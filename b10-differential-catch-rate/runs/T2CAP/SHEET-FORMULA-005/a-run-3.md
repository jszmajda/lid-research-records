```rust
// crates/sheets-view/src/tax_rate_cell.rs
// @spec SHEET-FORMULA-005

use crate::sheets::{
    BatchUpdateRequest, CellData, CellFormat, GridRange, NumberFormat, NumberFormatType,
    ProtectedRange, Request, RepeatCellRequest, AddProtectedRangeRequest, Editors, UserEnteredValue,
};

/// Tax rate carried as integer basis points (1 bp = 0.01%), matching the
/// project's no-float money discipline. 22.5% == 2250 bp.
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct RateBps(pub i32);

pub const MIN_BPS: i32 = 0;
pub const MAX_BPS: i32 = 10_000;

#[derive(Debug)]
pub enum TaxRateCellError {
    OutOfRange { got: i32 },
}

impl RateBps {
    pub fn checked(raw: i32) -> Result<Self, TaxRateCellError> {
        if (MIN_BPS..=MAX_BPS).contains(&raw) {
            Ok(RateBps(raw))
        } else {
            Err(TaxRateCellError::OutOfRange { got: raw })
        }
    }
    /// Percent-typed literal: "22.5%" — Sheets coerces to the number 0.225
    /// under a PERCENT numberFormat, so `price * rate` stays numeric.
    fn as_percent_literal(self) -> String {
        let (whole, frac) = (self.0 / 100, (self.0 % 100).abs());
        if frac == 0 { format!("{whole}%") } else { format!("{whole}.{frac:02}%") }
    }
}

/// Emits the two requests that satisfy SHEET-FORMULA-005: a percent-typed
/// value write, and an editors-restricted protection over the same cell.
pub fn tax_rate_cell_requests(
    sheet_id: i32,
    row: i32,
    col: i32,
    rate: RateBps,
    service_account_email: &str,
) -> Vec<Request> {
    let range = GridRange::single(sheet_id, row, col);
    vec![
        Request::RepeatCell(RepeatCellRequest {
            range: range.clone(),
            cell: CellData {
                user_entered_value: UserEnteredValue::StringValue(rate.as_percent_literal()),
                user_entered_format: Some(CellFormat {
                    number_format: Some(NumberFormat {
                        type_: NumberFormatType::Percent,
                        pattern: "0.00%".into(),
                    }),
                }),
            },
            fields: "userEnteredValue,userEnteredFormat.numberFormat".into(),
        }),
        Request::AddProtectedRange(AddProtectedRangeRequest {
            protected_range: ProtectedRange {
                range,
                description: "Est. Tax Rate — published by portfolio-tracker".into(),
                warning_only: false,
                editors: Editors { users: vec![service_account_email.to_string()] },
            },
        }),
    ]
}
```

Assumptions invented:
1. Rate is supplied as integer basis points (no floats anywhere), range-checked 0..=10000; out-of-range returns `Err`, no clamping, no publish.
2. "Percent-typed userEnteredValue" interpreted as a `stringValue` bearing a `%` suffix plus a PERCENT `numberFormat` — Sheets parses this to a true number. Chose this over `numberValue: 0.225` because the EARS explicitly names the `"%"`-suffixed form; the numberFormat is added so the display matches and re-entry stays numeric.
3. Protection = `addProtectedRange` with `warningOnly: false` and an explicit editors allowlist containing only the writer service account, so humans cannot overwrite with text or an operator.
4. Cell address passed in as `(sheet_id, row, col)` 0-indexed; caller (tab layout) owns where `Est. Tax Rate` lives.
5. Idempotency: caller is assumed to clear/replace existing protected ranges for this cell before applying (a repeated add would stack duplicates); not handled here.
6. Formatting: bps rendered with at most two decimals; trailing `.00` suppressed.
7. Function returns requests rather than issuing them — batching and retry belong to the sheets client; no accounting or tax math is performed here.
8. No fallback: if protection fails at the API layer, the caller should surface it as a publish failure rather than leaving an unprotected numeric cell.