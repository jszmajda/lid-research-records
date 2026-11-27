```rust
/// Settle pass: reads back GOOGLEFINANCE-derived marks after a prior,
/// separate write of price formulas. Never called inline with that write.
pub struct SettleConfig {
    pub poll_interval: std::time::Duration, // e.g. 500ms
    pub timeout: std::time::Duration,       // e.g. 30s bounded cap
}

#[derive(Debug, Clone, PartialEq)]
pub enum Mark {
    Numeric(Cents),
    TerminalError(String), // e.g. "#N/A", "#ERROR!"
}

#[derive(Debug)]
pub enum SettleError {
    Timeout { unresolved_rows: Vec<RowId> },
    Sheets(SheetsApiError),
}

pub type Cents = i64;
pub type RowId = u32;

/// Polls the `Price` column for each tracked row until every cell is
/// either numeric or terminally errored, or the bounded timeout elapses.
pub fn settle_marks(
    sheets: &impl SheetsClient,
    spreadsheet_id: &str,
    price_range: &str, // e.g. "Positions!C2:C50"
    row_ids: &[RowId],
    cfg: &SettleConfig,
) -> Result<Vec<(RowId, Mark)>, SettleError> {
    let deadline = std::time::Instant::now() + cfg.timeout;
    let mut resolved: std::collections::HashMap<RowId, Mark> = std::collections::HashMap::new();

    loop {
        let cells = sheets
            .read_range(spreadsheet_id, price_range)
            .map_err(SettleError::Sheets)?;

        for (row, cell) in row_ids.iter().zip(cells.iter()) {
            if resolved.contains_key(row) {
                continue;
            }
            match classify_cell(cell) {
                Some(mark) => { resolved.insert(*row, mark); }
                None => {} // still pending (blank/#N/A-loading/formula-pending)
            }
        }

        if resolved.len() == row_ids.len() {
            break;
        }
        if std::time::Instant::now() >= deadline {
            let unresolved = row_ids.iter().filter(|r| !resolved.contains_key(r)).copied().collect();
            return Err(SettleError::Timeout { unresolved_rows: unresolved });
        }
        std::thread::sleep(cfg.poll_interval);
    }

    Ok(row_ids.iter().map(|r| (*r, resolved[r].clone())).collect())
}

fn classify_cell(raw: &str) -> Option<Mark> {
    if let Ok(dollars) = raw.parse::<f64>() {
        return Some(Mark::Numeric((dollars * 100.0).round() as Cents));
    }
    if raw.starts_with('#') { return Some(Mark::TerminalError(raw.to_string())); }
    None // pending
}
```

Assumptions (invented, not given by the EARS):
1. "Separate settle pass" = a distinct function/call boundary, invoked strictly after the formula-write call returns — never in the same request/transaction.
2. Poll granularity: whole-range re-read each tick (batched), not per-cell requests, for API-quota reasons.
3. "Terminally errored" = cell text begins with `#` (GOOGLEFINANCE error convention: `#N/A`, `#ERROR!`); anything else non-numeric is treated as still-pending, not error.
4. Blank/empty cell = pending, not error.
5. Timeout is a wall-clock deadline (`Instant`-based), not a poll-count cap.
6. On timeout, partial results return via `SettleError::Timeout` carrying which rows never resolved, rather than silently dropping them — since the EARS doesn't specify partial-success semantics, I chose fail-with-detail over discard.
7. Currency conversion (dollars→Cents) happens at settle time, consistent with the integer-Cents money type stated in context.
8. `SheetsClient` trait is an assumed abstraction over the real Sheets API; not specified by the EARS.
9. No retry/backoff strategy specified — fixed-interval poll chosen as simplest compliant reading of "bounded timeout."