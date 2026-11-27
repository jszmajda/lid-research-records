```rust
// sheets-view crate: read-back settle pass for cached price marks.
use chrono::NaiveDate;
use std::collections::HashMap;

/// Cached mark for one symbol, keyed by ticker in the settle cache.
#[derive(Clone, Debug, PartialEq)]
pub struct Mark {
    pub symbol: String,
    pub price_cents: i64,
    /// GOOGLEFINANCE's own quote date — never the wall-clock read time.
    pub quote_date: NaiveDate,
}

/// One row read back from the sheet's GOOGLEFINANCE-backed columns
/// before it is folded into the mark cache.
pub struct RawQuoteRow {
    pub symbol: String,
    pub price: Option<f64>,
    /// The date attribute GOOGLEFINANCE attaches to this quote
    /// (read back from its own column, not sampled from the clock).
    pub quote_date: Option<NaiveDate>,
}

#[derive(Debug, PartialEq)]
pub enum MarkError {
    MissingPrice(String),
    InvalidPrice(String, f64),
    MissingQuoteDate(String),
}

/// Stamp one read-back row into the mark cache, dating it with
/// GOOGLEFINANCE's quote date rather than `Utc::now()`.
pub fn settle_mark(
    row: RawQuoteRow,
    cache: &mut HashMap<String, Mark>,
) -> Result<Mark, MarkError> {
    let price = row
        .price
        .filter(|p| p.is_finite() && *p >= 0.0)
        .ok_or_else(|| match row.price {
            Some(p) => MarkError::InvalidPrice(row.symbol.clone(), p),
            None => MarkError::MissingPrice(row.symbol.clone()),
        })?;

    // No fallback to wall-clock time: a missing quote date is an error,
    // not a reason to stamp with the read timestamp instead.
    let quote_date = row
        .quote_date
        .ok_or_else(|| MarkError::MissingQuoteDate(row.symbol.clone()))?;

    let mark = Mark {
        symbol: row.symbol.clone(),
        price_cents: (price * 100.0).round() as i64,
        quote_date,
    };
    cache.insert(row.symbol.clone(), mark.clone());
    Ok(mark)
}
```

Assumptions (invented, none given in the EARS text):
1. "Cached mark" = a `Mark { symbol, price_cents, quote_date }` struct keyed by ticker in an in-memory `HashMap`; no persistence format specified.
2. GOOGLEFINANCE's real-time `"price"` attribute alone carries no date; assumed the sheet pairs it with a second GOOGLEFINANCE-derived date cell/column, surfaced here as `RawQuoteRow.quote_date`, already read back by the caller.
3. Quote date is a plain calendar date (`NaiveDate`) — no time-of-day or timezone component, since GOOGLEFINANCE quote dates are day-granular.
4. Missing/blank quote date (holiday, `#N/A`, bad ticker) is treated as a hard error (`MissingQuoteDate`), not silently defaulted to the wall-clock read time — defaulting would directly violate the "not wall-clock" clause.
5. Price is read as `f64` from the sheet and converted to integer `Cents` via round-half-away-from-zero; `NaN`/negative/infinite price is rejected as `InvalidPrice`.
6. Re-settling the same symbol overwrites the prior cache entry (last read-back wins); no explicit staleness/ordering rule was given.
7. Out of scope: any accounting/tax use of the mark, and how/when the settle pass is triggered — this crate only projects and stamps, per the stated ownership boundary.