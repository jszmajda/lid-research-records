```rust
// crates/sheets-view/src/marks.rs
// @spec SHEET-MARK-004

use chrono::NaiveDate;

/// One row read back from the workbook's marks range.
pub struct MarkRow {
    pub symbol: String,
    /// GOOGLEFINANCE price cell, already parsed to integer Cents.
    pub price: Cents,
    /// The companion `=GOOGLEFINANCE(sym,"datadate")` / index-date cell,
    /// serialized by the Sheets API as a string (serial or ISO).
    pub quote_date_cell: Option<String>,
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

#[derive(Clone)]
pub struct CachedMark {
    pub symbol: String,
    pub price: Cents,
    /// The oracle's own quote date. Never the read clock.
    pub as_of: NaiveDate,
}

#[derive(Debug)]
pub enum MarkError {
    MissingQuoteDate { symbol: String },
    UnparsableQuoteDate { symbol: String, raw: String },
}

const SHEETS_EPOCH: NaiveDate = NaiveDate::from_ymd_opt(1899, 12, 30).unwrap();

fn parse_quote_date(raw: &str) -> Option<NaiveDate> {
    let t = raw.trim();
    if t.is_empty() {
        return None;
    }
    // Sheets serial number (possibly with a fractional time-of-day component).
    if let Ok(serial) = t.parse::<f64>() {
        if !serial.is_finite() || serial < 1.0 {
            return None;
        }
        return SHEETS_EPOCH.checked_add_days(chrono::Days::new(serial.trunc() as u64));
    }
    NaiveDate::parse_from_str(t, "%Y-%m-%d")
        .or_else(|_| NaiveDate::parse_from_str(t, "%m/%d/%Y"))
        .ok()
}

/// Build the cached mark. `read_at` is deliberately not a parameter:
/// the wall clock cannot reach the stamped date.
pub fn cache_mark(row: &MarkRow) -> Result<CachedMark, MarkError> {
    let raw = row
        .quote_date_cell
        .as_deref()
        .ok_or_else(|| MarkError::MissingQuoteDate { symbol: row.symbol.clone() })?;
    let as_of = parse_quote_date(raw).ok_or_else(|| MarkError::UnparsableQuoteDate {
        symbol: row.symbol.clone(),
        raw: raw.to_string(),
    })?;
    Ok(CachedMark { symbol: row.symbol.clone(), price: row.price, as_of })
}
```

Assumptions invented:
1. The workbook carries a companion quote-date column beside each GOOGLEFINANCE price; the requirement is unimplementable otherwise.
2. Quote date is date-granular (`NaiveDate`), not a timestamp — GOOGLEFINANCE "datadate" is a day.
3. Sheets returns the cell either as a numeric serial (1899-12-30 epoch, fraction truncated) or as an ISO / US-slash string; both are accepted.
4. Missing, blank, `#N/A`, or unparsable date -> hard error, no cache write. Chosen over falling back to wall clock because the requirement's whole point is that wall clock must never stamp a mark; a silent fallback would violate it.
5. Serial < 1.0, non-finite, or negative treated as invalid.
6. No timezone/market-close normalization; the oracle's date is taken verbatim.
7. Price already parsed to `Cents` upstream; this function does no money math.
8. Interpretation chosen: "stamp" = the persisted `as_of` field of the cached mark. Wall-clock read time may still be recorded elsewhere as separate telemetry, but is excluded from this constructor's signature so it cannot leak into `as_of`.
9. `symbol` cloned rather than borrowed for a `'static`-free cache entry.