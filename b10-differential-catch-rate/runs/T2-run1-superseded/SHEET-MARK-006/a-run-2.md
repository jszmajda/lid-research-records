```rust
// crate: sheets-view (owns the read-back pass only, no accounting/tax logic)

#[derive(Debug)]
pub struct Mark {
    pub symbol: String,
    pub price_cents: i64,
}

#[derive(Debug)]
pub enum MarksReadBackError {
    Transport(String), // network/API-level failure from the Sheets client
    // other variants (parse, schema) are out of scope for SHEET-MARK-006
}

pub trait SheetsClient {
    fn read_cell_range(&self, tab: &str, range: &str) -> Result<Vec<(String, i64)>, MarksReadBackError>;
}

/// Reads back marks for one pass. All-or-nothing: never returns a partially
/// populated Vec. On any transport failure, propagates the error and the
/// caller receives zero marks for this pass.
pub fn read_back_marks(
    client: &impl SheetsClient,
    tab: &str,
    range: &str,
) -> Result<Vec<Mark>, MarksReadBackError> {
    // Buffer locally; only materialize as the return value on full success,
    // so a mid-read transport error can't leak a partial/degraded result.
    let raw = client.read_cell_range(tab, range)?; // transport error short-circuits here
    let marks = raw
        .into_iter()
        .map(|(symbol, price_cents)| Mark { symbol, price_cents })
        .collect();
    Ok(marks)
}

// crate: runtime (owns carry-forward across passes)

pub struct MarksCache {
    last: Vec<Mark>,
}

impl MarksCache {
    pub fn refresh(
        &mut self,
        client: &impl SheetsClient,
        tab: &str,
        range: &str,
    ) -> Result<(), MarksReadBackError> {
        match read_back_marks(client, tab, range) {
            Ok(fresh) => {
                self.last = fresh;
                Ok(())
            }
            Err(e) => {
                // Retain last cached marks untouched; propagate the error
                // so the caller (e.g. scheduler/logger) knows this pass failed.
                Err(e)
            }
        }
    }

    pub fn current(&self) -> &[Mark] {
        &self.last
    }
}
```

Assumptions:
1. `Mark` shape is minimal (symbol, price_cents); real type likely richer but irrelevant to this spec.
2. "Transport failure" is a distinct error category (network/API-level), separate from parse/schema errors, which this spec doesn't govern.
3. "No partial or degraded marks" interpreted as all-or-nothing collection — read into a local buffer and only return it after full success, so a mid-read failure can't leak a partial `Vec`.
4. "Emit no marks" means `sheets-view`'s read-back function returns `Err` and calls no downstream publish/emit step at all for that pass.
5. Carry-forward logic (retaining last cached marks) lives in `runtime`, not `sheets-view`, per the requirement's explicit ownership split and the crate's no-accounting-logic charter.
6. Cache retention is in-memory only for this sketch; persistence lifetime is unspecified and out of scope.
7. Retry/backoff policy is unspecified — this function is single-attempt; retries are a caller/runtime concern.
8. Errors are propagated via `Result`/`?`, never swallowed or panicked on.
9. If reads are per-cell/streaming rather than one batch call, the same buffer-then-commit pattern applies to preserve atomicity.