```rust
/// A raw numeric price reading from the GOOGLEFINANCE oracle column,
/// prior to any cents-conversion or settlement.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PriceReading(pub f64);

/// Degraded-anomaly classification for a reading that cannot become a mark.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DegradedAnomaly {
    /// 0.0 or negative: transient/quotidian bad tick, may self-correct
    /// on a later read-back pass.
    SubCent,
    /// NaN or ±infinity: non-numeric/non-finite, treated as unrecoverable
    /// without operator intervention.
    Permanent,
}

/// Outcome of classifying one price reading during the marks settle pass.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum MarkOutcome {
    Mark(u64), // Cents, always > 0
    Anomaly(DegradedAnomaly),
}

/// Classifies a raw GOOGLEFINANCE reading per SHEET-MARK-007.
/// Never returns a Mark for non-positive or non-finite input.
pub fn classify_reading(reading: PriceReading) -> MarkOutcome {
    let v = reading.0;

    if !v.is_finite() {
        return MarkOutcome::Anomaly(DegradedAnomaly::Permanent);
    }
    if v <= 0.0 {
        return MarkOutcome::Anomaly(DegradedAnomaly::SubCent);
    }

    // Positive finite: convert to integer Cents. Rounding policy is
    // outside this spec's scope; round-half-even chosen as a neutral default.
    let cents = (v * 100.0).round_ties_even() as u64;
    MarkOutcome::Mark(cents)
}
```

Assumptions (invented, not stated by the EARS):

1. `PriceReading` is a bare `f64` wrapper — the spec says "numeric price reading" but not its representation; GOOGLEFINANCE cells surface as floats.
2. `-0.0` is treated as non-positive (`v <= 0.0` catches it), since it is not a usable positive price.
3. `DegradedAnomaly` is a two-variant enum (`SubCent`, `Permanent`) rather than a string/code, matching the two named categories exactly; no third catch-all variant added.
4. "Never as a mark" is implemented as the enum's Mark arm being unreachable for these inputs, i.e., exhaustive branching at the top of the function rather than a post-hoc filter — chosen so the guard can't be bypassed by future code paths.
5. Order of checks: non-finite is checked before non-positive, since NaN comparisons (`NaN <= 0.0`) are always false in IEEE-754, so the ordering is actually required, not just stylistic, to correctly route NaN to `Permanent` rather than falling through.
6. Successful mark conversion (positive finite) is out of this spec's scope but sketched minimally for context; rounding mode (`round_ties_even`) is an arbitrary placeholder default, not mandated by SHEET-MARK-007.
7. No distinction made between `+∞` and `-∞` — both fold into `Permanent`, since the spec groups "±∞" as one category.
8. Function is pure/total (no `Result`/error type) since every input has a defined outcome — no reading is rejected outright, only classified.
9. "Recorded as" is assumed to mean returning a value for the caller to persist (e.g., into a settle-pass log/store); persistence/storage mechanics are outside this sketch's scope.