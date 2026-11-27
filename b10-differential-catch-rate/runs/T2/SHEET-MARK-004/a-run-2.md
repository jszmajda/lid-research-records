```rust
use chrono::NaiveDate;

/// Cents newtype per project convention (kernel's money type).
pub struct Cents(pub i64);

/// A price mark cached from a GOOGLEFINANCE-backed sheet cell during the
/// marks read-back settle pass.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CachedMark {
    pub symbol: String,
    pub price: Cents,
    /// GOOGLEFINANCE's own quote date — never the moment we performed the read.
    pub quote_date: NaiveDate,
}

/// Raw strings read back from the sheet for one symbol's row.
pub struct SheetMarkRow {
    pub symbol: String,
    pub price_cell: String,
    /// Text of the companion cell holding `=GOOGLEFINANCE(ticker,"tradetime")`
    /// (or equivalent date-attribute formula) alongside the price cell.
    pub quote_date_cell: String,
}

#[derive(Debug)]
pub enum MarkStampError {
    MissingQuoteDate,
    InvalidQuoteDate(String),
    InvalidPrice(String),
}

/// Implements SHEET-MARK-004: stamps a mark with the quote date GOOGLEFINANCE
/// reports, sourced from the sheet cell text — deliberately never from
/// `Utc::now()` or any local clock, including on parse failure.
pub fn stamp_mark(row: &SheetMarkRow) -> Result<CachedMark, MarkStampError> {
    let raw = row.quote_date_cell.trim();
    if raw.is_empty() {
        return Err(MarkStampError::MissingQuoteDate);
    }
    let quote_date = NaiveDate::parse_from_str(raw, "%m/%d/%Y")
        .map_err(|_| MarkStampError::InvalidQuoteDate(raw.to_string()))?;

    let price = row.price_cell.trim().parse::<f64>()
        .map(|f| Cents((f * 100.0).round() as i64))
        .map_err(|_| MarkStampError::InvalidPrice(row.price_cell.clone()))?;

    Ok(CachedMark { symbol: row.symbol.clone(), price, quote_date })
}
```

Assumptions:
1. "Quote date" is a calendar date only (`NaiveDate`), not a timestamp — GOOGLEFINANCE's date-bearing attributes (e.g. `"tradetime"`/`"all"`) return a date, not necessarily intraday time.
2. The quote date arrives as a separate cell/column produced by its own GOOGLEFINANCE formula call, since the plain `"price"` attribute returns no date; the sheets-view layer is assumed to already read both cells back as raw strings before calling this function.
3. Date cell format assumed `%m/%d/%Y` (typical US-locale Sheets serialization) — real format is locale-dependent and would need confirming against the actual workbook locale.
4. Ambiguity resolution: "not the wall-clock read time" is read as an absolute prohibition, so missing/unparseable quote-date cells return an error rather than silently falling back to `Utc::now()` — no fallback path exists in this sketch.
5. Price parsing/`Cents` conversion is included only for row completeness; it is out of scope for SHEET-MARK-004 itself and not the focus of correctness here.
6. This function is a pure stamping step — actual sheet I/O, caching/storage of `CachedMark`, and the surrounding settle-pass orchestration are assumed to live elsewhere in the sheets-view crate.
7. No accounting/tax logic appears here, consistent with sheets-view owning none.