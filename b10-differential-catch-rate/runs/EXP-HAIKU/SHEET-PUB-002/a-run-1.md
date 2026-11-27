```rust
use google_sheets4::api::{BatchUpdateSpreadsheetRequest, Request};

/// Publishes a view tab by rewriting all data and truncating stale rows atomically.
/// 
/// EARS SHEET-PUB-002: Single batchUpdate writes new range and truncates tail to exact row count.
pub fn publish_view_tab(
    sheet_id: u32,
    tab_name: &str,
    rows: Vec<Vec<String>>, // Each inner Vec is one sheet row
) -> BatchUpdateSpreadsheetRequest {
    let row_count = rows.len();
    let col_count = rows.iter().map(|r| r.len()).max().unwrap_or(0);
    
    let mut requests = vec![];
    
    // Request 1: Update the data range [tab_name]!A1:Z{row_count}
    requests.push(Request {
        update_cells: Some(google_sheets4::api::UpdateCellsRequest {
            rows: Some(rows_to_cells(rows)),
            range: Some(google_sheets4::api::GridRange {
                sheet_id: Some(sheet_id),
                start_row_index: Some(0),
                end_row_index: Some(row_count as i32),
                start_column_index: Some(0),
                end_column_index: Some(col_count as i32),
            }),
            fields: Some("userEnteredValue,userEnteredFormat".to_string()),
        }),
        ..Default::default()
    });
    
    // Request 2: Delete all rows beyond row_count (truncate tail)
    // Assuming sheet has max_rows capacity; delete from row_count to max_rows
    let max_rows = 10000; // Assumption: reasonable sheet capacity
    if row_count < max_rows {
        requests.push(Request {
            delete_range: Some(google_sheets4::api::DeleteRangeRequest {
                range: Some(google_sheets4::api::GridRange {
                    sheet_id: Some(sheet_id),
                    start_row_index: Some(row_count as i32),
                    end_row_index: Some(max_rows as i32),
                    start_column_index: Some(0),
                    end_column_index: None,
                }),
                shift_dimension: Some("ROWS".to_string()),
            }),
            ..Default::default()
        });
    }
    
    BatchUpdateSpreadsheetRequest {
        requests: Some(requests),
        ..Default::default()
    }
}

fn rows_to_cells(rows: Vec<Vec<String>>) -> Vec<google_sheets4::api::RowData> {
    rows.into_iter()
        .map(|row| google_sheets4::api::RowData {
            values: Some(
                row.into_iter()
                    .map(|val| google_sheets4::api::CellData {
                        user_entered_value: Some(
                            google_sheets4::api::ExtendedValue {
                                string_value: Some(val),
                                ..Default::default()
                            }
                        ),
                        ..Default::default()
                    })
                    .collect()
            ),
            ..Default::default()
        })
        .collect()
}
```

**ASSUMPTIONS (explicit):**

1. **Sheet capacity**: Max 10,000 rows; truncation deletes beyond this threshold.
2. **Row shape**: Ragged rows (unequal column counts) are padded to max width; empty cells filled implicitly by API.
3. **Data type**: All cells are strings; numbers/formatting handled upstream.
4. **Empty tab**: If `rows.is_empty()`, publish clears all data (single delete_range from row 0).
5. **Sheet exists**: Tab identified by `sheet_id` already exists; no creation/discovery.
6. **Atomicity scope**: "Single batchUpdate" means one RPC call; Google Sheets executes requests sequentially within one batch (not strictly transactional, but atomic to callers).
7. **No headers**: Data row 1 is the first data row; no header-preservation logic.
8. **Interpretation chosen**: "Truncate tail" = DELETE_RANGE + SHIFT_ROWS (removes rows, not just clears values). This leaves "no leftover stale rows" per spec; clearing alone would leave empty rows.

**Edge cases handled:**
- Empty rows vector → clears all data.
- Ragged row widths → max column count used.
- No delete request if row_count ≥ max_rows.