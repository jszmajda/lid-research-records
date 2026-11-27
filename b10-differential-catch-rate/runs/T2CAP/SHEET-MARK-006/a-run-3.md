```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-006

use std::collections::BTreeMap;

pub type Ticker = String;

/// Money is integer Cents everywhere in the workspace.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Cents(pub i64);

#[derive(Clone, Copy, Debug)]
pub struct Mark {
    pub price: Cents,
    /// Sheet recalc timestamp read back alongside the price.
    pub as_of: i64,
}

/// One read-back pass produces all marks or none.
pub type MarkSet = BTreeMap<Ticker, Mark>;

#[derive(Debug, thiserror::Error)]
pub enum MarksError {
    #[error("transport failure during marks read-back: {0}")]
    Transport(#[from] TransportError),
    #[error("unparseable cell for {ticker}: {detail}")]
    Cell { ticker: Ticker, detail: String },
}

/// Anything that can fail to reach the workbook.
pub trait MarksTransport {
    /// Returns raw cell values for the GOOGLEFINANCE column, in range order.
    fn read_range(&self, range: &str) -> Result<Vec<RawCell>, TransportError>;
}

/// Reads one pass. All-or-nothing: on any transport failure the error
/// propagates and NO marks are returned — not a partial map, not a
/// map with defaulted/stale entries. Caller (`runtime`) keeps its cache.
pub fn read_marks<T: MarksTransport>(
    transport: &T,
    range: &str,
    tickers: &[Ticker],
) -> Result<MarkSet, MarksError> {
    // `?` is the whole requirement: no fallback arm, no retry, no partial accumulator.
    let cells = transport.read_range(range)?;

    // Build into a local map; it is only handed back on full success.
    let mut marks = MarkSet::new();
    for (ticker, cell) in tickers.iter().zip(cells) {
        let price = parse_cents(&cell).map_err(|detail| MarksError::Cell {
            ticker: ticker.clone(),
            detail,
        })?;
        marks.insert(ticker.clone(), Mark { price, as_of: cell.as_of });
    }
    Ok(marks)
}
```

Runtime side (carry-forward lives here, not in sheets-view):

```rust
// crates/runtime/src/mark_cache.rs — @spec SHEET-MARK-006
match sheets_view::marks::read_marks(&transport, RANGE, &tickers) {
    Ok(fresh) => { self.cached = Some(fresh.clone()); Ok(fresh) }
    Err(e) => { log::warn!("marks pass failed, carrying forward: {e}");
                self.cached.clone().ok_or(e) } // no cache yet => surface error
}
```

Assumptions invented:
1. Type shapes: `Cents(i64)`, `Mark{price,as_of}`, `MarkSet = BTreeMap<Ticker,Mark>` — none given by the EARS.
2. `MarksError` splits `Transport` from `Cell`; the EARS names only transport. I made cell-parse failures also abort the pass (same all-or-nothing shape) — chosen because "no partial or degraded marks" reads as a property of the pass, not of one error class.
3. "Propagate the error" = return `Err` up the call stack; no panic, no retry, no backoff at this layer.
4. "Emit no marks" = return no value at all (`Result`, not `Result<Option<..>>` and not an empty map) — an empty `MarkSet` would be a degraded mark set that a consumer could mistake for "all prices zero/absent".
5. Accumulation is into a local map returned only on success, so a mid-loop failure cannot leak partial state to the caller.
6. `read_marks` is pure/idempotent and holds no cache — carry-forward is `runtime`'s, per the EARS.
7. Cold-start edge case (failure with no prior cache): I surface the error rather than emitting an empty mark set. The EARS says "retaining the last cached marks" and is silent when there are none.
8. `tickers`/`cells` length mismatch is not handled explicitly; `zip` truncates. A real implementation should make that a hard error — flagged as a gap, not covered by this EARS.
9. Ambiguity chosen: "for that pass" scopes atomicity to a single read-back pass, not to the whole publish cycle; other tabs published in the same cycle are out of scope here.