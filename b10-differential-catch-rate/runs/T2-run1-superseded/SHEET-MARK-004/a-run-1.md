```rust
use chrono::NaiveDate;

/// Raw read-back of a GOOGLEFINANCE-backed cell pair, parsed off the sheet
/// during the marks settle pass (parsing itself happens upstream of this
/// module — sheets-view owns projection, not accounting math).
pub struct SheetQuoteReadback {
    pub symbol: String,
    pub price_cents: i64,
    /// Quote date as derived from GOOGLEFINANCE's own output
    /// (its paired date/tradetime cell), already parsed to a calendar date.
    pub quote_date: Option<NaiveDate>,
}

/// A cached price mark: a snapshot stamped with the date it was quoted for.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CachedMark {
    pub symbol: String,
    pub price_cents: i64,
    pub quote_date: NaiveDate,
}

#[derive(Debug, thiserror::Error)]
pub enum StampMarkError {
    #[error("GOOGLEFINANCE returned no usable quote date for {0}; refusing to fall back to wall-clock")]
    MissingQuoteDate(String),
}

/// Stamp a cached mark using GOOGLEFINANCE's own quote date.
/// Deliberately has no access to a clock — SHEET-MARK-004 is enforced
/// structurally, not by convention, since there is no `now()` to reach for.
pub fn stamp_mark(readback: SheetQuoteReadback) -> Result<CachedMark, StampMarkError> {
    let quote_date = readback
        .quote_date
        .ok_or_else(|| StampMarkError::MissingQuoteDate(readback.symbol.clone()))?;

    Ok(CachedMark {
        symbol: readback.symbol,
        price_cents: readback.price_cents,
        quote_date,
    })
}
```

Assumptions:
1. "Mark" = a per-symbol price snapshot `{symbol, price_cents, quote_date}`.
2. "Quote date" is a calendar date (`NaiveDate`), not a timestamp — GOOGLEFINANCE's date-bearing output (e.g. its historical-range date column, or a tradetime cell resolved against the market's session date) resolves to a date; the requirement says "date," not "datetime."
3. Sheet-cell parsing (turning the GOOGLEFINANCE cell text into `Option<NaiveDate>`) happens upstream in the read-back step, not here — `stamp_mark` only decides stamping policy, keeping the sheets-view crate free of formula-parsing logic mixed with domain logic.
4. On a missing/unparseable quote date (`#N/A`, market holiday, unrecognized ticker) the function returns an explicit error rather than silently substituting wall-clock time — substituting would directly violate the requirement, so failure is preferred over a plausible-looking wrong stamp. Caller decides retry-next-settle-pass vs. skip-this-symbol.
5. No `SystemTime`/`Utc::now`/`Local::now` call exists anywhere in this path, by construction — the function signature has no clock input, making "never wall-clock" mechanically true rather than merely intended.
6. `price_cents: i64` stands in for the workspace's existing `Cents` newtype (per the described integer-cents money type); shown as its underlying representation for brevity.
7. Ambiguity resolved: "cache each mark" is read as upsert-by-symbol (a settle pass overwrites the prior cached mark for that symbol with the newly stamped one), not an append-only history — no versioning/history requirement is implied by this EARS alone.