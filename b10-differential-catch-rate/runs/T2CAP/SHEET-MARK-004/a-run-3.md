```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-004

use time::Date; // date-only, no time-of-day

/// A raw row read back from the sheet's GOOGLEFINANCE column.
pub struct QuoteRow {
    pub symbol: String,
    /// Cell value of the price formula, already parsed to Cents by the caller.
    pub price: Cents,
    /// Cell value of the companion `GOOGLEFINANCE(sym,"datadelay")`-adjacent
    /// date attribute, as returned by the sheet (serial or RFC3339-ish text).
    pub quote_date_cell: Option<CellValue>,
}

/// A mark we are willing to cache.
pub struct CachedMark {
    pub symbol: String,
    pub price: Cents,
    /// Provenance of `as_of`: always the oracle's own quote date.
    pub as_of: Date,
}

#[derive(Debug)]
pub enum MarkError {
    MissingQuoteDate { symbol: String },
    UnparseableQuoteDate { symbol: String, raw: String },
}

/// Stamp a read-back row with GOOGLEFINANCE's quote date.
/// Wall-clock time is deliberately not a parameter: it cannot leak into `as_of`.
pub fn stamp_mark(row: QuoteRow) -> Result<CachedMark, MarkError> {
    let cell = row.quote_date_cell
        .ok_or_else(|| MarkError::MissingQuoteDate { symbol: row.symbol.clone() })?;
    let as_of = parse_quote_date(&cell).ok_or_else(|| MarkError::UnparseableQuoteDate {
        symbol: row.symbol.clone(),
        raw: cell.to_raw_string(),
    })?;
    Ok(CachedMark { symbol: row.symbol, price: row.price, as_of })
}

/// Sheets serials are days since 1899-12-30; text falls back to Y-M-D parsing.
/// Intraday serials are truncated toward the date component (no rounding).
fn parse_quote_date(cell: &CellValue) -> Option<Date> {
    match cell {
        CellValue::Number(n) => SHEETS_EPOCH.checked_add(time::Duration::days(n.floor() as i64)),
        CellValue::Text(s) => Date::parse(s.trim(), &ISO_YMD)
            .ok()
            .or_else(|| Date::parse(s.trim(), &US_MDY).ok()),
        _ => None,
    }
}
```

Interpretation chosen: "stamp" = set the cached mark's `as_of` provenance field; the requirement is a *source* constraint (oracle date, never `now()`), so the function takes no clock at all — unstampable rows fail rather than silently defaulting, because a wall-clock fallback would violate the requirement it exists to satisfy.

Assumptions invented:
1. `Cents` is an existing kernel integer money type; parsing price text to Cents happens upstream.
2. A `CellValue` enum (Number/Text/Error/Empty) models raw sheet cells; `to_raw_string()` exists for diagnostics.
3. GOOGLEFINANCE exposes a quote date via a companion attribute column adjacent to the price column; the sheet template guarantees the pair.
4. Date-only granularity (`Date`, not `OffsetDateTime`) — GOOGLEFINANCE daily quotes carry a date; intraday timestamps are truncated to their date.
5. Sheets serial epoch is 1899-12-30; serials arrive as f64.
6. Two text formats accepted: ISO `YYYY-MM-DD` and US `M/D/YYYY` (locale-dependent sheet rendering).
7. Missing or unparseable quote date → error, not a cached mark; the settle pass drops/reports that symbol rather than caching a wall-clock-stamped one.
8. `#N/A`/`Loading...` cells surface as `CellValue::Error`/`Text` and hit the same error path.
9. Negative or absurd serials are not range-validated beyond `checked_add` overflow.
10. Staleness policy (how old an `as_of` may be before rejection) is out of scope for this EARS.
11. Timezone/exchange-locale reconciliation is out of scope; the oracle's date is taken as authoritative verbatim.