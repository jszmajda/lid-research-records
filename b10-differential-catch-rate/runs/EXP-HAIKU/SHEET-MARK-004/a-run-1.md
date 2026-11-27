```rust
use chrono::NaiveDate;
use std::collections::HashMap;

/// A market price mark stamped with GOOGLEFINANCE's quote date, not wall-clock time.
#[derive(Clone, Debug)]
pub struct CachedMark {
    /// Price in integer cents
    pub price_cents: i64,
    /// Quote date from GOOGLEFINANCE response (the authoritative date for this mark)
    pub quote_date: NaiveDate,
}

/// Parsed GOOGLEFINANCE formula cell result
#[derive(Clone, Debug)]
pub struct GoogleFinanceQuote {
    pub price: f64,
    pub quote_date: String, // e.g. "2024-08-01"
}

/// Stamp a GOOGLEFINANCE quote as a cached mark, extracting and storing its quote date.
/// 
/// The quote_date from the GOOGLEFINANCE response becomes the authoritative timestamp,
/// NOT the current system time.
pub fn stamp_cached_mark(quote: &GoogleFinanceQuote) -> Result<CachedMark, String> {
    let price_cents = (quote.price * 100.0).round() as i64;
    
    // Parse GOOGLEFINANCE quote date (ISO-8601 format assumed)
    let quote_date = NaiveDate::parse_from_str(&quote.quote_date, "%Y-%m-%d")
        .map_err(|e| format!("Invalid GOOGLEFINANCE quote date: {}", e))?;
    
    Ok(CachedMark {
        price_cents,
        quote_date,
    })
}

/// In-memory cache keyed by (symbol, quote_date) to deduplicate marks with identical dates.
pub struct MarkCache {
    marks: HashMap<String, HashMap<NaiveDate, CachedMark>>,
}

impl MarkCache {
    pub fn insert(&mut self, symbol: &str, mark: CachedMark) {
        self.marks
            .entry(symbol.to_string())
            .or_insert_with(HashMap::new)
            .insert(mark.quote_date, mark);
    }
    
    /// Retrieve the latest cached mark by quote date (not by insertion time).
    pub fn latest(&self, symbol: &str) -> Option<&CachedMark> {
        self.marks
            .get(symbol)
            .and_then(|by_date| by_date.values().max_by_key(|m| m.quote_date))
    }
}
```

**ASSUMPTIONS (all invented from requirement text alone):**

1. GOOGLEFINANCE quote date is ISO-8601 string (`%Y-%m-%d`); parsing failure is an error
2. Price is float; conversion to integer cents uses `round()` (banker's rounding)
3. NaiveDate used (no timezone); quote dates are market calendar dates, zone-agnostic
4. "Stamp" means embed the quote_date in the CachedMark struct itself, not as a separate log entry
5. Multiple marks per symbol possible (deduped by symbol + quote_date pair)
6. Cache is in-memory HashMap; durability not addressed
7. GOOGLEFINANCE always provides a quote date; no wall-clock fallback if missing
8. "Quote date" is a single date field (not a timestamp with intraday granularity)
9. Price is always valid floating-point; invalid prices are panics, not errors
10. "Latest" mark = maximum by quote_date, independent of when cached

**INTERPRETATION:**
Requirement states "stamp each cached mark with GOOGLEFINANCE's quote date." I interpreted "stamp" as: the CachedMark struct owns the quote_date field sourced from the GOOGLEFINANCE response. The requirement explicitly forbids using wall-clock time—so we extract the date *from the GOOGLEFINANCE cell itself* and store it. This ensures all cached marks are tagged with market-sourced dates, not read times.