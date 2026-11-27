```rust
/// Integer minor-unit money type used throughout the kernel.
pub type Cents = i64;

/// Outcome of converting a live USD price into a mark.
#[derive(Debug, Clone, PartialEq)]
pub enum PriceMark {
    Settled(Cents),
    DegradedAnomaly { raw_price: f64, reason: &'static str },
}

/// Round-half-to-even ("banker's rounding") of an f64 to the nearest i64.
fn round_half_to_even(x: f64) -> i64 {
    let floor = x.floor();
    let frac = x - floor;
    let floor_i = floor as i64; // saturating cast (NaN -> 0, +-inf -> MAX/MIN)
    match frac.partial_cmp(&0.5) {
        Some(std::cmp::Ordering::Less) => floor_i,
        Some(std::cmp::Ordering::Greater) => floor_i + 1,
        _ => if floor_i % 2 == 0 { floor_i } else { floor_i + 1 },
    }
}

/// SHEET-MARK-002: convert a numeric USD price to Cents.
pub fn price_to_mark(price: f64) -> PriceMark {
    let cents = round_half_to_even(price * 100.0);
    if price > 0.0 && cents == 0 {
        PriceMark::DegradedAnomaly {
            raw_price: price,
            reason: "positive price rounded to 0 Cents",
        }
    } else {
        PriceMark::Settled(cents)
    }
}
```

Assumptions:
1. Input `price` is `f64`, already parsed from the GOOGLEFINANCE cell value (numeric, not the raw sheet string).
2. `Cents` is a signed `i64` alias — signed to allow negative/zero marks generally, per "Money is integer Cents" in the broader system.
3. Rust's stdlib has no built-in round-half-to-even for floats, so it's hand-rolled: compare the fractional part to 0.5 and, on an exact tie, round to the even integer.
4. Output is a new minimal `PriceMark` enum (`Settled` vs `DegradedAnomaly`) since the spec implies the mark pipeline distinguishes ordinary marks from anomalies but doesn't define the anomaly's shape — I gave it just `raw_price` + a static `reason` string, the smallest payload that satisfies "recorded as."
5. The anomaly condition is read literally: **only** `price > 0.0 && cents == 0` triggers it. A `price == 0.0` or negative price that rounds to 0 Cents is treated as an ordinary zero/negative mark, not an anomaly — the spec text explicitly says "a positive price."
6. `price × 100` is computed directly in floating point (no pre-scaling/Decimal), matching the literal formula text; any float-representation error in that multiply is accepted as inherent to the stated conversion, not compensated for.
7. `NaN`/`±Infinity` inputs are out of scope for this EARS — no anomaly path is defined for them here; the saturating float→int cast means NaN silently becomes `0` and would misleadingly hit the same `price > 0.0` check. Left as a gap since the requirement text doesn't address non-finite input; a fresh caller-side validation guard is assumed upstream.
8. Function is pure/synchronous — no I/O, no interaction with the marks read-back settle pass itself (out of scope for this spec).