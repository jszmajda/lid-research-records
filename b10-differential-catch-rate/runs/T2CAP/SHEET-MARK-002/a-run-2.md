```rust
// crates/sheets-view/src/mark.rs
// @spec SHEET-MARK-002

/// Money. Integer USD cents. i64 chosen for headroom over portfolio-sized sums.
#[derive(Copy, Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Cents(pub i64);

/// Why a price could not become a mark. Carried into the degraded-anomaly channel.
#[derive(Clone, Debug, PartialEq)]
pub enum MarkAnomaly {
    /// Positive price that rounds to 0 cents (0 < price < 0.005).
    UnderflowToZero { price: f64 },
    /// NaN / ±inf from the GOOGLEFINANCE cell.
    NotFinite { price: f64 },
    /// Negative price — not a valid USD price.
    Negative { price: f64 },
    /// |price×100| exceeds i64 range.
    OutOfRange { price: f64 },
}

/// Convert a numeric USD price to `Cents` via round-half-to-even.
/// Positive-but-subcent prices are never silently zeroed.
pub fn price_to_cents(price: f64) -> Result<Cents, MarkAnomaly> {
    if !price.is_finite() {
        return Err(MarkAnomaly::NotFinite { price });
    }
    if price < 0.0 {
        return Err(MarkAnomaly::Negative { price });
    }
    let scaled = price * 100.0;
    // f64::round_ties_even is banker's rounding: 2.5 -> 2, 3.5 -> 4.
    let rounded = scaled.round_ties_even();
    if rounded < i64::MIN as f64 || rounded > i64::MAX as f64 {
        return Err(MarkAnomaly::OutOfRange { price });
    }
    let cents = rounded as i64;
    if cents == 0 && price > 0.0 {
        return Err(MarkAnomaly::UnderflowToZero { price });
    }
    Ok(Cents(cents))
}
```

Assumptions invented (all of them):

1. `Cents` is a newtype over `i64`; it already exists in a shared money module and is imported here — redefined above only to make the sketch self-contained.
2. Input `price` is `f64`. GOOGLEFINANCE read-back yields a JSON/serde number, so a binary float is the realistic input type. (A decimal type would make the rounding exact; the requirement says "numeric," so f64 with `round_ties_even` is the reading chosen.)
3. "round_half_to_even" == banker's rounding == `f64::round_ties_even` (stable since Rust 1.77). Float representation means some literal-decimal ties (e.g. `0.005`) are not exact ties in binary and will not exercise the tie rule; accepted, not worked around.
4. Return shape: `Result<Cents, MarkAnomaly>` rather than a mark-plus-side-channel. Chosen because the requirement forbids producing a zero mark — the type must make "no mark" unrepresentable-as-zero, and the caller (the settle pass) decides how to record the anomaly. The function does not itself log or write; recording is the caller's job.
5. Exactly `price == 0.0` is a legitimate `Cents(0)`, not an anomaly. The requirement scopes the anomaly to *positive* prices only.
6. Negative prices are treated as anomalies (`Negative`) rather than rounded. The EARS says "USD price," and a negative price is invalid input; the requirement is silent, so this is an invented default. An alternate reading — round negatives normally — is defensible.
7. Non-finite and i64-overflow inputs are anomalies. The EARS is silent; refusing is safer than producing a garbage mark.
8. `-0.0` is not `> 0.0`, so it yields `Cents(0)`, not an anomaly.
9. Ambiguity chosen: "degraded anomaly" is modeled as a typed error variant, assuming the crate has an existing degraded/anomaly reporting channel that consumes such variants. No severity level, no retry, no fallback-to-last-known-mark is implemented — the requirement mentions none.