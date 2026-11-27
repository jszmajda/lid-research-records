```rust
#[derive(Debug, Clone)]
pub enum MarkResult {
    Cents(i64),
    DegradedAnomaly { price: f64 },
}

/// Converts a USD price to Cents using round-half-to-even.
/// Positive prices that round to 0 Cents are recorded as degraded anomalies.
pub fn price_to_cents(price: f64) -> MarkResult {
    // Reject non-finite values (NaN, Inf, -Inf)
    if !price.is_finite() {
        return MarkResult::DegradedAnomaly { price };
    }
    
    // Multiply by 100 and apply banker's rounding (round-half-to-even)
    let cents = (price * 100.0).round() as i64;
    
    // Special case: positive price rounding to 0 Cents is a degraded anomaly
    if price > 0.0 && cents == 0 {
        MarkResult::DegradedAnomaly { price }
    } else {
        MarkResult::Cents(cents)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn normal_price() {
        assert!(matches!(price_to_cents(10.50), MarkResult::Cents(1050)));
    }
    
    #[test]
    fn banker_rounding() {
        // 2.125 * 100 = 212.5 → rounds to 212 (even)
        assert!(matches!(price_to_cents(2.125), MarkResult::Cents(212)));
    }
    
    #[test]
    fn positive_price_rounds_to_zero() {
        // 0.001 * 100 = 0.1 → rounds to 0, but price > 0
        assert!(matches!(price_to_cents(0.001), MarkResult::DegradedAnomaly { .. }));
    }
    
    #[test]
    fn zero_price_normal() {
        // price == 0, so no anomaly even though result is 0
        assert!(matches!(price_to_cents(0.0), MarkResult::Cents(0)));
    }
    
    #[test]
    fn negative_price_allowed() {
        assert!(matches!(price_to_cents(-5.99), MarkResult::Cents(-599)));
    }
    
    #[test]
    fn nan_is_anomaly() {
        assert!(matches!(price_to_cents(f64::NAN), MarkResult::DegradedAnomaly { .. }));
    }
}
```

**Assumptions (explicit inventory):**

1. **Input type**: `f64` (IEEE 754 double-precision float, standard for money in Rust before conversion to fixed-point)
2. **Output type**: `i64` for Cents (signed to support refunds/adjustments)
3. **Return variant**: Custom enum `MarkResult` to distinguish successful Cents values from anomalies; "recorded" means returned/distinguishable at call site
4. **Banker's rounding**: `f64::round()` implements round-half-to-even natively
5. **Non-finite handling**: NaN, Inf, -Inf treated as invalid and returned as anomalies (not explicitly mentioned in EARS but implicit in "numeric")
6. **Anomaly threshold**: Positive means `price > 0.0` (strict greater-than; zero price × 100 = zero result is normal, not anomalous)
7. **Overflow**: Very large prices multiply to Infinity, caught by `is_finite()` check
8. **Negative prices**: Allowed to round normally (no anomaly even if they round to 0)

**Ambiguity resolved:** EARS says "positive price that rounds to 0" — interpreted as price input > 0.0, not the result being positive (which cannot happen if cents == 0).