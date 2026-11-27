```rust
pub type Cents = i64;

#[derive(Debug, Clone, Copy)]
pub enum PriceToCentsError {
    /// Positive price rounded to zero cents (degraded anomaly)
    DegradedAnomaly,
}

pub fn price_to_cents(price: f64) -> Result<Cents, PriceToCentsError> {
    let cents_float = price * 100.0;
    let cents_rounded = round_half_to_even(cents_float);
    
    // Positive price that rounds to zero is a degraded anomaly
    if price > 0.0 && cents_rounded == 0.0 {
        Err(PriceToCentsError::DegradedAnomaly)
    } else {
        Ok(cents_rounded as Cents)
    }
}

/// Implements banker's rounding (round half to even).
fn round_half_to_even(x: f64) -> f64 {
    let floor = x.floor();
    let frac = x - floor;
    
    match frac {
        f if f < 0.5 => floor,
        f if f > 0.5 => floor + 1.0,
        _ => {
            // Exactly 0.5: round to nearest even
            if (floor as i64) % 2 == 0 { floor } else { floor + 1.0 }
        }
    }
}
```

**Assumptions:**

1. **Input type**: f64 (standard Rust float for currency calculations)
2. **Cents type**: i64 (sufficient range for accounting; represents ±9.2 quintillion)
3. **"Positive price"**: strict inequality (price > 0.0); zero is not positive
4. **Rounding**: Banker's rounding applied to `price × 100` scaled value
5. **Anomaly representation**: `Err` variant forces caller to distinguish from normal zero
6. **"Recorded"**: returns error; caller decides logging/alerting mechanism
7. **Invalid inputs**: NaN, Infinity, negative prices unchecked; caller validates
8. **Precision**: No assumed decimal-place limit on input
9. **Normal zero**: Price exactly 0.0 returns `Ok(0)`, not anomaly
10. **Cast safety**: Assumes rounded value fits i64 (true for USD/cents scales)

**Interpretation**: "recorded as a degraded anomaly, not a zero mark" → Returns `Result::Err`, not `Ok(0)`. This prevents the anomaly signal from collapsing into a silent zero that indistinguishable from legitimate zero prices. Caller must pattern-match or map the error, ensuring the anomaly is explicitly acknowledged.