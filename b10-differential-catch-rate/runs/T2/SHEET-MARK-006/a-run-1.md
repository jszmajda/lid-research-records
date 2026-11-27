```rust
pub type Cents = i64;

#[derive(Debug, Clone)]
pub struct Mark { pub symbol: String, pub price: Cents, pub as_of: chrono::DateTime<chrono::Utc> }

pub type MarksSnapshot = std::collections::HashMap<String, Mark>;

#[derive(Debug, thiserror::Error)]
pub enum TransportError {
    #[error("network error: {0}")] Network(String),
    #[error("timeout")] Timeout,
}

#[derive(Debug, thiserror::Error)]
pub enum ReadBackError {
    #[error("transport failure during marks read-back: {0}")]
    Transport(#[from] TransportError),
}

/// Abstraction over the Sheets read call so transport failure is injectable/testable.
pub trait SheetTransport {
    fn read_marks_range(&self) -> Result<Vec<RawMarkRow>, TransportError>;
}

pub struct RawMarkRow { pub symbol: String, pub price_cents: Cents, pub as_of_iso: String }

/// One read-back pass. On transport failure: Err, and no MarksSnapshot is
/// constructed at all -- nothing partial exists to leak to a caller.
pub fn read_back_pass(t: &dyn SheetTransport) -> Result<MarksSnapshot, ReadBackError> {
    let rows = t.read_marks_range()?; // single bulk call: fails atomically, no partial rows
    let mut snapshot = MarksSnapshot::new();
    for r in rows {
        let as_of = r.as_of_iso.parse().unwrap_or_default(); // malformed row: not this spec's concern
        snapshot.insert(r.symbol.clone(), Mark { symbol: r.symbol, price: r.price_cents, as_of });
    }
    Ok(snapshot)
}

/// Runtime-owned cache. Carry-forward lives HERE, not in the read-back module.
pub struct MarksCache { last_good: MarksSnapshot }

impl MarksCache {
    pub fn apply_pass(&mut self, t: &dyn SheetTransport) -> Result<(), ReadBackError> {
        match read_back_pass(t) {
            Ok(snapshot) => { self.last_good = snapshot; Ok(()) } // atomic full replace
            Err(e) => Err(e), // last_good left untouched: this IS the carry-forward
        }
    }
    pub fn current(&self) -> &MarksSnapshot { &self.last_good }
}
```

Assumptions:
1. "Transport failure" = network/IO-layer error (`TransportError`), distinguished from parse/data errors (which the EARS doesn't govern); I did not surface a `Parse` variant on `ReadBackError` since the spec scopes only transport.
2. Underlying read is a single bulk fetch (`read_marks_range`) rather than per-symbol calls, so failure is naturally atomic — no partial rows can exist mid-construction. If the real transport is per-symbol/streaming, the same effect requires buffering into a local `Vec`/`HashMap` and only assigning to any shared/returned state after full success, never merging incrementally.
3. "Propagate the error" = return `Result::Err` up the call chain (no logging-and-swallowing, no default/zero marks substituted).
4. "Emit no marks for that pass" = the pass produces no `MarksSnapshot` value at all on failure — not an empty one and not one merged with old data — since an empty snapshot could be mistaken for "zero holdings" rather than "fetch failed."
5. Carry-forward ownership: modeled as `MarksCache`, sitting in the `runtime` layer, not the sheets-view/read-back module — `read_back_pass` itself is stateless and cache-unaware, matching "runtime owns carry-forward."
6. On failure, `last_good` is left byte-for-byte untouched (no timestamp bump, no staleness flag) — spec only requires retention, not staleness annotation.
7. Malformed timestamp defaults via `unwrap_or_default()` are a placeholder for out-of-scope parse-error handling, not a real fallback policy.