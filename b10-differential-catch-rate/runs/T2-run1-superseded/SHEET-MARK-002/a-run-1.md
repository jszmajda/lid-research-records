```rust
/// A Cents amount, or a recorded anomaly in place of a would-be zero mark.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PriceMark {
    Settled(Cents),
    DegradedAnomaly { raw_price: f64, reason: AnomalyReason },
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum AnomalyReason {
    /// price > 0 but round_half_to_even(price * 100) == 0
    PositivePriceRoundedToZero,
}

/// Round-half-to-even ("banker's rounding") to the nearest i64.
fn round_half_to_even(x: f64) -> i64 {
    x.round_ties_even() as i64 // stable since Rust 1.77
}

pub fn price_to_mark(price: f64) -> PriceMark {
    let cents = round_half_to_even(price * 100.0);
    if price > 0.0 && cents == 0 {
        PriceMark::DegradedAnomaly {
            raw_price: price,
            reason: AnomalyReason::PositivePriceRoundedToZero,
        }
    } else {
        PriceMark::Settled(Cents(cents))
    }
}
```

Assumptions invented beyond the EARS text:

1. **Input type**: `price: f64` — the GOOGLEFINANCE oracle column yields a floating-point USD number; no `Decimal` type is implied by the spec.
2. **`Cents` type**: assumed to already exist as an `i64`-backed newtype elsewhere in the kernel; not redefined here beyond its use.
3. **`round_half_to_even` implementation**: used `f64::round_ties_even` (stable Rust 1.77+) as the literal banker's-rounding primitive the EARS names; a hand-rolled floor/diff fallback would be substituted for an older toolchain.
4. **Return shape**: modeled as a 2-variant enum (`Settled` / `DegradedAnomaly`) rather than `Result<Cents, Error>`, since a degraded anomaly is described as something "recorded" during a settle pass, not a failure that aborts the caller — this is a valid, expected outcome path, not an error condition.
5. **"Positive price" boundary**: interpreted strictly as `price > 0.0`, so `price == 0.0` is a legitimate zero mark (not an anomaly), and only strictly-positive prices rounding down to 0 trigger the anomaly rule.
6. **Negative and non-finite (`NaN`/`±Infinity`) prices**: left unhandled/pass-through, since the EARS only constrains the positive-price-rounds-to-zero case; treating negative/NaN prices as a separate anomaly class is a plausible related rule but not one this EARS states, so it's out of scope here.
7. **No currency/unit conversion**: `price` is assumed already denominated in USD, matching the GOOGLEFINANCE column's stated semantics — no scaling beyond the ×100 cents conversion.
8. **Anomaly payload**: included `raw_price` and a `reason` enum as the minimal data a downstream settle-pass logger would need to record the anomaly meaningfully; the EARS doesn't specify anomaly payload shape, so this is invented for concreteness.