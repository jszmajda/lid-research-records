```rust
// --- shared value types (assumed shapes) ---
pub type Cents = i64;

#[derive(Debug, Clone)]
pub struct Mark {
    pub symbol: String,
    pub price: Cents,
}

#[derive(Debug)]
pub struct TransportError(pub String);

#[derive(Debug)]
pub enum ReadBackError {
    Transport(TransportError),
    // other non-transport failure kinds are out of scope for this spec
}

pub trait MarkTransport {
    fn read_cell(&self, symbol: &str) -> Result<Cents, TransportError>;
}

/// One read-back pass. Fails fast: on the first transport error, no
/// Vec of marks is ever handed back to the caller — the partially
/// built list is dropped with the stack frame, satisfying
/// "no partial or degraded marks".
pub fn read_back_marks(
    transport: &impl MarkTransport,
    expected_symbols: &[String],
) -> Result<Vec<Mark>, ReadBackError> {
    let mut marks = Vec::with_capacity(expected_symbols.len());
    for symbol in expected_symbols {
        let price = transport
            .read_cell(symbol)
            .map_err(ReadBackError::Transport)?; // propagate, drop `marks`
        marks.push(Mark { symbol: symbol.clone(), price });
    }
    Ok(marks)
}

// --- runtime: owns carry-forward, not this module ---
pub struct MarksCache {
    last_good: Vec<Mark>,
}

impl MarksCache {
    pub fn new() -> Self { Self { last_good: Vec::new() } }

    /// Feeds one pass's result in. On Ok, replaces the cache. On Err,
    /// leaves the cache untouched and re-propagates the error so the
    /// caller knows the pass failed, while `current()` still serves
    /// the last cached marks.
    pub fn apply_pass(&mut self, result: Result<Vec<Mark>, ReadBackError>) -> Result<(), ReadBackError> {
        let marks = result?;
        self.last_good = marks;
        Ok(())
    }

    pub fn current(&self) -> &[Mark] {
        &self.last_good
    }
}
```

Assumptions (all invented, not stated by the EARS):

1. "Transport failure" is a distinct error variant separate from other possible pass failures; only it is in scope here — the EARS text doesn't define the full error taxonomy.
2. `Mark`/`Cents` shapes invented (`symbol: String`, `price: Cents`) — no field names given.
3. No-partial-marks is achieved via fail-fast iteration (`?` short-circuits before pushing further), not collect-then-discard; both satisfy the requirement, this picks the cheaper one.
4. "Runtime owns carry-forward" interpreted as a hard module boundary: `read_back_marks` is stateless and holds no cache; a separate `MarksCache` (assumed to live in a `runtime` crate/module) is the sole owner of "last cached marks" and only mutates on `Ok`.
5. On error, `MarksCache::apply_pass` still returns `Err` (propagates) rather than swallowing it — cache retention and error propagation are treated as independent, both-required behaviors, not alternatives.
6. Initial/boundary case: before any successful pass, `last_good` defaults to an empty `Vec` — EARS doesn't specify pre-first-pass state.
7. No retry/backoff logic included — assumed out of scope for this spec (retry policy, if any, lives elsewhere).
8. Transport dependency injected via a `MarkTransport` trait for testability — not required by the EARS text, added for a plausible unit-testable sketch.