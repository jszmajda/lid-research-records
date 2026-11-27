```rust
use chrono::{DateTime, NaiveDate, Utc};
use serde::Deserialize;

/// A cached market quote with its authoritative source timestamp
#[derive(Debug, Clone)]
pub struct Mark {
    pub ticker: String,
    pub price_cents: i64,
    /// Timestamp from GOOGLEFINANCE response, not system wall-clock
    pub quote_date: DateTime<Utc>,
}

/// Subset of GOOGLEFINANCE response containing quote data
#[derive(Debug, Deserialize)]
pub struct GoogleFinanceQuote {
    pub price: f64,
    /// Date from GOOGLEFINANCE (assumed "YYYY-MM-DD" or ISO 8601)
    pub date: String,
}

/// Stamp a cached mark using GOOGLEFINANCE's quote date, not current time
pub fn stamp_mark_from_gf(
    ticker: &str,
    quote: GoogleFinanceQuote,
) -> Result<Mark, MarkError> {
    let quote_date = parse_gf_date(&quote.date)?;
    let price_cents = (quote.price * 100.0).round() as i64;

    if price_cents <= 0 {
        return Err(MarkError::InvalidPrice(price_cents));
    }

    Ok(Mark {
        ticker: ticker.to_string(),
        price_cents,
        quote_date,
    })
}

fn parse_gf_date(date_str: &str) -> Result<DateTime<Utc>, MarkError> {
    // Try RFC 3339 (full timestamp with time component)
    if let Ok(dt) = DateTime::parse_from_rfc3339(date_str) {
        return Ok(dt.with_timezone(&Utc));
    }

    // Fallback: parse date-only format, assume market close (4 PM ET / 20:00 UTC)
    let naive_date = NaiveDate::parse_from_str(date_str, "%Y-%m-%d")
        .map_err(|_| MarkError::DateParse(date_str.to_string()))?;
    
    let naive_dt = naive_date
        .and_hms_opt(20, 0, 0)
        .ok_or(MarkError::InvalidDateTime)?;
    
    Ok(DateTime::<Utc>::from_naive_utc_and_offset(naive_dt, Utc))
}

#[derive(Debug)]
pub enum MarkError {
    DateParse(String),
    InvalidDateTime,
    InvalidPrice(i64),
}
```

**Assumptions:**

1. **GOOGLEFINANCE date format**: Returns either RFC 3339 (ISO 8601 with time) or "YYYY-MM-DD" (date-only). If date-only, I assume market close time (20:00 UTC / 4 PM ET) as canonical quote reference.

2. **Timezone**: All marks stored as UTC internally. Assumption: GOOGLEFINANCE quotes are in US/Eastern; canonical conversion is 4 PM ET = 20:00 UTC.

3. **Price conversion**: Float dollars → integer cents via rounding. Assumes rounding acceptable (not banker's); no input validation beyond sign/zero check.

4. **Error handling**: Fails loudly if date is unparseable or price invalid. No fallback to `now()`—strict adherence to "use GOOGLEFINANCE date only."

5. **Ambiguity resolution**: "GOOGLEFINANCE's quote date" interpreted as a date/timestamp field *within* the response payload, not the HTTP response header timestamp. This preserves data fidelity (the quote may be hours old) and aligns with the system's role as a read-back settle pass over cached marks.