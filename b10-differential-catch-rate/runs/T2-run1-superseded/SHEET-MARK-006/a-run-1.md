```rust
/// One instrument's price mark read back from the workbook.
#[derive(Debug, Clone)]
pub struct Mark {
    pub symbol: String,
    pub price_cents: i64,
    pub as_of: chrono::DateTime<chrono::Utc>,
}

/// Failure of the underlying sheet transport (network/API/IO) during read-back.
#[derive(Debug)]
pub struct TransportError(pub String);

#[derive(Debug)]
pub enum MarksReadBackError {
    Transport(TransportError),
}

pub trait SheetTransport {
    fn read_cell(&self, range: &str) -> Result<String, TransportError>;
}

/// Runs one marks read-back pass. On any transport failure, aborts
/// immediately and returns Err — no partial marks are ever handed back,
/// since accumulation happens in a local buffer that is simply dropped.
/// This function does NOT perform carry-forward; that is `runtime`'s job.
pub fn read_back_marks(
    transport: &dyn SheetTransport,
    ranges: &[(String, String)], // (symbol, cell_range)
) -> Result<Vec<Mark>, MarksReadBackError> {
    let mut marks = Vec::with_capacity(ranges.len());
    for (symbol, range) in ranges {
        let cell = transport
            .read_cell(range)
            .map_err(MarksReadBackError::Transport)?; // fail-fast, whole pass aborts
        let price_cents = parse_price_cents(&cell);
        marks.push(Mark { symbol: symbol.clone(), price_cents, as_of: chrono::Utc::now() });
    }
    Ok(marks) // only returned if every read succeeded
}

fn parse_price_cents(_cell: &str) -> i64 { 0 /* elided */ }

/// runtime: owns carry-forward across passes.
pub struct MarksCache { last_good: Vec<Mark> }

impl MarksCache {
    pub fn apply(&mut self, result: Result<Vec<Mark>, MarksReadBackError>) -> (&[Mark], Option<MarksReadBackError>) {
        match result {
            Ok(new_marks) => { self.last_good = new_marks; (&self.last_good, None) }
            Err(e) => (&self.last_good, Some(e)), // retain last cached marks; propagate error upward
        }
    }
}
```

Assumptions (invented, since only the EARS text was given):
1. `Mark` shape (symbol, `price_cents: i64` per project's Cents convention, timestamp) is invented — spec doesn't define it.
2. "Transport failure" scoped narrowly to the `SheetTransport` I/O boundary (network/API/auth errors), not to parsing/format errors on returned cell content — spec says "transport failure" specifically.
3. Fail-fast on the *first* transport error, aborting the whole pass rather than attempting remaining instruments — chosen to satisfy "no partial marks" trivially, since partially-collected marks are simply never returned.
4. "Emit no marks" interpreted as: the function never returns/writes any marks for a failed pass — implemented via building the full `Vec<Mark>` locally and only returning it on total success, so no downstream writer ever sees a partial set.
5. Carry-forward is modeled as living entirely outside this function, in a separate `runtime`-owned `MarksCache` — the read-back function has zero awareness of previous marks, matching "runtime owns carry-forward."
6. Synchronous, blocking transport trait assumed; async/retry policy unspecified by the EARS and omitted.
7. Non-transport errors (e.g., malformed cell values) are out of scope for this spec and not handled by `MarksReadBackError` beyond a placeholder variant.
8. No partial-pass retry/backoff logic assumed — EARS only mandates propagate-and-emit-nothing, not retry behavior.