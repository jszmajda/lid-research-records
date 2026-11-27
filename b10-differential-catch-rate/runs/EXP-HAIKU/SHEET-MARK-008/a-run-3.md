```rust
/// SHEET-MARK-008: Quote Date column formula generator and parser
/// Renders a locale-proof integer date encoding (days since Unix epoch)
/// from GOOGLEFINANCE data, empty during load/error states.

const UNIX_EPOCH_DAYS_OFFSET: i32 = 25567; // DATE(1970,1,1) in Google Sheets serial date

/// Generates the Google Sheets formula for the Quote Date column.
/// Encodes the GOOGLEFINANCE quote-capture date as days since 1970-01-01 in TEXT format.
///
/// # Returns
/// A formula string safe for direct insertion into a Positions sheet cell.
///
/// # Formula Logic
/// - IFERROR: wraps to return "" if GOOGLEFINANCE fails or sheet is loading
/// - TEXT: formats the day count as a string (locale-proof integer)
/// - DATEVALUE: ensures date is a serial number
/// - TODAY(): captures quote-fetch epoch (treated as quote date since GOOGLEFINANCE
///   does not expose raw trade-time; settle pass assumes fetch ≈ quote moment)
/// - Subtraction: days since 1970-01-01 (DATE(1970,1,1) is serial 25567)
pub fn generate_quote_date_formula() -> String {
    "=IFERROR(TEXT(DATEVALUE(TODAY())-DATE(1970,1,1),\"0\"),\"\")".to_string()
}

/// Parses a Quote Date cell value read back from the Positions tab.
/// Converts the integer day-count string to a chrono::NaiveDate.
///
/// # Arguments
/// - `text`: The cell value (empty string if loading/error, else numeric string)
///
/// # Returns
/// - `Some(NaiveDate)` if text is a valid integer ≥0
/// - `None` if text is empty (loading/error state) or unparseable
///
/// # Panics
/// None; invalid input yields None.
pub fn parse_quote_date(text: &str) -> Option<chrono::NaiveDate> {
    use chrono::NaiveDate;
    
    if text.is_empty() {
        return None; // loading or error state
    }
    
    text.trim()
        .parse::<i64>()
        .ok()
        .and_then(|days| {
            // Unix epoch is 1970-01-01; reconstruct from day offset
            NaiveDate::from_ymd_opt(1970, 1, 1)
                .and_then(|epoch| epoch.checked_add_signed(chrono::Duration::days(days)))
        })
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_formula_generation() {
        let formula = generate_quote_date_formula();
        assert!(formula.contains("TODAY()"));
        assert!(formula.contains("DATE(1970,1,1)"));
        assert!(formula.contains("TEXT("));
        assert!(formula.contains("IFERROR"));
    }
    
    #[test]
    fn test_parse_empty_loads_as_none() {
        assert_eq!(parse_quote_date(""), None);
        assert_eq!(parse_quote_date("   "), None);
    }
    
    #[test]
    fn test_parse_valid_epoch_day() {
        // 1970-01-01 = day 0
        assert_eq!(parse_quote_date("0"), chrono::NaiveDate::from_ymd_opt(1970, 1, 1));
        // 1970-01-02 = day 1
        assert_eq!(parse_quote_date("1"), chrono::NaiveDate::from_ymd_opt(1970, 1, 2));
    }
}
```

---

**Assumptions Invented:**

1. **TODAY() as quote-capture proxy**: GOOGLEFINANCE in Google Sheets does not expose a raw `tradeDate` attribute; assumed TODAY() represents the settlement-date assumption (quote is "as of today"). Alternative: GOOGLEFINANCE might support a hidden `date` attribute; if so, formula becomes `TEXT(DATEVALUE(GOOGLEFINANCE(symbol,"date"))-DATE(1970,1,1),"0")`.

2. **Type: `i64` for day count**: Accommodated dates beyond 2038 (32-bit limit); Rust `chrono::Duration::days()` requires `i64`.

3. **No symbol parameter in formula**: Formula is static per column; assumed symbol comes from a sibling column or row reference (e.g., `GOOGLEFINANCE(B2,"price")`), not injected into Quote Date itself.

4. **Empty string = loading/error**: Sheets cells remain empty until formula resolves; settle pass treats empty as "skip this row" rather than a parsing error.

5. **No leap-second handling**: Date arithmetic uses calendar days; no accounting for leap seconds.

6. **Ambiguity resolved: "trade date" → "quote-fetch date"**: GOOGLEFINANCE price is point-in-time; chose TODAY() as the canonical "quote happened now" marker for settle pass alignment. If historical trade dates are needed, require a separate input (date picker or parameter).