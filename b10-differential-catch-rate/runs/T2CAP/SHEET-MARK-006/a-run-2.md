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

/// One read-back pass: all-or-nothing.
#[derive(Debug, Clone)]
pub struct MarksPass {
    pub marks: BTreeMap<Ticker, Mark>,
}

#[derive(Debug, thiserror::Error)]
pub enum MarksError {
    #[error("transport failure during marks read-back: {0}")]
    Transport(#[source] Box<dyn std::error::Error + Send + Sync>),
    #[error("unreadable oracle cell for {ticker}: {detail}")]
    CellValue { ticker: Ticker, detail: String },
}

pub trait SheetsTransport {
    /// Returns the raw GOOGLEFINANCE column read-back, or a transport error.
    fn read_range(&self, range: &str) -> Result<Vec<Vec<String>>, Box<dyn std::error::Error + Send + Sync>>;
}

/// Reads back the price-oracle column and returns a complete pass, or an error.
/// Never returns a partially populated `MarksPass`: the buffer is local and is
/// dropped on any error path, so no marks escape a failed pass.
pub fn read_back_marks<T: SheetsTransport>(
    transport: &T,
    range: &str,
    expected: &[Ticker],
) -> Result<MarksPass, MarksError> {
    let rows = transport
        .read_range(range)
        .map_err(MarksError::Transport)?; // propagate; emit nothing

    let mut buf = BTreeMap::new();
    for (ticker, row) in expected.iter().zip(rows.iter()) {
        let cell = row.first().map(String::as_str).unwrap_or("");
        let price = parse_cents(cell).ok_or_else(|| MarksError::CellValue {
            ticker: ticker.clone(),
            detail: cell.to_string(),
        })?; // `?` drops `buf` — no degraded marks
        buf.insert(ticker.clone(), Mark { ticker: ticker.clone(), price });
    }
    if buf.len() != expected.len() {
        return Err(MarksError::CellValue {
            ticker: "<pass>".into(),
            detail: format!("short read: {} of {}", buf.len(), expected.len()),
        });
    }
    Ok(MarksPass { marks: buf })
}

fn parse_cents(s: &str) -> Option<Cents> { /* decimal -> Cents, half-even */ unimplemented!() }
```

Runtime side (owner of carry-forward, shown for contract clarity only — not part of this crate):

```rust
match sheets_view::read_back_marks(&t, RANGE, &tickers) {
    Ok(pass) => { self.cached_marks = pass; }      // replace wholesale
    Err(e)   => { log_and_surface(&e); }           // retain last cached marks
}
```

Assumptions invented:
1. `Cents(i64)`; prices non-negative but not enforced here.
2. Transport is a trait returning `Box<dyn Error>`; "transport failure" = any I/O/auth/HTTP/timeout/quota error from that call — no retry, no classification, no backoff at this layer.
3. Return type `Result<MarksPass, MarksError>` rather than `Result<Vec<Mark>, _>`, so "emit no marks" is structurally impossible to violate.
4. `expected: &[Ticker]` supplies row ordering; a short/mismatched read is treated as a failed pass (chose strict over truncation, since truncation is "partial marks").
5. Unparseable/`#N/A`/`#ERROR!` cells fail the whole pass — the EARS names only transport failure, but degraded-marks prohibition reads as pass-level atomicity; stated as a separate error variant so runtime can distinguish.
6. No side channel: no metrics/partial emit/logging of marks inside the function.
7. Empty `expected` yields an empty successful pass (vacuous, not an error).
8. Sync API; async is a mechanical `.await` swap.
9. Runtime holds cache; sheets-view is stateless — no last-good copy kept here.
10. No staleness bound or age stamping on carry-forward (not stated in this EARS).