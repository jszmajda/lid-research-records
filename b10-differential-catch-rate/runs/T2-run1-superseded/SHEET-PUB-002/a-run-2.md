```rust
// sheets-view: single-batchUpdate tab rewrite (SHEET-PUB-002)
use google_sheets4::api::{
    BatchUpdateSpreadsheetRequest, CellData, ExtendedValue, GridCoordinate,
    GridRange, Request, RowData, UpdateCellsRequest,
};

pub struct ViewTab {
    pub sheet_id: i32,
    pub start_row: i32, // 0-indexed, first row below header/labels
}

/// Builds one BatchUpdateSpreadsheetRequest that (a) writes `new_rows`
/// starting at `tab.start_row` and (b) clears any rows beyond the new
/// data up to `previous_row_count`, as sub-requests of a single call.
pub fn rewrite_tab(
    tab: &ViewTab,
    new_rows: Vec<Vec<ExtendedValue>>,
    previous_row_count: usize,
) -> BatchUpdateSpreadsheetRequest {
    let new_count = new_rows.len() as i32;
    let mut requests = vec![Request {
        update_cells: Some(UpdateCellsRequest {
            start: Some(GridCoordinate {
                sheet_id: Some(tab.sheet_id),
                row_index: Some(tab.start_row),
                column_index: Some(0),
            }),
            rows: Some(
                new_rows
                    .into_iter()
                    .map(|r| RowData {
                        values: Some(
                            r.into_iter()
                                .map(|v| CellData { user_entered_value: Some(v), ..Default::default() })
                                .collect(),
                        ),
                    })
                    .collect(),
            ),
            fields: Some("userEnteredValue".into()),
            ..Default::default()
        }),
        ..Default::default()
    }];

    if previous_row_count as i32 > new_count {
        requests.push(Request {
            update_cells: Some(UpdateCellsRequest {
                range: Some(GridRange {
                    sheet_id: Some(tab.sheet_id),
                    start_row_index: Some(tab.start_row + new_count),
                    end_row_index: Some(tab.start_row + previous_row_count as i32),
                    start_column_index: Some(0),
                    end_column_index: None,
                }),
                fields: Some("userEnteredValue".into()),
                ..Default::default()
            }),
            ..Default::default()
        });
    }

    BatchUpdateSpreadsheetRequest { requests: Some(requests), ..Default::default() }
}
```

Assumptions (invented, not in the EARS text):
1. "single batchUpdate" = one `spreadsheets.batchUpdate` HTTP call carrying both write and truncate as sub-requests; relies on the Sheets API applying a request array as one atomic transaction to guarantee "no half-written window."
2. Truncation clears cell content (`updateCells` with empty values) rather than deleting grid rows/dimensions — avoids shifting row indices of anything anchored below (e.g. the GOOGLEFINANCE column or other tabs). Row-deletion was the rejected alternative reading of "truncate."
3. `previous_row_count` is supplied by the caller (e.g. a per-tab publish-state record), not fetched here — this function does no read-back; the marks read-back settle pass is treated as a separate concern.
4. `start_row` is a fixed per-tab constant (rows below header) known to the caller; header/label rows are untouched by this rewrite.
5. If `new_rows` is empty, the whole prior body is truncated (skip-write, truncate-all).
6. If `new_count >= previous_row_count`, no truncation sub-request is emitted — still one batchUpdate call, just fewer sub-requests.
7. Cell values arrive pre-formatted `ExtendedValue`s; this module does no accounting/money formatting, consistent with sheets-view owning no accounting math.
8. Column width truncated is unbounded (`end_column_index: None`) — clears the full row width, since the spec doesn't scope truncation to a column subset.
9. API-call failure/partial-apply handling (retry, error surfacing) is out of scope for this sketch — assumed handled by a calling publish-orchestration layer.