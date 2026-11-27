```rust
/// Money is represented as integer cents throughout the kernel.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub i64);

/// Outcome of converting a GOOGLEFINANCE price read into a mark.
/// A sum type (not Result<Cents, Error>) because a degraded anomaly
/// is a recorded fact, not necessarily a hard failure of the settle pass.
#[derive(Debug, Clone, PartialEq)]
pub enum PriceMark {
    Ok(Cents),
    DegradedAnomaly {
        reason: &'static str,
        input_price: f64,
    },
}

/// SHEET-MARK-002: convert a numeric USD price to Cents via
/// round_half_to_even(price * 100). A positive price that rounds to
/// 0 Cents is recorded as a degraded anomaly, never as a zero mark.
pub fn price_to_cents(price: f64) -> PriceMark {
    let scaled = price * 100.0;
    let cents = scaled.round_ties_even() as i64;

    if price > 0.0 && cents == 0 {
        return PriceMark::DegradedAnomaly {
            reason: "positive price rounded to 0 cents",
            input_price: price,
        };
    }

    PriceMark::Ok(Cents(cents))
}
```

Assumptions:
1. **Input type**: `price: f64` — "numeric USD price" taken as a plain float from the GOOGLEFINANCE cell read; the spec doesn't name a decimal type.
2. **`round_half_to_even`**: mapped directly to `f64::round_ties_even` (stable rounding, banker's rounding), assumed equivalent to the spec's named function rather than a hand-rolled implementation.
3. **"Positive"**: interpreted strictly as `price > 0.0`, excluding exactly `0.0` and negative prices from the anomaly rule — the spec only constrains the positive-rounds-to-zero case.
4. **Zero/negative price behavior**: left unspecified by this EARS; a `price == 0.0` or negative price passes through to `Ok(Cents(0))`/`Ok(Cents(negative))` uninterrupted, since only the positive→0 case is called out. This may be under-specified (an out-of-scope gap), not something I invented a rule for.
5. **NaN/Infinite input**: not mentioned in the spec; left undefined here (would produce a garbage `cents` value via `as i64`) rather than inventing an additional anomaly category not requested — flagged as a real gap a fresh reader should notice.
6. **Anomaly representation**: `PriceMark::DegradedAnomaly` carries no `Cents` field at all (not even `Cents(0)`), so it's structurally impossible to mistake it for a zero mark downstream — chosen to directly satisfy "not a zero mark" rather than relying on a sentinel value.
7. **`Cents` signedness**: `i64`, allowing negative for generality elsewhere in the ledger, though this function's anomaly path only triggers on the positive side per spec text.