```rust
/// Result of one marks read-back pass. On success, the full set of freshly
/// read marks for the pass; no partial/degraded variant exists by construction.
pub struct MarkSet {
    pub marks: Vec<Mark>,
}

pub struct Mark {
    pub symbol: String,
    pub price_cents: i64,
}

#[derive(Debug, thiserror::Error)]
pub enum MarkReadError {
    #[error("transport failure during marks read-back: {0}")]
    Transport(#[from] TransportError),
    // other read-back failure kinds may exist; only Transport is in scope here
}

#[derive(Debug, thiserror::Error)]
#[error("transport error: {0}")]
pub struct TransportError(pub String);

/// Performs one marks read-back pass. Emits either a complete MarkSet or
/// an error — never a partially-populated MarkSet.
pub fn read_back_marks(
    rows: &[SheetRow],
    fetch: &impl Fn(&SheetRow) -> Result<Mark, TransportError>,
) -> Result<MarkSet, MarkReadError> {
    let mut marks = Vec::with_capacity(rows.len());
    for row in rows {
        // First transport failure aborts the whole pass immediately;
        // partially-collected `marks` is dropped, not returned.
        let mark = fetch(row)?;
        marks.push(mark);
    }
    Ok(MarkSet { marks })
}

pub struct SheetRow {
    pub symbol: String,
}
```

Caller sketch (illustrating the ownership boundary only, not part of this EARS):
```rust
// In `runtime`: on Err, do nothing to cached_marks (carry-forward is
// retaining, i.e. a no-op) and propagate the error upward.
match sheets_view::read_back_marks(&rows, &fetch) {
    Ok(fresh) => runtime.cached_marks = fresh.marks,
    Err(e) => return Err(e.into()), // cached_marks left untouched
}
```

Assumptions:
1. "Transport failure" maps to a dedicated `TransportError` distinguished from other read-back errors (e.g., parse errors); only transport failures are in scope for this EARS, but the sketch treats any `fetch` error as triggering abort-and-propagate since the requirement's guarantee (no partial marks) is agnostic to error subtype.
2. Fail-fast-on-first-error interpretation chosen over "collect all failures then report": the requirement's "no partial or degraded marks" reads as an atomicity guarantee, so the first error aborts the pass rather than continuing to accumulate.
3. `read_back_marks` (sheets-view crate) is the emitting boundary; it returns `Result<MarkSet, _>` with no partial-state variant, satisfying "emit no marks for that pass" structurally (the type has no partial constructor).
4. Carry-forward cache (`cached_marks`) is modeled as owned by `runtime`, not `sheets-view`, matching "runtime owns carry-forward" — the sketch shows this as an external field the function never touches on error.
5. Empty `rows` input is treated as trivially successful (`Ok(MarkSet{marks: vec![]})`), not an error — not addressed by this EARS.
6. No retry/backoff logic assumed; propagation is immediate per "shall propagate the error."