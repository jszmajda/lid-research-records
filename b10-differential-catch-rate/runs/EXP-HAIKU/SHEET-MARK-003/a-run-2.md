```rust
use std::time::{Instant, Duration};

#[derive(Debug, Clone, Copy, PartialEq)]
enum PriceValue {
    Valid(f64),
    Transient, // #N/A or Loading...
}

/// Tracks a single symbol's price mark through transient states.
struct SymbolMark {
    symbol: String,
    cached_good_price: Option<f64>,
    transient_started_at: Option<Instant>,
    retry_window: Duration,
    degraded: bool,
}

impl SymbolMark {
    fn new(symbol: String, retry_window_secs: u64) -> Self {
        Self {
            symbol,
            cached_good_price: None,
            transient_started_at: None,
            retry_window: Duration::from_secs(retry_window_secs),
            degraded: false,
        }
    }

    /// Updates price and returns the mark to publish (None if degraded).
    fn update(&mut self, price: PriceValue) -> Option<f64> {
        match price {
            PriceValue::Valid(v) => {
                // Valid numeric price: cache it, clear transience timer, mark healthy
                self.cached_good_price = Some(v);
                self.transient_started_at = None;
                self.degraded = false;
                Some(v)
            }
            PriceValue::Transient => {
                // #N/A or Loading: start retry window if not already tracking
                if self.transient_started_at.is_none() {
                    self.transient_started_at = Some(Instant::now());
                }

                // Check if retry window exceeded
                if let Some(start) = self.transient_started_at {
                    if start.elapsed() > self.retry_window {
                        // Bounded window expired: mark degraded, return None
                        self.degraded = true;
                        return None;
                    }
                }

                // Still within retry window: return cached good price
                self.cached_good_price
            }
        }
    }

    fn is_degraded(&self) -> bool {
        self.degraded
    }
}
```

**Assumptions & Interpretation:**

1. **Type shapes**: `PriceValue::Valid(f64)` for numeric prices; `Transient` state unifies `#N/A` and `Loading...`. Marks are `Option<f64>` — `Some(price)` is good, `None` means degraded/no mark.

2. **Retry window**: Fixed bounded duration (default: constructor takes seconds). Starts when first transient observed; resets on valid price.

3. **"Stays non-numeric"**: Interpreted as "remains in `Transient` state for duration > retry_window." Once window expires, symbol is marked `degraded=true` and returns `None`.

4. **"Keep prior good cached mark"**: While transient and within window, `update()` returns `cached_good_price` (prior numeric value or `None` if never seen valid).

5. **"Recording the symbol degraded"**: The `degraded` flag persists; `is_degraded()` query returns it. Sheets column publishes `None` (renders blank or custom degraded marker).

6. **Cache persistence**: Cached good price persists across transients; only clears on next valid observation. Allows recovery if transience clears before window expires.

7. **Ambiguity resolved**: "Retry" implies timer-based polling (not active retry count), chosen for bounded-window reading. Window doesn't reset on each transient tick—only on valid price or at first transient observation.