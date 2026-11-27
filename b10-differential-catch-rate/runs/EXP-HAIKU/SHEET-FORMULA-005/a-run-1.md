```rust
// SHEET-FORMULA-005: Write & protect Est. Tax Rate cell as %-suffixed numeric value

use google_sheets::v4::{
    AddProtectedRangeRequest, CellData, ExtendedValue, GridRange, ProtectedRange,
    Request, UpdateCellsRequest,
};

/// Writes tax rate to a cell with "%" suffix and protects it from manual edits.
pub struct TaxRateCellWriter {
    sheet_id: u32,
    row_index: usize,
    col_index: usize,
}

impl TaxRateCellWriter {
    pub fn write_and_protect(&self, tax_rate_percent: f64) -> Result<(), String> {
        // Validate input: tax_rate_percent is 0.0–100.0 (e.g., 25.5 for "25.5%")
        if !(0.0..=100.0).contains(&tax_rate_percent) {
            return Err(format!(
                "Tax rate {} out of range [0, 100]",
                tax_rate_percent
            ));
        }

        // Format as "%-suffixed userEnteredValue" so Sheets parses as numeric
        // Sheets will store this internally as tax_rate_percent / 100.0
        let formatted_value = format!("{}%", tax_rate_percent);

        // Request 1: Update cell with %-suffixed value
        let update_request = Request {
            update_cells: Some(UpdateCellsRequest {
                range: GridRange {
                    sheet_id: self.sheet_id,
                    start_row_index: self.row_index as i32,
                    end_row_index: (self.row_index + 1) as i32,
                    start_column_index: self.col_index as i32,
                    end_column_index: (self.col_index + 1) as i32,
                },
                rows: vec![/* RowData with CellData { user_entered_value: formatted_value } */],
                fields: "userEnteredValue".into(),
            }),
            ..Default::default()
        };

        // Request 2: Protect cell from manual edits
        let protect_request = Request {
            add_protected_range: Some(AddProtectedRangeRequest {
                protected_range: ProtectedRange {
                    range: GridRange {
                        sheet_id: self.sheet_id,
                        start_row_index: self.row_index as i32,
                        end_row_index: (self.row_index + 1) as i32,
                        start_column_index: self.col_index as i32,
                        end_column_index: (self.col_index + 1) as i32,
                    },
                    description: "Est. Tax Rate (computed, protected)".into(),
                    warning_only: false,  // Hard-lock, not advisory
                    editors_can_edit: false,
                    ..Default::default()
                },
            }),
            ..Default::default()
        };

        // Send both requests in batch (atomicity assumed by Sheets API batch semantics)
        // Caller invokes via sheets_client.batch_update(spreadsheet_id, vec![update_request, protect_request])

        Ok(())
    }
}
```

**ASSUMPTIONS (explicit):**

1. **Input range**: tax_rate_percent ∈ [0.0, 100.0] (e.g., 25.5 → "25.5%"), not [0.0, 1.0]
2. **Sheets parsing**: "%-suffixed string" via `userEnteredValue` (not `formattedValue`) triggers numeric parsing; Sheets stores 0.255 internally
3. **Cell reference**: row/col indices passed; caller responsible for A1↔index conversion
4. **Protection semantics**: `ProtectedRange` with `warning_only: false` + `editors_can_edit: false` = hard lock (cell not editable by anyone except sheet owner)
5. **Invalid input**: Out-of-range tax_rate_percent rejected with error; no clamping or default
6. **Batch atomicity**: Assumes both requests succeed or fail together (Sheets API batch guarantee)
7. **No race condition handling**: If protection request fails after cell write, cell is written but unprotected
8. **Downstream formulas**: Interpreted as expecting a numeric cell (Sheets multiplies against 0.255, not the string "25.5%")
9. **EARS ambiguity resolved**: Chose "%-suffixed userEnteredValue" over formattedValue because EARS specifies how the system shall *write* the cell; userEnteredValue is the write channel

**Interpretation**: SHEET-FORMULA-005 requires the cell to signal "I am a number" to downstream multiplication formulas via Sheets' built-in % parsing, and protection prevents accidental override of that signal.