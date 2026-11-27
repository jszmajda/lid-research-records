```rust
use google_sheets1::{Request, UpdateCellsRequest, CellData, ExtendedValue, 
    AddProtectedRangeRequest, ProtectedRange, GridRange};

/// Write Est. Tax Rate cell formatted as protected percentage for numeric evaluation.
/// Satisfies SHEET-FORMULA-005: userEnteredValue formatted as "X.XX%", cell protected
/// against manual edits so dependent formulas multiply it numerically.
pub async fn write_protected_tax_rate(
    sheets_api: &google_sheets1::SpreadsheetService,
    spreadsheet_id: &str,
    sheet_id: u32,
    row_idx: u32,    // 0-indexed row of Est. Tax Rate cell
    col_idx: u32,    // 0-indexed column of Est. Tax Rate cell
    tax_rate: f64,   // normalized decimal, e.g., 0.25 for 25%
) -> Result<(), Box<dyn std::error::Error>> {
    
    // Clamp tax_rate to valid range [0.0, 1.0]
    let clamped = tax_rate.max(0.0).min(1.0);
    
    // Format as percent-suffixed string for Sheets userEnteredValue
    let percent_value = format!("{:.2}%", clamped * 100.0);
    
    // Request 1: Update cell with percent-formatted value
    let update_cell_req = Request {
        update_cells: Some(UpdateCellsRequest {
            data: vec![google_sheets1::RowData {
                values: Some(vec![CellData {
                    user_entered_value: Some(ExtendedValue {
                        string_value: Some(percent_value),
                        ..Default::default()
                    }),
                    ..Default::default()
                }]),
                ..Default::default()
            }],
            range: Some(GridRange {
                sheet_id: Some(sheet_id),
                start_row_index: Some(row_idx),
                end_row_index: Some(row_idx + 1),
                start_column_index: Some(col_idx),
                end_column_index: Some(col_idx + 1),
            }),
            ..Default::default()
        }),
        ..Default::default()
    };
    
    // Request 2: Protect cell range against edits
    let protect_req = Request {
        add_protected_range: Some(AddProtectedRangeRequest {
            protected_range: Some(ProtectedRange {
                range: Some(GridRange {
                    sheet_id: Some(sheet_id),
                    start_row_index: Some(row_idx),
                    end_row_index: Some(row_idx + 1),
                    start_column_index: Some(col_idx),
                    end_column_index: Some(col_idx + 1),
                }),
                description: Some("Est. Tax Rate - auto-calculated".into()),
                warning_only: Some(false),  // Hard enforce; reject manual edits
                ..Default::default()
            }),
            ..Default::default()
        }),
        ..Default::default()
    };
    
    sheets_api.spreadsheets()
        .batch_update(
            google_sheets1::BatchUpdateSpreadsheetRequest {
                requests: Some(vec![update_cell_req, protect_req]),
                ..Default::default()
            },
            spreadsheet_id,
        )
        .doit()
        .await?;
    
    Ok(())
}
```

**Assumptions & Interpretations:**

1. **Tax rate type:** Input is normalized decimal (0.0–1.0); 0.25 = 25%. Clamped to [0.0, 1.0] for safety.
2. **Format precision:** Percent string uses 2 decimal places (e.g., "25.50%").
3. **userEnteredValue:** Passing string "%"-suffixed value to Sheets API; Sheets auto-recognizes as percentage and parses numerically for formula evaluation.
4. **Protection enforcement:** `warning_only=false` enforces hard block on manual edits; cells are locked and reject writes outside API updates.
5. **Row/column indexing:** 0-indexed; caller converts from A1 notation (e.g., D5 → row 4, col 3).
6. **Single cell:** Function writes one cell; loop externally if multiple cells needed.
7. **Boundary handling:** Negative/overflow rates clamp silently; no error thrown for out-of-range input.
8. **Dependency:** Assumes dependent formulas reference this cell by address and multiply the value; Sheets treats "%"-formatted string as numeric, not text.
9. **API client:** Requires `google-sheets1` crate and authenticated `SpreadsheetService`.
10. **Interpretation of ambiguity:** "percent-typed userEnteredValue" chosen as string suffix "%", not numeric formatting—this matches Sheets' behavior of recognizing "%"-suffixed user input as percentage literals for formula math.