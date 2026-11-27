```rust
use std::collections::HashMap;
use std::time::{Duration, Instant};

/// Terminal state of one Price cell after settling.
#[derive(Debug, Clone)]
pub enum Mark {
    Numeric(f64),
    TerminalError(String), // e.g. "#N/A", "#ERROR!", "#REF!"
}

#[derive(Debug, Clone)]
pub enum SettleOutcome {
    Settled(Mark),
    TimedOut, // still blank/computing when deadline hit
}

#[derive(Debug)]
pub struct SheetsError(pub String);

pub trait SheetsClient {
    /// Raw string per row's Price cell: numeric literal, a sheet error
    /// string starting with '#', or "" if GOOGLEFINANCE is still computing.
    fn read_price_cells(&self, sheet: &str, rows: &[u32]) -> Result<Vec<String>, SheetsError>;
}

pub struct SettleConfig {
    pub poll_interval: Duration,
    pub timeout: Duration,
}

impl Default for SettleConfig {
    fn default() -> Self {
        Self { poll_interval: Duration::from_millis(500), timeout: Duration::from_secs(30) }
    }
}

/// Settle pass. Caller MUST invoke this only after the formula-write call
/// has returned and completed — never from within it.
pub fn settle_marks(
    client: &impl SheetsClient,
    sheet: &str,
    rows: &[u32],
    cfg: &SettleConfig,
) -> HashMap<u32, SettleOutcome> {
    let deadline = Instant::now() + cfg.timeout;
    let mut results = HashMap::new();
    let mut pending: Vec<u32> = rows.to_vec();

    while !pending.is_empty() && Instant::now() < deadline {
        if let Ok(values) = client.read_price_cells(sheet, &pending) {
            let mut still_pending = Vec::new();
            for (row, raw) in pending.iter().zip(values) {
                let raw = raw.trim();
                if raw.starts_with('#') {
                    results.insert(*row, SettleOutcome::Settled(Mark::TerminalError(raw.into())));
                } else if let Ok(v) = raw.parse::<f64>() {
                    results.insert(*row, SettleOutcome::Settled(Mark::Numeric(v)));
                } else {
                    still_pending.push(*row);
                }
            }
            pending = still_pending;
        }
        if !pending.is_empty() {
            std::thread::sleep(cfg.poll_interval.min(deadline.saturating_duration_since(Instant::now())));
        }
    }
    for row in pending {
        results.insert(row, SettleOutcome::TimedOut);
    }
    results
}
```

Assumptions invented:
1. Timeout is a single deadline for the whole settle pass (all rows), not per-cell — EARS says "a bounded timeout" (singular), read as pass-scoped.
2. "Numeric" = raw cell string parses as `f64`; no currency/Cents conversion here — that belongs to the kernel, per the project's Cents/no-accounting-in-sheets-view boundary.
3. "Terminally errored" = cell text starting with `#` (Sheets' convention: `#N/A`, `#ERROR!`, `#REF!`, `#NUM!`); treated as terminal, not retried.
4. Blank/whitespace or non-numeric, non-`#` text = still-computing, kept pending and retried.
5. Transport/API failures on a poll (`Err` from `read_price_cells`) are treated as transient — the tick is skipped and the same rows retried next interval, not counted as terminal errors, since they're a read-back fault, not a cell-formula fault.
6. Rows still pending when the deadline passes get `SettleOutcome::TimedOut`, kept distinct from `TerminalError` so callers don't conflate "sheet gave up" with "GOOGLEFINANCE gave up."
7. Defaults: 500ms poll interval, 30s total timeout — not specified in the EARS, chosen as plausible values; both are configurable via `SettleConfig`.
8. Separation from the write is enforced structurally (this function takes no write-side handle/state and is documented as a distinct call), since the EARS forbids inlining but Rust's type system can't itself prevent a caller from calling it inline.
9. `SheetsClient` abstracts the actual Sheets API; batch-read per tick (not one call per cell) assumed for efficiency, not required by the spec.