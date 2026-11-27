```rust
use google_sheets4::api::{
    BatchUpdateSpreadsheetRequest, Request, DeleteDimensionRequest,
    DimensionRange, UpdateValuesRequest,
};

/// SHEET-PUB-002: Atomically rewrite tab—single batchUpdate, write new range, 
/// truncate tail to exact row count, no half-written window, no stale rows
pub async fn rewrite_view_tab(
    client: &google_sheets4::Client,
    spreadsheet_id: &str,
    sheet_name: &str,
    sheet_id: u32,
    new_data: Vec<Vec<String>>,
) -> Result<(), Box<dyn std::error::Error>> {
    let row_count = new_data.len() as i32;
    let mut requests = vec![];

    // Write phase: push new data from A1
    if row_count > 0 {
        let values = new_data
            .iter()
            .map(|row| {
                row.iter()
                    .map(|s| json!(s.clone()))
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        requests.push(Request::UpdateValuesRequest(Box::new(
            UpdateValuesRequest {
                range: format!("'{}'!A1", sheet_name),
                values: Some(values),
                major_dimension: Some("ROWS".to_string()),
                ..Default::default()
            },
        )));
    }

    // Truncate phase: delete rows from (row_count) to sheet end
    requests.push(Request::DeleteDimensionRequest(Box::new(
        DeleteDimensionRequest {
            range: Some(DimensionRange {
                sheet_id: Some(sheet_id as i32),
                dimension: Some("ROWS".to_string()),
                start_index: Some(row_count),
                end_index: None, // none = to sheet end
            }),
        },
    )));

    client
        .spreadsheets()
        .batch_update(
            BatchUpdateSpreadsheetRequest {
                requests: Some(requests),
                ..Default::default()
            },
            spreadsheet_id,
        )
        .await?;

    Ok(())
}
```

**ASSUMPTIONS (all invented):**
1. Data type: `Vec<Vec<String>>` (rectangular 2D strings, ragged arrays OK).
2. Sheet identified by both `sheet_name` (A1-notation escaping) and `sheet_id` (numeric).
3. Write always from A1; no offset or partial-range writes.
4. Empty `new_data` (len=0) → delete all rows (clear sheet).
5. Row count is *only* metric—columns not truncated.
6. `DeleteDimensionRequest` with `end_index=None` deletes to end-of-sheet.
7. Single `batchUpdate` call is atomic (satisfies "no half-written window").
8. `google_sheets4` crate API surface; error via `Result<T, Box<Error>>`.
9. Sheet exists, is writable, client authenticated.
10. No cell-value validation (caller formats strings).
11. Columns persist across writes—only row tail cleared.

**INTERPRETATION CHOICE:**
"Truncates the residual tail to the exact row count" = delete all rows indexed ≥ `new_data.len()`. This makes the sheet's row count equal to the data's row count. Alternative (truncate columns) rejected: requirement explicitly says "row count," not cell count.