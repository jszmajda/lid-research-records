```rust
/// Money is integer Cents elsewhere in the kernel; this newtype is assumed to
/// already exist and is reused here, not redefined.
pub struct Cents(pub i64);

/// Severity label reused verbatim from the EARS wording.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AnomalySeverity {
    /// Reading was 0.0 or negative.
    SubCent,
    /// Reading was NaN or ±infinity.
    Permanent,
}

#[derive(Debug, Clone, PartialEq)]
pub struct DegradedAnomaly {
    pub severity: AnomalySeverity,
    pub raw_reading: f64,
}

/// Outcome of classifying one raw GOOGLEFINANCE price reading during the
/// marks read-back settle pass. The two variants are structurally distinct
/// so a caller cannot accidentally treat an anomaly as a usable price.
#[derive(Debug, Clone, PartialEq)]
pub enum MarkOutcome {
    Mark(Cents),
    Anomaly(DegradedAnomaly),
}

/// Classifies a single numeric price reading per SHEET-MARK-007.
/// Non-finite checks run first: NaN/`inf` comparisons against 0.0 are
/// unreliable (`NaN <= 0.0` is false; `-inf <= 0.0` is true), so finiteness
/// must be resolved before the non-positive check to avoid misrouting.
pub fn classify_price_reading(raw: f64) -> MarkOutcome {
    if raw.is_nan() || raw.is_infinite() {
        return MarkOutcome::Anomaly(DegradedAnomaly {
            severity: AnomalySeverity::Permanent,
            raw_reading: raw,
        });
    }
    if raw <= 0.0 {
        return MarkOutcome::Anomaly(DegradedAnomaly {
            severity: AnomalySeverity::SubCent,
            raw_reading: raw,
        });
    }
    let cents = (raw * 100.0).round() as i64;
    MarkOutcome::Mark(Cents(cents))
}
```

Assumptions (all invented, not stated in the EARS):

1. Reading type is `f64`, matching a spreadsheet-formula numeric cell.
2. `Cents(i64)` already exists in the kernel; not redefined, just referenced.
3. `0.0` exactly is included in the sub-cent (non-positive) branch, per the EARS's explicit "(0.0 or negative)".
4. `-0.0` is treated as non-positive (satisfies `<= 0.0`), since the spec doesn't distinguish signed zero.
5. Non-finite check must run before the non-positive comparison — order is load-bearing, not stylistic, since `NaN <= 0.0` is `false` and `-inf <= 0.0` is `true`, both of which would misclassify without the finiteness guard.
6. "Sub-cent" and "permanent" are read as severity labels for the anomaly, not literal cent-magnitude thresholds — reused the EARS's own vocabulary as enum variants rather than inventing new names.
7. "Never as a mark" is enforced at the type level: `Mark` and `Anomaly` are separate enum variants, so no numeric value from the anomaly path can flow into `Cents` arithmetic.
8. Valid positive finite readings are rounded half-away-from-zero into whole Cents via `f64::round` — this rounding choice is outside the EARS's scope but was needed to complete the sketch's Mark branch.
9. Persisting/logging the anomaly (which sheet cell, which settle-pass run) is left to the caller; this function only classifies one reading.
10. Absent/missing readings (empty cell, parse failure upstream) are out of scope — the EARS only discusses numeric readings, so a prior parse stage is assumed to hand this function a bare `f64`.