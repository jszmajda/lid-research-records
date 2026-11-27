```rust
/// Cents: integer minor-unit money type used throughout the kernel.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

/// Result of converting a raw USD price into a mark.
#[derive(Debug, Clone, PartialEq)]
pub enum Mark {
    Value(Cents),
    Anomaly(MarkAnomaly),
}

#[derive(Debug, Clone, PartialEq)]
pub enum MarkAnomaly {
    /// Positive price rounded to 0 Cents — degraded, not a legitimate zero mark.
    ZeroFromPositivePrice { price: f64 },
    /// Non-finite or negative input; out of domain for a price oracle.
    InvalidPrice { price: f64 },
}

/// EARS SHEET-MARK-002.
pub fn price_to_mark(price: f64) -> Mark {
    if !price.is_finite() || price < 0.0 {
        return Mark::Anomaly(MarkAnomaly::InvalidPrice { price });
    }

    let scaled = price * 100.0;
    let cents = scaled.round_ties_even() as i64; // banker's rounding, per spec

    if price > 0.0 && cents == 0 {
        return Mark::Anomaly(MarkAnomaly::ZeroFromPositivePrice { price });
    }

    Mark::Value(Cents(cents))
}
```

Assumptions (every one invented, none stated by the EARS text):

1. **Input type**: `price: f64`. The requirement says "numeric USD price" but gives no type; f64 is the natural fit for a `GOOGLEFINANCE`-sourced value.
2. **`round_half_to_even` = `f64::round_ties_even`** (stable since Rust 1.77), applied to `price * 100.0` before truncating to `i64`. No custom banker's-rounding reimplementation.
3. **Output shape**: a `Mark` enum wrapping either `Cents` or an anomaly variant, rather than a bare `Result`/panic — the spec explicitly wants the degraded case *recorded*, implying a durable, inspectable value rather than an error short-circuit.
4. **Zero price (`price == 0.0`) is NOT an anomaly.** The spec says "a **positive** price that rounds to 0" — exact zero input is excluded from the guard and yields a legitimate `Cents(0)`.
5. **Negative and non-finite (`NaN`/`±inf`) prices are out of scope for this rule** and are routed to a separate `InvalidPrice` anomaly rather than being fed through the rounding rule at all — the spec only discusses "a positive price," so negative/invalid inputs needed an invented fallback.
6. **No currency/locale conversion** — "numeric USD price" is assumed already USD-denominated; no FX handling.
7. **No overflow guard** on `as i64` truncation post-round — assumed prices stay in a range where `price * 100` fits `i64` (no saturating/checked cast), since the spec doesn't address extreme magnitudes.
8. **Anomaly carries the offending `price`** for downstream logging/audit, since "recorded as a degraded anomaly" implies retaining enough context to diagnose it, though the spec doesn't specify the anomaly's payload.