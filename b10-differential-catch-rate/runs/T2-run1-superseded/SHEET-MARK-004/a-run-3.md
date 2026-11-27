```rust
use chrono::NaiveDate;

/// Raw read-back of the two cells the mark formula pair exposes per row:
/// the resolved price, and the quote date GOOGLEFINANCE attached to it
/// (via a historical-range formula whose last row is `(date, close)`,
/// since single-value live GOOGLEFINANCE has no date attribute).
pub struct RawMarkRow {
    pub price_cell: String,
    pub quote_date_cell: String,
}

/// A settled, cached mark. `quote_date` is GOOGLEFINANCE's own quote date —
/// never the wall-clock moment the sheets-view crate happened to read it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CachedMark {
    pub cents: i64,
    pub quote_date: NaiveDate,
}

#[derive(Debug)]
pub enum MarkSettleError {
    MissingPrice,
    MissingQuoteDate,
    UnparseablePrice(String),
    UnparseableQuoteDate(String),
}

/// Settle one read-back row into a cached mark. On any missing/unparseable
/// input this returns an error rather than falling back to `Utc::now()` —
/// silently substituting read time would directly violate SHEET-MARK-004.
pub fn settle_mark(row: &RawMarkRow) -> Result<CachedMark, MarkSettleError> {
    if row.price_cell.trim().is_empty() {
        return Err(MarkSettleError::MissingPrice);
    }
    if row.quote_date_cell.trim().is_empty() {
        return Err(MarkSettleError::MissingQuoteDate);
    }
    let price: f64 = row.price_cell.trim().parse()
        .map_err(|_| MarkSettleError::UnparseablePrice(row.price_cell.clone()))?;
    let cents = (price * 100.0).round() as i64;

    let quote_date = parse_sheet_date(&row.quote_date_cell)
        .ok_or_else(|| MarkSettleError::UnparseableQuoteDate(row.quote_date_cell.clone()))?;

    Ok(CachedMark { cents, quote_date })
}

fn parse_sheet_date(raw: &str) -> Option<NaiveDate> {
    if let Ok(d) = NaiveDate::parse_from_str(raw.trim(), "%Y-%m-%d") {
        return Some(d);
    }
    // Sheets numeric serial date, epoch 1899-12-30.
    let serial: f64 = raw.trim().parse().ok()?;
    NaiveDate::from_ymd_opt(1899, 12, 30)?
        .checked_add_signed(chrono::Duration::days(serial.trunc() as i64))
}
```

Assumptions:
1. Live GOOGLEFINANCE("price") alone has no date attribute, so the sheet is assumed to pair it with a historical-range formula (`GOOGLEFINANCE(ticker,"close",TODAY()-N,TODAY())`) whose last row supplies quote date — this is the only way to get a genuine quote date, not wall-clock, from this function.
2. Cell values arrive as raw strings (Sheets API text), requiring parse rather than native numeric/date types.
3. `quote_date` is date-only (`NaiveDate`); spec says "date," not timestamp, so no time-of-day or timezone handling.
4. Cents computed via round-half-away-from-zero on `price * 100.0`.
5. Sheets numeric serial dates (epoch 1899-12-30) are supported as a fallback parse alongside ISO `YYYY-MM-DD`.
6. Missing/empty or unparseable price or date cells produce a typed error, never a silent default — in particular never a fallback to `Utc::now()`, since that would defeat the requirement.
7. GOOGLEFINANCE error strings (`#N/A`, `#ERROR!`) are not special-cased; they simply fail float/date parsing and surface as `Unparseable*`.
8. Caching/persistence of `CachedMark` and retry-on-error policy are out of scope — this module only performs the stamp-with-quote-date settle step.