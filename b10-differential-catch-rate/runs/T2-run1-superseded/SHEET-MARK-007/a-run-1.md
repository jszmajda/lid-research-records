```rust
/// A raw numeric reading pulled from the price oracle cell
/// (e.g. a GOOGLEFINANCE-driven cell read back during the marks settle pass).
pub type PriceReading = f64;

/// Money, always whole cents.
pub type Cents = i64;

/// Result of evaluating one price reading for settlement.
#[derive(Debug, Clone, PartialEq)]
pub enum MarkResult {
    /// Valid, positive, finite price — safe to convert and record as a mark.
    Mark(Cents),
    /// Reading was non-positive (`0.0` or negative): degraded, sub-cent anomaly.
    DegradedSubCent { reading: PriceReading },
    /// Reading was non-finite (`NaN` / `±∞`): degraded, permanent anomaly.
    DegradedPermanent { reading: PriceReading },
}

/// Classify a raw price reading per SHEET-MARK-007. Never returns `Mark`
/// for a non-positive or non-finite reading — the anomaly variants are the
/// only way such readings leave this function.
pub fn classify_reading(
    reading: PriceReading,
    to_cents: impl FnOnce(f64) -> Cents,
) -> MarkResult {
    // Finiteness must be checked before the `<= 0.0` comparison: under IEEE 754,
    // NaN compares false against everything, so a NaN reading would otherwise
    // fall through past a non-positive check into the Mark branch.
    if !reading.is_finite() {
        return MarkResult::DegradedPermanent { reading };
    }
    if reading <= 0.0 {
        return MarkResult::DegradedSubCent { reading };
    }
    MarkResult::Mark(to_cents(reading))
}
```

Assumptions invented beyond the EARS text:

1. `PriceReading` modeled as `f64`, matching a GOOGLEFINANCE-sourced numeric cell.
2. `Cents` modeled as `i64`, per the stated integer-cents money convention.
3. Each degraded variant carries the offending raw `reading` value, assumed necessary for the anomaly record to be inspectable/auditable, not just a bare tag.
4. `-0.0` is treated as non-positive (`-0.0 <= 0.0` is true in IEEE 754), since the spec's "`0.0`" wording doesn't distinguish signed zero.
5. Check order (non-finite before non-positive) is deliberate, not stylistic — required so `NaN` routes to `DegradedPermanent` rather than silently passing the `<= 0.0` test.
6. "Never as a mark" interpreted as a type-level guarantee: `Mark` is only constructible on the success path, not merely a runtime convention.
7. The actual f64→Cents conversion (`to_cents`) is assumed to live elsewhere in the kernel and is injected here as a closure — out of scope for this spec.
8. No retry/backoff or transient-vs-permanent recovery logic is included; this function is a stateless, single-reading classifier only — what the settle pass does with each `MarkResult` (write a mark vs. append to an anomaly log) is assumed out of scope.
9. A missing/absent reading (e.g., blank cell, parse failure upstream) is assumed to be a distinct concern from "a numeric price reading" and is not handled by this function — it would need to be normalized to some `PriceReading` (or rejected) before reaching here.
10. Ambiguity resolved: "sub-cent" and "permanent" are treated as two anomaly *kinds*, not a severity ordering — no assumption is made that one escalates into the other.