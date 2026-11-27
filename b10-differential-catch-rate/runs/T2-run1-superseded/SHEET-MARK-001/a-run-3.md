```rust
/// Distinct settle pass — invoked strictly after formula-write returns,
/// never called from within the write path.
pub struct SettleConfig {
    pub poll_interval: Duration,
    pub timeout: Duration,
}

pub enum Mark {
    Price(Cents),
    SheetError(String), // e.g. #N/A, #REF!, #ERROR! — terminal per GOOGLEFINANCE
    TimedOut,           // settle pass exhausted timeout before resolving
}

pub trait SheetClient {
    fn read_price_cells(&self, rows: &[RowId]) -> Result<HashMap<RowId, CellValue>, SheetErr>;
}

enum CellState { Numeric(f64), TerminalError(String), Pending }

fn classify(v: &CellValue) -> CellState {
    match v {
        CellValue::Number(n) => CellState::Numeric(*n),
        CellValue::Text(s) if is_terminal_error(s) => CellState::TerminalError(s.clone()),
        _ => CellState::Pending, // "Loading...", blank, transient #N/A
    }
}

pub fn settle_marks(
    client: &impl SheetClient,
    rows: &[RowId],
    cfg: &SettleConfig,
) -> HashMap<RowId, Mark> {
    let deadline = Instant::now() + cfg.timeout;
    let mut pending: HashSet<RowId> = rows.iter().copied().collect();
    let mut marks = HashMap::new();

    while !pending.is_empty() && Instant::now() < deadline {
        let batch: Vec<RowId> = pending.iter().copied().collect();
        if let Ok(values) = client.read_price_cells(&batch) {
            for (row, val) in values {
                match classify(&val) {
                    CellState::Numeric(n) => { marks.insert(row, Mark::Price(dollars_to_cents(n))); pending.remove(&row); }
                    CellState::TerminalError(e) => { marks.insert(row, Mark::SheetError(e)); pending.remove(&row); }
                    CellState::Pending => {}
                }
            }
        }
        if !pending.is_empty() { thread::sleep(cfg.poll_interval); }
    }
    for row in pending { marks.insert(row, Mark::TimedOut); }
    marks
}
```

**Assumptions (invented, not in the EARS text):**

1. A `RowId`/`CellValue` abstraction stands in for actual Sheets API types; batched via `read_price_cells` per poll (one call for all pending rows), not one call per cell — EARS doesn't mandate batching, but it's the reasonable default for a bounded-timeout poll loop.
2. "Numeric" = Sheets returns a plain number type for the cell (post-`GOOGLEFINANCE` resolution); any string is treated as non-numeric.
3. "Terminally errored" = a recognized Sheets/GOOGLEFINANCE error string (`#N/A`, `#ERROR!`, `#REF!`, etc.) distinguished from transient placeholder states (blank, "Loading...", transient `#N/A` during fetch) — I chose to treat bare `#N/A` as *pending* unless a helper `is_terminal_error` positively identifies it, since GOOGLEFINANCE briefly shows `#N/A` while loading. This is the most ambiguous call in the EARS; an alternative reading treats any `#N/A` as terminal immediately.
4. Timeout is a single wall-clock deadline for the whole pass (all rows), not per-cell — EARS says "a bounded timeout" singular, not per-row.
5. On timeout, unresolved rows get an explicit `Mark::TimedOut` variant rather than being silently dropped or conflated with `SheetError`, so downstream consumers can distinguish infra timeout from a real formula error.
6. Price values are dollars (float) from Sheets and converted to integer `Cents` via a `dollars_to_cents` rounding helper (not shown), consistent with the workspace's integer-money invariant.
7. Poll interval is fixed/constant (no backoff specified by the EARS).
8. Formula-writing itself is assumed to live in a separate prior function; `settle_marks` is never called from it, satisfying "never inline with the formula write."