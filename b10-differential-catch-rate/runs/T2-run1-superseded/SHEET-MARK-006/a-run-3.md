```rust
// marks_readback.rs — SHEET-MARK-006

/// A single settled mark (price at read-back time), integer cents.
#[derive(Clone, Debug)]
pub struct Mark {
    pub symbol: String,
    pub price_cents: i64,
    pub as_of: i64, // unix seconds
}

#[derive(Debug)]
pub enum MarksError {
    /// Network/IO/API failure talking to the sheet backend during read-back.
    Transport(String),
}

/// Abstraction over the sheet client so this is testable without live I/O.
pub trait MarksSource {
    fn fetch_all(&self, symbols: &[String]) -> Result<Vec<Mark>, MarksError>;
}

/// One read-back pass. All-or-nothing: either every requested symbol's
/// mark is returned, or nothing is returned and the error propagates.
pub fn read_back_pass(
    source: &dyn MarksSource,
    symbols: &[String],
) -> Result<Vec<Mark>, MarksError> {
    // Single fetch call, not per-symbol accumulation — a failure partway
    // through must not leave a partial Vec in scope for the caller to use.
    source.fetch_all(symbols)
}

/// `runtime` owns carry-forward: on failure it keeps whatever it had.
pub struct Runtime {
    cached_marks: Vec<Mark>,
}

impl Runtime {
    pub fn cached_marks(&self) -> &[Mark] {
        &self.cached_marks
    }

    /// Attempt a settle pass. On success, replace the cache atomically.
    /// On transport failure, propagate the error unchanged and leave
    /// `cached_marks` exactly as it was (last-known-good).
    pub fn settle(
        &mut self,
        source: &dyn MarksSource,
        symbols: &[String],
    ) -> Result<(), MarksError> {
        let marks = read_back_pass(source, symbols)?; // early return, no mutation yet
        self.cached_marks = marks; // only reached on full success
        Ok(())
    }
}
```

Assumptions:
1. "Transport failure" maps to a single `MarksError::Transport` variant carrying a string; real code would wrap the underlying HTTP/API error type instead.
2. Read-back is modeled as one atomic `fetch_all` call rather than per-symbol loop, so there is no intermediate state that could be mistaken for "partial marks" — this is the most direct way to guarantee no partial/degraded emission given the spec's explicit prohibition.
3. `emit no marks for that pass` is interpreted as: the pass's `Result` is `Err`, and no `Vec<Mark>` is returned/published at all (not an empty `Ok(vec![])`, which would be a different, successful-but-empty signal).
4. Cache mutation (`self.cached_marks = marks`) happens only after the fetch succeeds (via `?` early-return), so a failure leaves the previous cache byte-for-byte untouched — satisfying "retaining the last cached marks."
5. `runtime` is modeled as the sole owner of `cached_marks`; the read-back function itself is stateless and holds no cache, matching "runtime owns carry-forward."
6. Boundary case (empty `symbols` slice) is left to `MarksSource` implementations/upstream validation — not addressed by this EARS.
7. Non-transport failures (e.g., malformed data) are out of scope for this spec and not modeled here.