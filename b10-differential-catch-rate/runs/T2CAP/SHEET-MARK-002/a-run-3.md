```rust
// crates/sheets-view/src/mark.rs
// @spec SHEET-MARK-002

/// Money. Integer cents, signed (kernel-wide type; re-exported here).
#[derive(Copy, Clone, PartialEq, Eq, Debug)]
pub struct Cents(pub i64);

/// Why a price could not become a mark.
#[derive(Clone, PartialEq, Debug)]
pub enum MarkAnomaly {
    /// price > 0.0 but round_half_to_even(price * 100) == 0
    SubCentPrice { price: f64 },
    /// NaN / ±inf
    NonFinite { price: f64 },
    /// price < 0.0
    NegativePrice { price: f64 },
    /// |price * 100| exceeds i64
    OutOfRange { price: f64 },
}

/// Degraded outcome: never fabricate a zero mark.
pub type MarkResult = Result<Cents, MarkAnomaly>;

pub fn price_to_cents(price: f64) -> MarkResult {
    if !price.is_finite() {
        return Err(MarkAnomaly::NonFinite { price });
    }
    if price < 0.0 {
        return Err(MarkAnomaly::NegativePrice { price });
    }
    let scaled = price * 100.0;
    // f64::round_ties_even == round-half-to-even (banker's rounding)
    let rounded = scaled.round_ties_even();
    if rounded < i64::MIN as f64 || rounded > i64::MAX as f64 {
        return Err(MarkAnomaly::OutOfRange { price });
    }
    let cents = rounded as i64;
    if cents == 0 && price > 0.0 {
        return Err(MarkAnomaly::SubCentPrice { price });
    }
    Ok(Cents(cents))
}
```

ASSUMPTIONS (all invented; none stated by the EARS):

1. `Cents` is a newtype over `i64`, signed, whole cents. Not stated.
2. Input "numeric USD price" is `f64` — the natural shape for a GOOGLEFINANCE cell read back as a number. A decimal type would remove the `price * 100.0` representation error entirely.
3. Rounding uses `f64::round_ties_even` (Rust 1.77+) rather than a hand-rolled half-to-even. Note: `price * 100.0` can itself round before the tie test, so exact-tie behavior on decimal inputs is not guaranteed — a decimal/scaled-integer path would be needed for strictness.
4. "Degraded anomaly" is modeled as `Err(MarkAnomaly)`, i.e. the function returns no mark at all. The EARS says only "recorded as a degraded anomaly"; I assume the caller (settle pass) records it and the cell renders as stale/blank, not 0.
5. Chosen interpretation of the positive-zero clause: the anomaly triggers only when `price > 0.0` and result is exactly 0. An input of exactly `0.0` is treated as a legitimate `Cents(0)` — the EARS scopes the rule to "a positive price".
6. Negative prices → anomaly. The EARS is silent; a negative USD mark is nonsense for this oracle, so I refuse rather than record.
7. NaN/±inf → anomaly. GOOGLEFINANCE can yield errors/blank; the EARS says "numeric" so I reject non-finite rather than panic or coerce.
8. i64 overflow → anomaly rather than saturating.
9. No logging, metrics, or anomaly persistence here — this function is pure; recording is the caller's job. The EARS's "recorded" is honored by returning a typed, non-lossy anomaly value.
10. No currency tag: USD is assumed by the requirement, not checked.