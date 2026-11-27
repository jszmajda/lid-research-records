# Rust Implementation Sketch: SHEET-FORMULA-005

```rust
use google_sheets4::api::{CellData, ExtendedValue, NumberFormat, CellFormat, GridRange, ProtectedRange};

/// Write `Est. Tax Rate` cell with percent-typed value and read-only protection.
/// 
/// # Arguments
/// * `tax_rate`: Decimal (0.0–1.0); clamped to [0, 1] if out of range
/// * `sheet_id`: Google Sheets sheet ID (from metadata)
/// * `row`, `col`: 0-indexed cell coordinates
///
/// Returns (cell_update, protection_spec) for batch request
pub fn tax_rate_protected_cell(
    tax_rate: f64,
    sheet_id: i32,
    row: i32,
    col: i32,
) -> (CellData, ProtectedRange) {
    // Clamp invalid input to [0, 1]
    let clamped = tax_rate.clamp(0.0, 1.0);
    
    // Format as percentage string (e.g., "25%" for 0.25)
    let pct_value = format!("{}%", (clamped * 100).round() as u32);
    
    // Cell write: stringValue with PERCENT format forces Sheets to parse as number
    let cell = CellData {
        user_entered_value: Some(ExtendedValue {
            string_value: Some(pct_value),
            ..Default::default()
        }),
        user_entered_format: Some(CellFormat {
            number_format: Some(NumberFormat {
                type_: Some("PERCENT".to_string()),
                pattern: Some("0%".to_string()), // Display as "25%", not "0.25"
            }),
            ..Default::default()
        }),
        ..Default::default()
    };
    
    // Protection: hard lock (not warning-only) on this single cell
    let protection = ProtectedRange {
        range: Some(GridRange {
            sheet_id: Some(sheet_id),
            start_row_index: Some(row),
            end_row_index: Some(row + 1),
            start_column_index: Some(col),
            end_column_index: Some(col + 1),
        }),
        description: Some("Est. Tax Rate — system-written, read-only".to_string()),
        warning_only: Some(false), // Hard protection
        requesting_user_can_edit: None, // Owner can always edit
        ..Default::default()
    };
    
    (cell, protection)
}
```

## Assumptions (Explicit List)

1. **Tax rate domain**: Input is clamped to [0, 1]; <0 or >1 treated as user error, not panic.
2. **Percentage display precision**: Rounded to nearest integer (no decimals); e.g., 0.251 → "25%".
3. **Google Sheets API v4**: Using `google-sheets4` crate; assumes batch request context (caller assembles `UpdateCellsRequest` + `AddProtectedRangeRequest`).
4. **String-formatted percent**: `userEnteredValue` is a string `"%"`-suffixed; Sheets' PERCENT number format parses it to numeric internally.
5. **Protection semantics**: `warningOnly: false` enforces hard lock; only sheet owner can edit (not applicable to protected cells via normal flow).
6. **Cell pre-existence**: Cell coordinates are valid and writable; no row-auto-insert or column-create needed.
7. **No concurrent protection**: Single protection request; caller handles merging with other sheet updates.
8. **No error handling**: Invalid Sheets metadata, API failures, or quota exhaustion not caught (caller's responsibility).

## Interpretation

The requirement explicitly calls for a **string value suffixed `"%"`** in `userEnteredValue` + PERCENT cell formatting. This dual approach ensures Sheets' formula engine sees a number (not text), preventing the "$Est. Unrealized Tax$ = $Est. Tax Rate$ × $amount$" formula from treating the rate as a string or encountering an operator overload.