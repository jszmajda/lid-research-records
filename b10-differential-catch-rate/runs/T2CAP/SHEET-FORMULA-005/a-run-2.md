```rust
// crates/sheets-view/src/formula/tax_rate.rs
// @spec SHEET-FORMULA-005

use crate::sheets::{
    BatchUpdateRequest, CellData, GridRange, NumberFormat, NumberFormatType, ProtectedRange,
    Request, RepeatCellRequest, UserEnteredValue,
};

/// Basis points (1/100 of a percent). 2500 bps == 25.00%.
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct RateBps(pub i32);

pub const DEFAULT_RATE_BPS: RateBps = RateBps(0);
pub const MAX_RATE_BPS: i32 = 10_000;

#[derive(Debug, PartialEq)]
pub enum TaxRateError {
    OutOfRange(i32),
}

/// Clamp-free validation: reject rather than silently coerce.
pub fn validate(rate: RateBps) -> Result<RateBps, TaxRateError> {
    if rate.0 < 0 || rate.0 > MAX_RATE_BPS {
        return Err(TaxRateError::OutOfRange(rate.0));
    }
    Ok(rate)
}

/// Emit the two requests that (a) write the cell as a percent-typed number and
/// (b) protect it from manual edits. Both are in one batch so the cell is never
/// briefly writable-and-numeric in a partially applied state.
pub fn tax_rate_requests(
    sheet_id: i32,
    cell: GridRange,      // single-cell range for `Est. Tax Rate`
    rate: RateBps,
    editor_emails: &[String],
) -> Result<Vec<Request>, TaxRateError> {
    let rate = validate(rate)?;
    // Fraction-of-one, the representation Sheets multiplies numerically.
    let fraction = f64::from(rate.0) / 10_000.0;

    let write = Request::RepeatCell(RepeatCellRequest {
        range: cell.clone(),
        cell: CellData {
            // numberValue, NOT stringValue and NOT a "%"-suffixed literal:
            // a raw number plus a PERCENT numberFormat renders "25.00%" while
            // guaranteeing numeric parse. (See interpretation note.)
            user_entered_value: UserEnteredValue::Number(fraction),
            user_entered_format: Some(NumberFormat {
                type_: NumberFormatType::Percent,
                pattern: "0.00%".into(),
            }),
        },
        fields: "userEnteredValue,userEnteredFormat.numberFormat".into(),
    });

    let protect = Request::AddProtectedRange(ProtectedRange {
        range: cell,
        description: "Est. Tax Rate — written by portfolio-tracker; edits are overwritten".into(),
        warning_only: false,
        requesting_user_can_edit: false,
        editors: editor_emails.to_vec(), // service account only if empty
    });

    let _ = sheet_id; // carried in GridRange
    Ok(vec![write, protect])
}
```

Interpretation chosen: the EARS's `"%"`-suffixed example is illustrative ("e.g."), and the binding clause is "so Sheets parses it as a number." A `"25%"` string in `userEnteredValue` only parses numerically under `USER_ENTERED` input mode; a `numberValue` + PERCENT format is numeric under both modes, so I write the number and carry the percent through the format. If the project mandates literal `"%"` text, swap `UserEnteredValue::Number(fraction)` for `UserEnteredValue::String(format!("{:.2}%", rate.0 as f64 / 100.0))` and force `ValueInputOption::UserEntered`.

Assumptions invented:
1. Rate stored as integer basis points (`RateBps`), consistent with integer-Cents money discipline; no float rate in the kernel.
2. Sheets API wrapper types (`Request`, `RepeatCellRequest`, `ProtectedRange`, …) already exist in the sheets-view crate.
3. Valid range is 0..=10000 bps inclusive; out-of-range is a hard error, not a clamp — a silently clamped rate would produce wrong tax numbers.
4. Absent/None configured rate defaults to 0 bps (post-tax == pre-tax), handled by the caller, not here.
5. Protection is hard (`warningOnly: false`, `requestingUserCanEdit: false`), with an empty editor list meaning "service account only".
6. Idempotency: re-running must not stack duplicate protected ranges; caller deletes an existing protected range for this cell by id before applying (`DeleteProtectedRange`) — not shown.
7. Cell address supplied by the caller as a `GridRange`; this module does not locate the label.
8. Write and protect are issued in a single `BatchUpdateRequest` for atomicity.
9. `0.00%` display pattern is arbitrary; two decimals chosen to survive rates like 23.80%.
10. This module performs no tax math — it only transports a rate the kernel computed.