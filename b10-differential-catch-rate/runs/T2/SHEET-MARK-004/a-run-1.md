```rust
//! sheets-view :: read-back settle pass
//! Stamps each cached mark with the quote date GOOGLEFINANCE itself
//! reports, never the time this process happened to read it.

use chrono::NaiveDate;

/// A price mark held in the local cache for one instrument.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CachedMark {
    pub symbol: String,
    pub price_cents: i64,
    /// The date GOOGLEFINANCE attributes to this quote — not wall-clock.
    pub quote_date: NaiveDate,
}

/// One row read back from the sheet's price+date column pair, both
/// produced by GOOGLEFINANCE formulas.
pub struct SheetQuoteRow {
    pub symbol: String,
    pub price: f64,
    /// Raw cell text from the companion GOOGLEFINANCE date attribute.
    pub quote_date_raw: String,
}

#[derive(Debug)]
pub enum StampError {
    InvalidDate(String),
    InvalidPrice(f64),
}

/// Pure mapping: sheet read-back -> cached mark. Deliberately never
/// calls a clock; a missing/unparseable quote date is an error, not a
/// wall-clock fallback, per SHEET-MARK-004.
pub fn stamp_mark(row: &SheetQuoteRow) -> Result<CachedMark, StampError> {
    let quote_date = NaiveDate::parse_from_str(&row.quote_date_raw, "%Y-%m-%d")
        .map_err(|_| StampError::InvalidDate(row.quote_date_raw.clone()))?;

    if !row.price.is_finite() || row.price < 0.0 {
        return Err(StampError::InvalidPrice(row.price));
    }
    let price_cents = (row.price * 100.0).round() as i64;

    Ok(CachedMark { symbol: row.symbol.clone(), price_cents, quote_date })
}
```

Assumptions (invented, not in the EARS text):

1. "Cached mark" = a `CachedMark{symbol, price_cents, quote_date}` struct; no other fields specified.
2. GOOGLEFINANCE doesn't emit a date for a plain price query, so a companion cell/column supplies the quote date; the settle pass reads both together as one `SheetQuoteRow`.
3. `quote_date` is a calendar date (`NaiveDate`), not a timestamp — GOOGLEFINANCE quote dates carry no time-of-day/timezone semantics worth modeling here.
4. Sheets API returns the date cell as an ISO `"YYYY-MM-DD"` string (value-render-option dependent; ambiguous, chosen as simplest deterministic parse).
5. Invalid/unparseable date (`#N/A`, empty, malformed) → `Err`, cached mark is left untouched rather than silently stamped with `Utc::now()` — a wall-clock fallback would violate the requirement outright, so failure must be loud, not silent.
6. Stale dates (prior trading day, weekend/holiday close) are accepted as valid — that's the whole point of stamping the *quote* date instead of read time; no freshness check is performed here.
7. Price→Cents uses round-half-away-from-zero via `f64::round()`; negative/NaN/Inf price rejected as defensive input validation, since EARS doesn't specify.
8. Concurrency/persistence of the cache write itself is out of scope; this sketch covers only the stamping computation, not storage transaction semantics.