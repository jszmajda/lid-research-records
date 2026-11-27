```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-006

use std::collections::BTreeMap;

pub type Ticker = String;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

#[derive(Debug, Clone)]
pub struct Mark {
    pub ticker: Ticker,
    pub price: Cents,
}

/// Whole-pass result: every ticker requested, or nothing.
#[derive(Debug, Clone)]
pub struct MarksPass {
    pub marks: BTreeMap<Ticker, Mark>,
    pub read_at: std::time::SystemTime,
}

#[derive(Debug, thiserror::Error)]
pub enum MarksError {
    #[error("transport failure during marks read-back: {0}")]
    Transport(#[source] TransportError),
    #[error("unreadable cell for {ticker}: {detail}")]
    Cell { ticker: Ticker, detail: String },
}

pub trait SheetsTransport {
    /// One call for the whole marks range; partial reads are not representable.
    fn read_range(&self, range: &str) -> Result<Vec<Vec<String>>, TransportError>;
}

/// Reads back the GOOGLEFINANCE price column for `expected`.
/// All-or-nothing: on ANY transport failure, returns Err and emits no marks.
pub fn read_back_marks<T: SheetsTransport>(
    transport: &T,
    range: &str,
    expected: &[Ticker],
) -> Result<MarksPass, MarksError> {
    // `?` is the whole requirement: no fallback, no cached value, no partial map.
    let rows = transport.read_range(range).map_err(MarksError::Transport)?;

    // Build into a local map; nothing escapes this fn unless every row parses.
    let mut marks = BTreeMap::new();
    for (row, ticker) in rows.iter().zip(expected) {
        let cell = row.first().map(String::as_str).unwrap_or("");
        let price = parse_cents(cell).ok_or_else(|| MarksError::Cell {
            ticker: ticker.clone(),
            detail: format!("unparseable/loading cell {cell:?}"),
        })?;
        marks.insert(ticker.clone(), Mark { ticker: ticker.clone(), price });
    }
    if marks.len() != expected.len() {
        return Err(MarksError::Cell {
            ticker: "<pass>".into(),
            detail: format!("short read: {} of {}", marks.len(), expected.len()),
        });
    }
    Ok(MarksPass { marks, read_at: std::time::SystemTime::now() })
}

// runtime side (NOT this crate's job beyond returning Err):
// match read_back_marks(..) { Ok(p) => cache.replace(p), Err(e) => { log(e); /* cache untouched: carry-forward */ } }
```

ASSUMPTIONS (all invented):
1. `TransportError` exists in a transport crate; `thiserror` is available.
2. Marks read back as a single ranged call, so "partial" is not naturally representable — enforced anyway via local-map-then-return.
3. Return type `Result<MarksPass, MarksError>` rather than `Result<Vec<Mark>, _>`; no `Option`/empty-vec success channel, since an empty success would read as degraded marks.
4. Non-transport failures (unparseable cell, `#N/A`, `Loading...`, short row count) also fail the whole pass — the EARS names transport only; I extended all-or-nothing to any read defect for consistency, and flagged it as a distinct error variant so callers can distinguish.
5. `parse_cents(&str) -> Option<Cents>` exists elsewhere (dollar-string → integer Cents).
6. Interpretation chosen: "emit no marks" = return `Err` and write nothing to any shared/cached state — not "emit an empty mark set". Caching, retry, and staleness policy live entirely in `runtime`; this function is pure and holds no cache reference, which is what makes carry-forward structurally `runtime`-owned.
7. No retry/backoff here; a retrying transport may wrap `SheetsTransport`, but exhausted retries surface as `Transport`.
8. `expected` empty → `Ok` with empty map (vacuous pass, not a failure).
9. Ordering: rows assumed positionally aligned to `expected`; misalignment is out of scope of this EARS.