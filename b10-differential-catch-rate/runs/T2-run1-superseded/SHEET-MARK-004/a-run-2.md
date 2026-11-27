```rust
use chrono::{Duration, NaiveDate};

/// Raw cell contents as read back from the sheet after GOOGLEFINANCE settles.
/// Assumption: the tab carries a GOOGLEFINANCE(ticker,"price") column paired
/// with a GOOGLEFINANCE(ticker,"closeyesterday")/"date"-style helper column
/// (or an explicit ="date" attribute cell) so the quote date is readable
/// independently of the price cell.
pub enum CellValue {
    Number(f64),
    Text(String),
    Empty,
}

pub struct SheetQuoteRow {
    pub symbol: String,
    pub quote_date_cell: CellValue,
}

pub struct CachedMark {
    pub symbol: String,
    pub price_cents: i64,
    /// GOOGLEFINANCE's own quote date — never the wall-clock read time.
    pub quote_date: NaiveDate,
}

#[derive(Debug)]
pub enum MarkReadError {
    MissingQuoteDate { symbol: String },
    UnparseableQuoteDate { symbol: String },
}

pub fn build_cached_mark(
    row: &SheetQuoteRow,
    price_cents: i64,
) -> Result<CachedMark, MarkReadError> {
    let quote_date = parse_quote_date(&row.quote_date_cell).ok_or_else(|| {
        match row.quote_date_cell {
            CellValue::Empty => MarkReadError::MissingQuoteDate { symbol: row.symbol.clone() },
            _ => MarkReadError::UnparseableQuoteDate { symbol: row.symbol.clone() },
        }
    })?;
    Ok(CachedMark { symbol: row.symbol.clone(), price_cents, quote_date })
}

fn parse_quote_date(cell: &CellValue) -> Option<NaiveDate> {
    match cell {
        CellValue::Empty => None,
        // Sheets serial dates: days since 1899-12-30.
        CellValue::Number(serial) => NaiveDate::from_ymd_opt(1899, 12, 30)?
            .checked_add_signed(Duration::days(serial.trunc() as i64)),
        CellValue::Text(s) => NaiveDate::parse_from_str(s, "%Y-%m-%d")
            .or_else(|_| NaiveDate::parse_from_str(s, "%m/%d/%Y"))
            .ok(),
    }
}
```

Assumptions:
1. "Quote date" is sourced from a dedicated GOOGLEFINANCE attribute/date cell in the tab, not derived from the price cell itself — GOOGLEFINANCE("price") alone carries no date, so a paired date-attribute column is required to satisfy this spec at all.
2. Sheet cells arrive as one of `Number` (Google Sheets serial date) or `Text` (formatted date string); `Empty` models a not-yet-settled or blank cell.
3. Serial-date conversion uses the standard Sheets epoch (1899-12-30); only the integer day component is kept (time-of-day, if any, is dropped) since a Cents ledger only needs a date, not a timestamp.
4. Text dates are tried against ISO (`%Y-%m-%d`) then US (`%m/%d/%Y`) formats as the two plausible Sheets locale outputs; no other formats assumed.
5. **Interpretation of ambiguity**: "shall stamp... not wall-clock" is read as a hard prohibition — on missing/unparseable quote date, the function returns `Err` rather than silently falling back to `Utc::now()`/`SystemTime::now()`, since any such fallback would violate the requirement outright. No default date is fabricated.
6. Out-of-range/garbage numeric serials (e.g., negative) are treated as unparseable via `checked_add_signed`/`from_ymd_opt` returning `None`, surfaced as `UnparseableQuoteDate`.
7. `price_cents` is passed in already parsed/validated by a separate concern (price parsing is out of scope for this date-stamping requirement).