```rust
/// Classification of a raw GOOGLEFINANCE numeric reading, per SHEET-MARK-007.
/// Never produces a mark for non-positive or non-finite input.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PriceReadingOutcome {
    /// Finite and strictly positive; eligible to become a mark (conversion to Cents is out of scope here).
    Valid(f64),
    /// Must be recorded as a degraded anomaly instead of a mark.
    Degraded(DegradedAnomaly),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DegradedAnomalyKind {
    /// 0.0 or negative numeric reading.
    SubCent,
    /// NaN or ±∞.
    Permanent,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct DegradedAnomaly {
    pub kind: DegradedAnomalyKind,
    pub raw: f64,
}

pub fn classify_price_reading(raw: f64) -> PriceReadingOutcome {
    // Check non-finite FIRST: -inf <= 0.0 is true, so a <=0.0 check alone
    // would misclassify -infinity as SubCent instead of Permanent.
    if raw.is_nan() || raw.is_infinite() {
        return PriceReadingOutcome::Degraded(DegradedAnomaly {
            kind: DegradedAnomalyKind::Permanent,
            raw,
        });
    }
    if raw <= 0.0 {
        return PriceReadingOutcome::Degraded(DegradedAnomaly {
            kind: DegradedAnomalyKind::SubCent,
            raw,
        });
    }
    PriceReadingOutcome::Valid(raw)
}
```

Assumptions:
1. Input type is `f64` — the raw GOOGLEFINANCE cell read-back, prior to any Cents conversion.
2. This function is pure classification only; persisting the anomaly ("recorded as") is a caller-side effect, not modeled here — matches the described separation where sheets-view owns no accounting math.
3. Converting a `Valid` reading into an actual mark (Cents) is a different spec's responsibility; `Valid(f64)` is a passthrough placeholder, not the mark type itself.
4. `0.0` exactly is treated as non-positive per the spec's explicit inclusion ("`0.0` or negative").
5. Both `+inf` and `-inf` map to `Permanent`, per "`±∞`".
6. No magnitude-based tiers beyond the two named: any finite value `<= 0.0` is `SubCent` regardless of how negative; any non-finite value is `Permanent` regardless of sign.
7. Ordering choice (non-finite check before non-positive check) is deliberate and required for correctness, since `-infinity <= 0.0` evaluates true in IEEE-754/Rust and would otherwise be misrouted to `SubCent`.
8. `DegradedAnomaly` carries the raw offending value for audit purposes — not required by the text but reasonable for a "recorded" anomaly to be inspectable.
9. Assumed a broader anomaly-kind enum may exist elsewhere in the real system; `DegradedAnomalyKind` here is scoped narrowly to just the two kinds this EARS defines.
10. No explicit handling for subnormal/tiny-but-positive floats — spec only distinguishes non-positive vs non-finite vs (implicitly) positive-finite.