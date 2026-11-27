```rust
use std::fmt;

#[derive(Debug)]
pub enum ConversionError {
    DegradedAnomaly { original_price: f64 },
    InvalidPrice { price: f64 },
}

impl fmt::Display for ConversionError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::DegradedAnomaly { original_price } => {
                write!(f, "Degraded anomaly: positive price {} rounds to 0 cents", original_price)
            }
            Self::InvalidPrice { price } => {
                write!(f, "Invalid price: {} (not finite)", price)
            }
        }
    }
}

/// Convert USD price to Cents using banker's rounding (round_half_to_even).
/// Returns error if price is non-finite or a positive price rounds to 0 cents.
pub fn price_to_cents(price: f64) -> Result<i64, ConversionError> {
    if !price.is_finite() {
        return Err(ConversionError::InvalidPrice { price });
    }
    
    // f64::round() implements banker's rounding (round half to even) by default
    let cents = (price * 100.0).round() as i64;
    
    // Anomaly: positive price that rounds to zero cents (precision loss below 1¢)
    if price > 0.0 && cents == 0 {
        return Err(ConversionError::DegradedAnomaly { original_price: price });
    }
    
    Ok(cents)
}
```

**ASSUMPTIONS:**

1. **Input type**: `f64` — standard floating-point USD price representation.
2. **Output type**: `Result<i64, ConversionError>` — `i64` for cents (signed to support negative prices/refunds); `Result` to distinguish anomaly from valid zero.
3. **Banker's rounding**: Rust's `f64::round()` natively implements round-half-to-even; no external crate needed.
4. **"Recorded as anomaly"**: Interpreted as returning `Err(DegradedAnomaly)` rather than `Ok(0)`; caller must handle the error case explicitly.
5. **"Positive price"**: `price > 0.0` strictly; zero and negative prices do not trigger anomaly even if they round to 0 cents.
6. **Invalid inputs**: NaN and infinity rejected as `InvalidPrice` (not silently clamped).
7. **Overflow**: Assumes price × 100 fits in i64 (approximately ±92 quadrillion dollars; reasonable for single holdings).
8. **No subnormal handling**: Prices below 0.005 USD that round to 0 cents are caught by the anomaly check; caller decides whether to reject, retry with higher precision, or log.

**Interpretation choice**: "Degraded anomaly, not a zero mark" means the system must distinguish anomaly cases from legitimate zero-cent positions (e.g., a zero or negative price). A `Result` type enforces this distinction at the type level, preventing accidental silent loss of precision data.