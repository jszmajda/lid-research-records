```rust
//! Price → Cents conversion for the sheets-view live-price oracle.
//! @spec SHEET-MARK-002

/// Money is integer cents (i64: signed so downstream deltas/short positions work).
pub type Cents = i64;

#[derive(Debug, Clone, PartialEq)]
pub enum MarkAnomaly {
    /// Positive price that rounds to zero cents (sub-half-cent price).
    UnderflowToZero { price: f64 },
    /// Price is NaN or infinite.
    NotFinite { price: f64 },
    /// Price is negative (a USD equity/fund price should never be < 0).
    Negative { price: f64 },
    /// |price × 100| exceeds Cents range.
    Overflow { price: f64 },
}

#[derive(Debug, Clone, PartialEq)]
pub enum PriceMark {
    /// Usable mark.
    Mark(Cents),
    /// No mark recorded; the row is degraded and carries the reason.
    Degraded(MarkAnomaly),
}

/// Convert a numeric USD price to `Cents` via round-half-to-even on `price × 100`.
pub fn price_to_cents(price: f64) -> PriceMark {
    if !price.is_finite() {
        return PriceMark::Degraded(MarkAnomaly::NotFinite { price });
    }
    if price < 0.0 {
        return PriceMark::Degraded(MarkAnomaly::Negative { price });
    }

    // f64::round_ties_even is exactly round-half-to-even (banker's rounding).
    let scaled = price * 100.0;
    let rounded = scaled.round_ties_even();

    if rounded < (Cents::MIN as f64) || rounded > (Cents::MAX as f64) {
        return PriceMark::Degraded(MarkAnomaly::Overflow { price });
    }

    let cents = rounded as Cents;

    // The requirement's carve-out: positive price must never become a zero mark.
    if cents == 0 && price > 0.0 {
        return PriceMark::Degraded(MarkAnomaly::UnderflowToZero { price });
    }

    PriceMark::Mark(cents)
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn rounds_half_to_even() {
        assert_eq!(price_to_cents(1.005), PriceMark::Mark(100)); // 100.49999.. binary
        assert_eq!(price_to_cents(0.125), PriceMark::Mark(12)); // 12.5 → 12
        assert_eq!(price_to_cents(0.135), PriceMark::Mark(14)); // 13.5 → 14
    }
    #[test]
    fn positive_underflow_is_degraded() {
        assert!(matches!(price_to_cents(0.001), PriceMark::Degraded(MarkAnomaly::UnderflowToZero { .. })));
        assert!(matches!(price_to_cents(0.004999), PriceMark::Degraded(MarkAnomaly::UnderflowToZero { .. })));
    }
    #[test]
    fn exact_zero_is_a_mark_not_an_anomaly() {
        assert_eq!(price_to_cents(0.0), PriceMark::Mark(0));
    }
}
```

Assumptions invented (not stated in the EARS):

1. `Cents = i64`, signed — the EARS names `Cents` but not its width/signedness.
2. Input is `f64` — "numeric USD price" implies the sheet's float, not a decimal type. Exact decimal input would change which values are ties.
3. Return type is a two-variant enum (`Mark` | `Degraded`) rather than `Result` or `Option`, because "recorded as a degraded anomaly" implies a first-class carried value, not an error to propagate. Assumed the caller records it; this function only classifies.
4. Anomaly payload shape (`MarkAnomaly` variants, carrying the offending price) is invented; the EARS names only the underflow case.
5. **Interpretation chosen:** "positive price that rounds to 0" means `price > 0.0 && cents == 0` — i.e. the *input* is strictly positive. Exactly `0.0` is therefore a legitimate zero mark, not an anomaly. Chosen because the EARS says "positive price," not "non-negative."
6. Extended the degraded path to NaN/±Inf, negative, and overflow inputs — the EARS covers none of these; returning `Mark` for them would be worse than degrading. Flagged as scope I added.
7. Negative prices treated as invalid rather than as a legitimate signed mark; if short/adjustment prices can be negative, variant 3 is wrong and `Negative` should be dropped.
8. `f64::round_ties_even` (stable since Rust 1.77) is taken as the canonical `round_half_to_even`. Assumed no requirement for pre-1.77 toolchains.
9. Ties are evaluated on the binary `f64` product `price * 100.0`, so decimal "exact halves" like `1.005` are usually not ties at all. Assumed acceptable; a decimal library would be needed for decimal-tie semantics.
10. No logging/metrics/anomaly-sink side effects here — assumed the caller (settle/read-back pass) owns persistence of the degraded record.