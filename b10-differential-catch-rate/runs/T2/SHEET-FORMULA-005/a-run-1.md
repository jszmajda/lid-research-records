```rust
use google_sheets4::api::{CellData, CellFormat, ExtendedValue, NumberFormat};

/// Tax rate in basis points (1 bp = 0.01%), matching the ledger's
/// integer-money convention — avoids storing a float in domain state.
/// E.g. 1550 => 15.50%.
#[derive(Clone, Copy, Debug)]
pub struct TaxRateBps(pub u32);

/// Builds the `Est. Tax Rate` CellData as a numeric, percent-formatted
/// value so downstream GOOGLEFINANCE-derived formulas (`Est. Unrealized
/// Tax`, `Net Unrealized`) that multiply this cell see a number, not text.
pub fn est_tax_rate_cell(rate: TaxRateBps) -> CellData {
    let fraction = rate.0 as f64 / 10_000.0; // Sheets PERCENT expects 0.155, not 15.5
    CellData {
        user_entered_value: Some(ExtendedValue {
            number_value: Some(fraction),
            ..Default::default()
        }),
        user_entered_format: Some(CellFormat {
            number_format: Some(NumberFormat {
                type_: Some("PERCENT".to_string()),
                pattern: Some("0.00%".to_string()),
            }),
            ..Default::default()
        }),
        ..Default::default()
    }
}
```

Assumptions (invented, not in the EARS text):

1. **Interpretation of "percent-typed userEnteredValue"**: the EARS's parenthetical ("a `%`-suffixed value") describes what a *user* would type, but the fix must hold under a batchUpdate write path — so I set `ExtendedValue.number_value` directly (a fraction, e.g. `0.155`) plus `NumberFormat{type: PERCENT}`, rather than writing the string `"15.50%"` via `values.update`/`USER_ENTERED` and relying on Sheets' input parser. Direct CellData is deterministic regardless of write path; string-input parsing is a plausible but weaker alternative I rejected.
2. **Input type**: no existing type for tax rate was given, so I invented `TaxRateBps(u32)` (basis points) to mirror the crate's integer-`Cents` philosophy rather than passing a raw `f64` percentage into domain code.
3. **Sheets library**: assumed `google_sheets4`'s `api::{CellData, CellFormat, ExtendedValue, NumberFormat}` types, since the workspace already talks to Sheets for tab publishing.
4. **Value range**: no clamping or validation — `u32` forbids negative rates, but rates above 100% (10000 bps) are passed through uncapped, since "reasonable" doesn't rule out edge-case display in the source data.
5. **Zero rate**: `TaxRateBps(0)` still yields a numeric `0.0` + percent format (not a blank/text cell), so downstream formulas always multiply against a number.
6. **Missing/unknown rate**: out of scope for this function — no `Option<TaxRateBps>` handling invented, since the EARS only constrains the written case, not absence.
7. **Number format pattern**: `"0.00%"` (two decimals) chosen arbitrarily as a reasonable display pattern; the EARS only requires percent *type*, not a specific pattern.