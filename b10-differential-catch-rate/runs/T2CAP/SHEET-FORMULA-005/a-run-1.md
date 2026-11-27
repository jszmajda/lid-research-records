```rust
//! Writes the `Est. Tax Rate` cell as a protected numeric-percent value.
//! @spec SHEET-FORMULA-005

use crate::sheets::{BatchUpdateRequest, Request, GridRange, CellData, ExtendedValue,
                    NumberFormat, NumberFormatType, ProtectedRange, Editors};

/// Basis points (1/100 of a percent) — kernel-side integer rate, mirroring Cents.
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct RateBps(pub i32);

#[derive(Debug)]
pub enum TaxRateError { OutOfRange(i32) }

/// Sheets stores percents as fractions (0.25 == "25%") with a percent NumberFormat.
fn to_fraction(r: RateBps) -> f64 { f64::from(r.0) / 10_000.0 }

pub fn est_tax_rate_requests(
    sheet_id: i32,
    cell: GridRange,          // single-cell range for `Est. Tax Rate`
    rate: RateBps,
    service_account_email: &str,
) -> Result<Vec<Request>, TaxRateError> {
    if !(0..=10_000).contains(&rate.0) {
        return Err(TaxRateError::OutOfRange(rate.0));
    }

    let cell_data = CellData {
        // Numeric userEnteredValue — never a string, never a leading-apostrophe literal.
        user_entered_value: Some(ExtendedValue::NumberValue(to_fraction(rate))),
        user_entered_format: Some(NumberFormat {
            type_: NumberFormatType::Percent,
            pattern: "0.00%".into(),          // renders "25.00%", parses as 0.25
        }.into()),
        ..Default::default()
    };

    Ok(vec![
        Request::UpdateCells { range: cell.clone(), rows: vec![cell_data.into()],
                               fields: "userEnteredValue,userEnteredFormat.numberFormat".into() },
        // Protection is warning_only: false — a hard lock, so a human edit is rejected
        // rather than merely flagged, keeping the multiplying formulas numeric.
        Request::AddProtectedRange(ProtectedRange {
            range: cell,
            description: "Est. Tax Rate — written by portfolio-tracker; edit the ledger config instead".into(),
            warning_only: false,
            editors: Editors { users: vec![service_account_email.to_string()],
                               domain_users_can_edit: false },
            ..Default::default()
        }),
    ])
}
```

Publisher calls `delete_existing_protected_ranges(sheet_id, cell)` before this (protection adds are not idempotent), then appends both requests to the workbook `BatchUpdateRequest` so value+format+lock land atomically in one round trip — no window where the cell is numeric but unprotected.

Assumptions invented:
1. Rate is carried kernel-side as integer basis points (`RateBps`), mirroring the Cents discipline; the requirement names no type.
2. Sheets' percent convention: `userEnteredValue` = fraction (0.25) + `PERCENT` number format. The EARS' `"%"`-suffixed spelling is treated as an illustrative alternative ("e.g."); I chose the numeric+format form because a `"%"`-suffixed *string* would go in `userEnteredValue.stringValue` and risk exactly the text-coercion failure the EARS forbids. Interpretation chosen for that reason.
3. Valid domain 0–100% (0..=10_000 bps); out-of-range is a hard error, not clamped — a silently clamped tax rate would produce wrong `Net Unrealized` numbers.
4. "Protect against manual edits" = `AddProtectedRange` with `warningOnly: false` and the writing service account as sole editor. Sheets offers no stronger lock; the owner can always unprotect, so this is best-effort, not a guarantee.
5. Protection is re-established per publish by deleting prior ranges matching this cell, since repeat runs would otherwise stack duplicates.
6. Pattern `0.00%` (two decimals) as the display default; not specified.
7. Cell location arrives as a caller-supplied `GridRange` from the tab layout module; this function does no cell-address discovery.
8. Requests are emitted, not executed — the sheets-view crate batches them; keeps this unit pure and testable, and owns no tax math (rate is an input).
9. `f64` conversion is exact here (bps ≤ 10000 / 10^4), so no rounding concern; float appears only at the API boundary.