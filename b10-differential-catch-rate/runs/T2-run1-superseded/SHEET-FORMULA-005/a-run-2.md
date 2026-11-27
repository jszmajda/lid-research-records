```rust
// sheets-view crate: cell-projection for the Est. Tax Rate column.
// @spec SHEET-FORMULA-005

use google_sheets4::api::{CellData, CellFormat, ExtendedValue, NumberFormat};

/// Tax rate as basis points (10_000 = 100%), matching the kernel's
/// integer-money convention (Cents) applied to rates.
#[derive(Clone, Copy, Debug)]
pub struct TaxRateBps(pub i32);

impl TaxRateBps {
    fn as_fraction(self) -> f64 {
        self.0 as f64 / 10_000.0
    }
}

/// Builds the `userEnteredValue`/`userEnteredFormat` pair for the
/// `Est. Tax Rate` cell so Sheets stores a typed number (not a string),
/// letting downstream `Est. Unrealized Tax` / `Net Unrealized` formulas
/// multiply it numerically.
pub fn est_tax_rate_cell(rate: Option<TaxRateBps>) -> CellData {
    match rate {
        Some(r) => CellData {
            user_entered_value: Some(ExtendedValue {
                number_value: Some(r.as_fraction()),
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
        },
        // No computable rate (e.g. no cost basis to divide by): leave the
        // cell blank rather than writing text/"N/A". Sheets treats a blank
        // operand in multiplication as 0, preserving numeric evaluation.
        None => CellData::default(),
    }
}
```

Assumptions (invented, not stated by the EARS):

1. **Input shape**: rate arrives as integer basis points (`TaxRateBps(i32)`), consistent with the project's integer-money convention; kernel already validated/computed it (sheets-view "owns no accounting or tax math").
2. **Interpretation of "%-suffixed value"**: read as *illustrative*, not literal — chose `numberValue` (f64 fraction) + `numberFormat{type: PERCENT}` over writing a literal string like `"15%"`, since the latter (`stringValue`) is inert unless the API call uses `valueInputOption=USER_ENTERED`, which is locale-fragile. Numeric `userEnteredValue` + explicit percent format is deterministic regardless of call path.
3. **Negative/out-of-range rates**: no clamping applied — assumed upstream kernel invariant guarantees non-negative, finite rates; not re-validated here.
4. **Missing/undefined rate** (e.g., no realized cost basis, division undefined upstream): fallback is a blank cell (`CellData::default()`), not `0%` or an error string, since blank multiplies as numeric 0 and avoids asserting a false rate.
5. **Precision/display**: `"0.00%"` pattern chosen arbitrarily (two decimal places); EARS doesn't specify display precision, only that the *type* be numeric.
6. **No formula (`formulaValue`) used**: rejected the alternative of writing `=0.15` or similar as a formula string, since a plain typed number is simpler and equally satisfies "parses as a number."
7. **API surface**: assumed `google_sheets4::api` types (`CellData`/`ExtendedValue`/`CellFormat`/`NumberFormat`) as the sheets-view crate's underlying client; field name `type_` per that crate's Rust-keyword-escaping convention.