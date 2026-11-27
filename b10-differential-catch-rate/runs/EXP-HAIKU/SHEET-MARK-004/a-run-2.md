```rust
use chrono::{DateTime, Utc};

/// A market price quote stamped with GOOGLEFINANCE's reported quote date.
#[derive(Debug, Clone)]
pub struct CachedMark {
    /// Price in cents (integer)
    price_cents: i64,
    /// Quote date from GOOGLEFINANCE response, NOT system time
    quote_date: DateTime<Utc>,
}

impl CachedMark {
    /// Build a cached mark from GOOGLEFINANCE response data.
    /// Extracts quote_date from the response; ignores wall-clock time.
    pub fn from_googlefinance_response(
        price: f64,
        quote_date_str: &str,
    ) -> Result<Self, String> {
        let price_cents = (price * 100.0).round() as i64;
        let quote_date = parse_googlefinance_quote_date(quote_date_str)?;
        
        Ok(CachedMark {
            price_cents,
            quote_date,
        })
    }
    
    pub fn price_cents(&self) -> i64 {
        self.price_cents
    }
    
    pub fn quote_date(&self) -> DateTime<Utc> {
        self.quote_date
    }
}

/// Parse GOOGLEFINANCE's quote date field.
/// Handles ISO8601 (preferred) and date-only fallback.
fn parse_googlefinance_quote_date(s: &str) -> Result<DateTime<Utc>, String> {
    // Attempt RFC3339 (ISO8601 with timezone)
    DateTime::parse_from_rfc3339(s)
        .map(|dt| dt.with_timezone(&Utc))
        .or_else(|_| {
            // Fallback: date-only (YYYY-MM-DD) → midnight UTC
            chrono::NaiveDate::parse_from_str(s, "%Y-%m-%d")
                .map(|d| d.and_hms_opt(0, 0, 0).unwrap().and_utc())
                .map_err(|e| format!("Invalid quote_date format: {}", e))
        })
}
```

**Assumptions:**

1. **Mark definition**: A `CachedMark` pairs price (as integer cents per project) with its quote date.
2. **GOOGLEFINANCE response structure**: Caller extracts `price` and `quote_date_str` fields from the GOOGLEFINANCE result; I don't parse the Sheets API response itself (that's upstream).
3. **Quote date format**: GOOGLEFINANCE provides date as ISO8601 (preferred) or `YYYY-MM-DD` string; not parsed from timestamps in the cached row.
4. **Timezone default**: Date-only input → midnight UTC (no intraday granularity assumed for fallback path).
5. **Price conversion**: Float to cents via `round()` (no banker's rounding; assumes prices are well-formed non-negative decimals).
6. **No wall-clock**: Constructor takes quote date as parameter only; never calls `Utc::now()`.
7. **Error handling**: Parse failures return `Err`; caller decides whether to skip, retry, or use stale cached mark.
8. **Interpretation**: "Stamp" means store the quote date *with* the mark in a struct, not emit it as a side effect.