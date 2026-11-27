```rust
/// Integer cents, per project convention.
pub type Cents = i64;

/// Raw price reading as read back from the GOOGLEFINANCE oracle column.
/// Assumed already normalized to f64 (blank/#N/A cells become NaN upstream).
pub type PriceReading = f64;

/// Why a reading was degraded instead of becoming a mark.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DegradedAnomaly {
    /// 0.0 or negative: treated as sub-cent / transient.
    SubCent,
    /// NaN or ±∞: treated as permanent.
    Permanent,
}

/// Outcome of classifying one reading during the marks settle pass.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum MarkOutcome {
    Mark(Cents),
    Anomaly(DegradedAnomaly),
}

/// @spec SHEET-MARK-007
/// Classifies a raw price reading; never returns Mark for a bad reading.
pub fn classify_price_reading(
    raw: PriceReading,
    to_cents: impl Fn(f64) -> Cents,
) -> MarkOutcome {
    // Non-finite check must precede the numeric comparison: NaN <= 0.0 is
    // false in IEEE-754, so it would otherwise fall through undetected.
    if raw.is_nan() || raw.is_infinite() {
        return MarkOutcome::Anomaly(DegradedAnomaly::Permanent);
    }
    if raw <= 0.0 {
        // Catches 0.0 and -0.0 (equal under <=) as well as negatives.
        return MarkOutcome::Anomaly(DegradedAnomaly::SubCent);
    }
    MarkOutcome::Mark(to_cents(raw))
}
```

Assumptions:

1. Reading type is `f64`; sheets-view has already parsed the GOOGLEFINANCE cell into a float before this function runs.
2. Any unparseable/blank/error cell (`#N/A`, empty) is normalized to `NaN` upstream, so it lands in the `Permanent` branch here rather than needing a separate `Option`/`Result` input type.
3. `-0.0` is treated as non-positive (sub-cent), since it compares equal to `0.0` under `<=` — the EARS text only says "0.0 or negative" but I read `-0.0` as the same value.
4. Check order matters: non-finite must be tested before the `<= 0.0` comparison, since NaN fails all numeric comparisons and would otherwise silently skip both branches.
5. "Sub-cent" and "permanent" are modeled as an enum discriminant only; actual persistence (writing to an anomaly log/store, distinct retry semantics) is assumed to be the caller's responsibility, out of scope for this classification function.
6. `to_cents` is assumed infallible/pre-validated for positive finite input — rounding/precision policy for cents conversion is not specified here and assumed handled elsewhere in the kernel.
7. `Mark` and `Anomaly` are mutually exclusive by construction (enum), satisfying "never as a mark" structurally rather than by convention.
8. `+∞` and `-∞` are not distinguished — both map to `Permanent`, per the EARS's grouping of "NaN/±∞" as one category.