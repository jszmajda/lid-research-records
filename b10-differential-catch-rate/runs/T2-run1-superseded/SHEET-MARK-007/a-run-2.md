```rust
/// A raw numeric reading pulled from the GOOGLEFINANCE oracle cell.
pub type PriceReading = f64;

/// Degraded-anomaly categories a bad reading can produce.
/// Never converted into a settled mark.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DegradedAnomaly {
    /// Reading was finite but non-positive (`0.0` or negative).
    SubCent,
    /// Reading was non-finite (`NaN` or `±∞`).
    Permanent,
}

/// Result of validating a price reading before it may settle as a mark.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum MarkOutcome {
    /// Reading was strictly positive and finite; safe to convert to Cents.
    Mark(PriceReading),
    /// Reading was rejected; the anomaly category to record.
    Degraded(DegradedAnomaly),
}

/// Classifies a raw price reading per SHEET-MARK-007.
///
/// @spec SHEET-MARK-007
pub fn classify_price_reading(reading: PriceReading) -> MarkOutcome {
    // Non-finite check MUST precede the non-positive check: NaN compares
    // false against `<= 0.0`, so checking finiteness first is required for
    // NaN to land in `Permanent` rather than falling through to `Mark`.
    if !reading.is_finite() {
        return MarkOutcome::Degraded(DegradedAnomaly::Permanent);
    }
    if reading <= 0.0 {
        return MarkOutcome::Degraded(DegradedAnomaly::SubCent);
    }
    MarkOutcome::Mark(reading)
}
```

Assumptions (explicitly invented, since only the EARS text was given):

1. **Reading type**: raw reading is `f64` (Sheets API/GOOGLEFINANCE numeric cell deserializes as `f64`); the actual Cents conversion is a separate downstream step not shown, since this spec only governs classification, not the price→Cents math.
2. **"Sub-cent" / "permanent" are category labels**, not literal sub-cent arithmetic — read as two severity tiers (transient/retryable vs. permanent/non-retryable) for downstream anomaly handling, since the EARS gives no further semantics for either name.
3. **Zero is included** in "non-positive" per the parenthetical `(0.0 or negative)`; `-0.0` is treated as non-positive too (`<= 0.0` covers it).
4. **Check ordering is load-bearing**: `is_finite()` must run before the `<= 0.0` comparison, because NaN fails all ordered comparisons — without this order NaN would silently pass through as a "positive" mark, violating "never silently understates or corrupts value."
5. **"Recorded as an anomaly" is modeled as a return value**, not an I/O side effect — the function is pure; actual persistence/logging of the anomaly is assumed to be the caller's responsibility (e.g., an anomaly-log append), out of scope for this classification sketch.
6. **`MarkOutcome` enum chosen over `Result<f64, DegradedAnomaly>`** — treats "degraded" as a first-class settle outcome rather than a Rust error, since a degraded reading is documented, expected pipeline behavior, not an exceptional failure to `?`-propagate.
7. **No distinction made between `+∞` and `-∞`** — both fall under `Permanent` via `!is_finite()`, since the EARS lists them together (`±∞`) with no differing treatment specified.
8. Boundary case reading exactly `0.0` is unambiguous per the spec text itself (explicitly named), so no interpretation was needed there.