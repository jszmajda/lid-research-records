```rust
/// Generates the Quote Date formula placed in a Positions tab cell
fn quote_date_formula(symbol: &str) -> String {
    format!(
        r#"=IFERROR(TEXT(GOOGLEFINANCE("{}","date")-DATE(1970,1,1),"0"),"")"#,
        symbol
    )
}

/// Parses the integer epoch-days value read back during the settle pass
fn parse_quote_epoch_days(cell_value: &str) -> Option<i32> {
    let trimmed = cell_value.trim();
    if trimmed.is_empty() {
        None // Loading or error state
    } else {
        trimmed.parse::<i32>().ok()
    }
}

/// Holds the parsed quote-epoch result for one symbol from settle pass
#[derive(Debug, Clone)]
pub struct SymbolQuoteEpoch {
    pub symbol: String,
    pub days_since_epoch: Option<i32>, // None if loading/errored
}

impl SymbolQuoteEpoch {
    /// Parse a Quote Date cell value from the settle pass read-back
    pub fn from_settle_cell(symbol: String, cell_value: &str) -> Self {
        Self {
            symbol,
            days_since_epoch: parse_quote_epoch_days(cell_value),
        }
    }

    /// Convert epoch days back to a date if available (for logging/validation)
    pub fn to_trade_date(&self) -> Option<chrono::NaiveDate> {
        self.days_since_epoch.and_then(|days| {
            chrono::NaiveDate::from_ymd_opt(1970, 1, 1)
                .and_then(|epoch| epoch.checked_add_signed(
                    chrono::Duration::days(days as i64)
                ))
        })
    }
}
```

**Assumptions:**

1. **Formula interpretation**: `GOOGLEFINANCE("SYMBOL","date")` returns the trade date as a serial number; subtracting `DATE(1970,1,1)` yields integer days.
2. **Type bounds**: Days fit in `i32` (~5,900 years from epoch); no overflow expected in practice.
3. **Error handling**: GOOGLEFINANCE errors (invalid symbol, network failure, rate limit) trigger IFERROR→empty string; empty cell means not yet loaded or errored.
4. **TEXT format**: Format code `"0"` renders as plain integer without decimals or locale markup (e.g., no thousands separator).
5. **Settle pass timing**: Runs after Google Sheets finishes recalculation (all GOOGLEFINANCE calls resolved).
6. **Input whitespace**: Cell values may have trailing spaces; `trim()` is defensive.
7. **Parse failure**: Non-numeric non-empty strings parse as `None` (malformed sheet state, treated as error).
8. **Chrono integration** (optional): `to_trade_date()` reconstructs the naive date for logging; `chrono` dependency assumed available.
9. **Symbol validation**: Caller ensures symbols are valid for GOOGLEFINANCE (e.g., ticker:exchange format); no validation here.
10. **Locale independence**: Google Sheets formulas with serial arithmetic and TEXT("0") format are locale-proof by design; no parsing of date strings needed.