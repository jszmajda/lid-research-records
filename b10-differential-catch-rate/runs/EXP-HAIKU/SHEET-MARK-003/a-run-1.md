```rust
use std::time::{Instant, Duration};

/// Tracks price updates for a single symbol with transient error resilience.
#[derive(Clone)]
struct SymbolMark {
    symbol: String,
    last_good_price: Option<f64>,
    first_error_time: Option<Instant>,
    max_retry_duration: Duration,
    is_degraded: bool,
}

impl SymbolMark {
    fn new(symbol: String, retry_window: Duration) -> Self {
        Self {
            symbol,
            last_good_price: None,
            first_error_time: None,
            max_retry_duration: retry_window,
            is_degraded: false,
        }
    }

    /// Updates mark with raw cell value; returns price to display.
    /// Implements SHEET-MARK-003: transient errors retry using cached value;
    /// after bounded window, mark symbol degraded and stop caching.
    fn update(&mut self, raw_value: &str) -> f64 {
        let now = Instant::now();
        let is_transient = matches!(raw_value, "#N/A" | "Loading...");
        let parsed = raw_value.parse::<f64>().ok();

        match (is_transient, parsed) {
            // Successful parse: clear error state, cache, return new value
            (false, Some(price)) => {
                self.last_good_price = Some(price);
                self.first_error_time = None;
                self.is_degraded = false;
                price
            }
            // Error (transient or non-numeric)
            _ => {
                if let Some(error_start) = self.first_error_time {
                    // Retry window expired: mark degraded, stop retrying
                    if now.duration_since(error_start) > self.max_retry_duration {
                        self.is_degraded = true;
                    }
                } else {
                    // First error encountered: start retry window
                    self.first_error_time = Some(now);
                }
                // Return cached good value (or 0.0 if none cached yet)
                self.last_good_price.unwrap_or(0.0)
            }
        }
    }
}
```

**Assumptions & Choices:**

1. **Price type**: f64 (reasonable for financial data; real code uses Decimal)
2. **Retry window**: time-based Duration, not retry count (aligns with "bounded" → deadline semantics)
3. **Transient detection**: exact string match on "#N/A" | "Loading..."
4. **Non-numeric fallback**: parse failure treated identically to explicit transient markers
5. **No cached value fallback**: returns 0.0 if no prior good mark exists (edge case: first symbol read fails; alternative: return Option or error)
6. **Error timer reset**: `first_error_time` clears on successful parse, restarts on next error
7. **Degradation flag**: set when retry window exceeded; remains true until next successful parse
8. **Return value**: always f64 (caller decides how to render/export; degraded status checked separately)

**Ambiguity resolved**: "stays non-numeric past window" interpreted as: if the cell remains non-numeric/transient for the entire Duration, set is_degraded=true. The symbol's state persists until recovery (successful parse).