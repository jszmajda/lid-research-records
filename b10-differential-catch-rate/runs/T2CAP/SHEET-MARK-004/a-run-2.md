```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-004
use time::Date;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

/// One row read back from the sheet's GOOGLEFINANCE oracle block.
#[derive(Debug, Clone)]
pub struct OracleRow {
    pub symbol: String,
    pub price_cents: Option<Cents>, // None => formula errored / still loading
    pub quote_date: Option<Date>,   // parsed from the GOOGLEFINANCE "date" attribute cell
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CachedMark {
    pub symbol: String,
    pub price: Cents,
    /// Provenance date: GOOGLEFINANCE's quote date. Never the read time.
    pub as_of: Date,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum MarkReject {
    NoPrice,
    NoQuoteDate,
}

/// Stamps a mark with the oracle's own quote date. Read time is not an input,
/// so no code path can substitute it.
pub fn stamp_mark(row: &OracleRow) -> Result<CachedMark, (String, MarkReject)> {
    let price = row.price_cents.ok_or_else(|| (row.symbol.clone(), MarkReject::NoPrice))?;
    let as_of = row.quote_date.ok_or_else(|| (row.symbol.clone(), MarkReject::NoQuoteDate))?;
    Ok(CachedMark { symbol: row.symbol.clone(), price, as_of })
}

pub fn stamp_all(rows: &[OracleRow]) -> (Vec<CachedMark>, Vec<(String, MarkReject)>) {
    let mut ok = Vec::with_capacity(rows.len());
    let mut rejected = Vec::new();
    for r in rows {
        match stamp_mark(r) {
            Ok(m) => ok.push(m),
            Err(e) => rejected.push(e),
        }
    }
    (ok, rejected)
}
```

ASSUMPTIONS (all invented):
1. `CachedMark`/`OracleRow`/`Cents` shapes are mine; requirement names no types.
2. Quote date modeled as a calendar `Date` (`time` crate), not a timestamp — GOOGLEFINANCE's "date" attribute for delayed equity quotes is day-granular. Intraday sub-day precision is discarded.
3. Signature deliberately takes no clock/`now` parameter — the strongest way to make "not the wall-clock read time" structurally unfalsifiable.
4. Missing/unparseable quote date is a hard reject, not a fallback to today. Substituting read time is exactly what the requirement forbids, so no fallback exists.
5. Missing price also rejects (a mark needs both), though the EARS speaks only to the date.
6. Parsing of the raw cell (string/serial number → `Date`, `#N/A`, `#ERROR!`, empty, "Loading...") happens upstream and yields `None`; not shown.
7. Rejects are returned to the caller rather than logged/panicked; the settle pass decides whether to retain a prior cached mark or leave the symbol unmarked.
8. Timezone/exchange-locale normalization of the quote date is out of scope — the oracle's date is taken as authoritative and stored verbatim.
9. Stale-date policy (how old is too old) is a different requirement; nothing here rejects on age.

INTERPRETATION: "cached mark" = the persisted price record produced by the marks read-back settle pass; "stamp" = the mark's as-of/provenance field. I read the requirement as constraining the *provenance* field only, not adding a separate read-time audit field — so I omitted a `read_at` field entirely rather than storing both, since storing both invites the wrong one being consumed downstream.