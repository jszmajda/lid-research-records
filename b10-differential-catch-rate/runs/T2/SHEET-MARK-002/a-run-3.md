```rust
/// Ledger money unit (spec: Money is integer Cents).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

/// Distinguishes a genuine settled mark from a degraded anomaly —
/// callers must not treat the latter as a valid zero-value mark.
#[derive(Debug, Clone, PartialEq)]
pub enum MarkOutcome {
    Settled(Cents),
    DegradedAnomaly(MarkAnomaly),
}

#[derive(Debug, Clone, PartialEq)]
pub enum MarkAnomaly {
    /// price > 0.0 but rounded to exactly 0 Cents.
    PositivePriceRoundedToZero { price: f64 },
    /// price was NaN or infinite; not convertible at all.
    NonFinitePrice { price: f64 },
    /// price was <= 0.0 (spec is silent here; see assumptions).
    NonPositivePrice { price: f64 },
}

/// SHEET-MARK-002: Cents = round_half_to_even(price * 100); a positive
/// price rounding to 0 Cents is a degraded anomaly, not a zero mark.
pub fn price_to_cents(price: f64) -> MarkOutcome {
    if !price.is_finite() {
        return MarkOutcome::DegradedAnomaly(MarkAnomaly::NonFinitePrice { price });
    }
    if price <= 0.0 {
        return MarkOutcome::DegradedAnomaly(MarkAnomaly::NonPositivePrice { price });
    }

    let scaled = (price * 100.0).round_ties_even(); // banker's rounding
    let cents = scaled as i64;

    if cents == 0 {
        MarkOutcome::DegradedAnomaly(MarkAnomaly::PositivePriceRoundedToZero { price })
    } else {
        MarkOutcome::Settled(Cents(cents))
    }
}
```

Assumptions (every one invented beyond the literal EARS text):

1. Price input type is `f64` (GOOGLEFINANCE-sourced numeric USD quote).
2. `Cents` is a newtype over `i64`.
3. `round_half_to_even` is implemented via Rust's stable `f64::round_ties_even`, assumed semantically identical to the spec's banker's-rounding term.
4. Formula applied literally as one multiply-then-round step (`price * 100.0` then round), no intermediate decimal/rational type — spec gives an exact expression, so no extra precision layer was added.
5. Result type is an enum (`MarkOutcome`) distinguishing `Settled` vs `DegradedAnomaly`, rather than `Result<Cents, Error>` — "recorded as a degraded anomaly, not a zero mark" reads as a distinct record kind, not merely an error short-circuit.
6. Non-finite price (NaN/±inf) isn't addressed by the spec at all; chosen to treat as its own anomaly variant rather than panicking or letting `as i64` produce an undefined/saturating value.
7. `price <= 0.0` (zero or negative) is treated as a separate `NonPositivePrice` anomaly. This is an invented extension: the spec's anomaly clause only covers *positive* price rounding to 0; it says nothing about non-positive input. Chosen defensively since a live-price oracle should never emit ≤0, and letting it fall through would either produce a spurious `Cents(0)` "settled" mark (violating the spirit of the rule) or a nonsensical negative mark.
8. The function is pure — it only classifies/converts; actual persistence/logging of the anomaly ("recorded") is assumed to be the caller's (sheets-view settle pass's) responsibility, since the EARS doesn't specify a logging side effect inside conversion itself.
9. No special-cased boundary arithmetic beyond what `round_ties_even` already provides for exact `.5`-cent ties (e.g., price `0.005` → `0.5` → ties-to-even → `0` cents → anomaly).