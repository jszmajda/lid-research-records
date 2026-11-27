```rust
/// Generates the Quote Date column formula for Google Sheets Positions tab.
/// 
/// Formula encodes GOOGLEFINANCE's trade date as days since 1970-01-01 (Unix epoch),
/// TEXT-formatted as a locale-proof string integer, empty while loading/errored.
fn quote_date_formula(symbol_cell_ref: &str) -> String {
    format!(
        r#"=IFERROR(TEXT(DAYS(GOOGLEFINANCE({}, "price"), DATE(1970, 1, 1)), "0"), "")"#,
        symbol_cell_ref
    )
}

/// Parses quote date value read back from Positions tab in settle pass.
/// Returns Some(days_since_epoch) for valid values; None for empty/loading state.
fn parse_quote_date(cell_value: &str) -> Option<i32> {
    let trimmed = cell_value.trim();
    if trimmed.is_empty() {
        None // Still loading or GOOGLEFINANCE failed
    } else {
        trimmed.parse::<i32>().ok()
    }
}

/// Settle pass structure: parses per-symbol quote-epoch stamps from readback.
struct QuoteEpochRecord {
    symbol: String,
    quote_date_days: i32,
}

impl QuoteEpochRecord {
    fn from_sheet_row(symbol: String, quote_date_str: &str) -> Result<Self, String> {
        let quote_date_days = parse_quote_date(quote_date_str)
            .ok_or_else(|| format!("Quote date not ready for {}", symbol))?;
        Ok(QuoteEpochRecord {
            symbol,
            quote_date_days,
        })
    }
}
```

**ASSUMPTIONS:**

1. `GOOGLEFINANCE(symbol, "price")` in Google Sheets returns a numeric value (price or date metadata accessible internally)
2. `DAYS(date1, date2)` returns integer day count; Google Sheets dates are serial numbers (epoch ~1899-12-30)
3. `TEXT(..., "0")` formats integers as strings without locale-specific separators (canonical assumption: US locale baseline, overridable in sheet)
4. Empty string signals loading/error state per spec; no attempt to distinguish cause
5. Symbol cell reference is externally validated (e.g., "A2", "B2"); no validation in formula
6. Integer overflow impossible within realistic date ranges (i32 sufficient for ±292M years from epoch)
7. Settle pass reads sheet values as strings; "not ready" ≡ `""`, "ready" ≡ valid i32 parseable string
8. GOOGLEFINANCE query succeeds for stock symbols (failure → empty → parse returns None → settle rejects row)
9. No timezone handling needed (days since epoch is date-only, not time-aware)
10. Interpretation choice: "GOOGLEFINANCE's trade date" assumed as the quote refresh date returned by the API, not a user-specified date parameter

**Ambiguity resolved:** GOOGLEFINANCE doesn't expose "trade date" as a direct attribute in public API; assumption made that either (a) metadata is embedded in response, or (b) "trade date" means "price-quote fetch date" (current/most-recent). Formula treats as opaque numeric date value; exact attribute parameter may need adjustment per actual GOOGLEFINANCE API surface.