```rust
/// Rewrites one view tab in a single spreadsheets.batchUpdate call:
/// writes the new data range, then clears any rows left over from a
/// previous publish that were longer than the new content.
pub fn build_tab_rewrite(
    grid_id: i64,          // tab's sheetId (gid)
    start_row: i32,        // 0-indexed first data row (below header)
    col_count: i32,        // fixed column width for this tab's schema
    new_rows: &[Vec<CellValue>],
    previous_row_count: i32, // rows written by the last publish of this tab
) -> BatchUpdateSpreadsheetRequest {
    let new_row_count = new_rows.len() as i32;
    let mut requests = Vec::with_capacity(2);

    requests.push(Request::UpdateCells(UpdateCellsRequest {
        range: GridRange {
            sheet_id: grid_id,
            start_row_index: Some(start_row),
            end_row_index: Some(start_row + new_row_count),
            start_column_index: Some(0),
            end_column_index: Some(col_count),
        },
        rows: new_rows.iter().map(to_row_data).collect(),
        fields: "userEnteredValue,userEnteredFormat".into(),
    }));

    if previous_row_count > new_row_count {
        requests.push(Request::UpdateCells(UpdateCellsRequest {
            range: GridRange {
                sheet_id: grid_id,
                start_row_index: Some(start_row + new_row_count),
                end_row_index: Some(start_row + previous_row_count),
                start_column_index: Some(0),
                end_column_index: Some(col_count),
            },
            rows: vec![], // empty RowData => clears userEnteredValue in range
            fields: "userEnteredValue".into(),
        }));
    }

    BatchUpdateSpreadsheetRequest {
        requests,
        include_spreadsheet_in_response: Some(false),
        response_ranges: None,
    }
}
// Caller: one `sheets.spreadsheets().batch_update(req, spreadsheet_id).doit().await?`
// per tab — the two Requests above execute atomically as one API call.
```

Assumptions:
1. "Tab" = one grid sheet identified by numeric `grid_id` (gid); tab discovery/creation is out of scope here.
2. `previous_row_count` is tracked state from the last publish (e.g. in a per-tab manifest), not re-derived from live sheet metadata — cheaper and avoids a read-before-write race; if untracked, caller must fetch `gridProperties.rowCount` first.
3. Truncation means clearing cell *content* (`userEnteredValue`) in stale rows, not shrinking sheet dimensions via `deleteDimension` — preserves frozen rows/formatting/row height set by the user.
4. Interpreted "single batchUpdate" as one `spreadsheets.batchUpdate` HTTP call carrying multiple `Request` entries (Sheets API batches requests atomically server-side), not one `Request` object — this is what "no half-written window" requires.
5. `new_row_count == 0` (empty dataset): still issue the write request with zero rows and let the tail-clear branch handle everything ≤ `previous_row_count`; guarded by the `if` so no no-op empty request is sent.
6. `previous_row_count < new_row_count` (growth case): no truncation request needed; only the write covers the full new range.
7. Column width (`col_count`) is fixed per tab schema (including the GOOGLEFINANCE formula column), so clearing only needs `start_column_index..col_count`, not open-ended.
8. Fields mask `userEnteredValue,userEnteredFormat` on write assumes formats are re-sent each publish (idempotent); tail-clear omits format to avoid stripping banding/borders on now-empty rows.