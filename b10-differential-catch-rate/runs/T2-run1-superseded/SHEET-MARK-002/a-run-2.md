```rust
/// Money is integer Cents; a Mark is either a good value or a degraded anomaly.
pub type Cents = i64;

#[derive(Debug, Clone, PartialEq)]
pub enum MarkAnomaly {
    /// price > 0.0 but round_half_to_even(price*100) == 0 (sub-half-cent price).
    ZeroFromPositivePrice { price: f64 },
    /// Non-finite or negative input; out of scope of the stated rule but
    /// must resolve to *some* variant, so treated as degraded too.
    InvalidPrice { price: f64 },
}

#[derive(Debug, Clone, PartialEq)]
pub enum Mark {
    Value(Cents),
    Degraded(MarkAnomaly),
}

/// @spec SHEET-MARK-002
pub fn price_to_mark(price: f64) -> Mark {
    if !price.is_finite() || price < 0.0 {
        return Mark::Degraded(MarkAnomaly::InvalidPrice { price });
    }
    // round_half_to_even == Rust's round_ties_even (banker's rounding).
    let cents = (price * 100.0).round_ties_even() as i64;
    if price > 0.0 && cents == 0 {
        return Mark::Degraded(MarkAnomaly::ZeroFromPositivePrice { price });
    }
    Mark::Value(cents)
}
```

Assumptions:
1. Input type is `f64` (GOOGLEFINANCE yields a numeric spreadsheet value).
2. `Cents` is `i64`; no dedicated newtype wrapper shown, per stated "Money is integer Cents."
3. `round_half_to_even` maps directly to Rust's stable `f64::round_ties_even`.
4. Return shape is a `Mark` enum (`Value(Cents)` vs `Degraded(MarkAnomaly)`) rather than `Result`, since "recorded as a degraded anomaly" reads as a first-class settle-pass state, not merely an error to propagate/short-circuit.
5. "Positive price" interpreted as strictly `price > 0.0` (not `>= 0.0`); a legitimate price of exactly `0.0` is out of the rule's stated scope and is passed through as `Mark::Value(0)`, since the EARS only singles out *positive* prices rounding to zero.
6. Negative and non-finite (`NaN`/`±inf`) prices are undefined by this EARS; I chose to treat them as a separate `InvalidPrice` anomaly rather than silently producing a value, since a negative/garbage mark is never desirable — this is an invented fallback, not derived from the requirement text.
7. No explicit overflow guard beyond the `as i64` cast — assumed realistic USD prices never approach `i64::MAX` cents; not handled as a distinct anomaly.
8. Anomaly variants carry the offending `price: f64` for audit/debug traceability; the requirement doesn't mandate a payload, but "recorded as" implies something inspectable downstream.
9. Ambiguity in "recorded as a degraded anomaly": chosen to mean the function's return value itself signals degradation (caller records it), not that this function performs I/O/logging directly — keeps the sketch a pure conversion function.