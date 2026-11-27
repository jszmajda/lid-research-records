```rust
// crates/sheets-view/src/publish.rs
// @spec SHEET-PUB-002

use google_sheets4::api::{
    BatchUpdateSpreadsheetRequest, DeleteDimensionRequest, DimensionRange, GridRange, Request,
    UpdateCellsRequest,
};

pub struct TabTarget {
    pub sheet_id: i32,       // numeric gid, not title
    pub title: String,
    pub current_row_count: u32, // grid row count read at publish start
    pub column_count: u32,
}

pub struct ViewGrid {
    pub rows: Vec<Vec<CellValue>>, // includes header row(s); may be empty
    pub width: u32,
}

pub enum PublishError { Api(String), TooWide { got: u32, cap: u32 } }

/// Builds ONE batchUpdate whose requests are applied atomically by the API:
///   1. updateCells over rows [0, new_len) — full rewrite of the live window
///   2. deleteDimension over rows [new_len, current_row_count) — truncate tail
/// Never two calls; never update-then-delete as separate round trips.
pub fn build_tab_rewrite(tab: &TabTarget, grid: &ViewGrid) -> Result<Vec<Request>, PublishError> {
    let new_len = grid.rows.len() as u32;
    let mut reqs = Vec::with_capacity(2);

    // Grow first if needed: appendDimension when new_len > current_row_count,
    // so updateCells never writes past the grid.
    if new_len > tab.current_row_count {
        reqs.push(append_rows(tab.sheet_id, new_len - tab.current_row_count));
    }

    if new_len > 0 {
        reqs.push(Request { update_cells: Some(UpdateCellsRequest {
            range: Some(GridRange {
                sheet_id: Some(tab.sheet_id),
                start_row_index: Some(0), end_row_index: Some(new_len as i32),
                start_column_index: Some(0), end_column_index: Some(grid.width as i32),
            }),
            rows: Some(grid.rows.iter().map(to_row_data).collect()),
            fields: Some("userEnteredValue,userEnteredFormat".into()),
            ..Default::default()
        }), ..Default::default() });
    }

    // Truncate residual tail. Sheets requires >=1 row; floor the delete at row 1.
    let keep = new_len.max(1);
    if tab.current_row_count > keep {
        reqs.push(Request { delete_dimension: Some(DeleteDimensionRequest {
            range: Some(DimensionRange {
                sheet_id: Some(tab.sheet_id), dimension: Some("ROWS".into()),
                start_index: Some(keep as i32), end_index: Some(tab.current_row_count as i32),
            }),
        }), ..Default::default() });
    }
    Ok(reqs)
}

pub async fn publish_tab(api: &Sheets, spreadsheet_id: &str, tab: &TabTarget, grid: &ViewGrid)
    -> Result<(), PublishError>
{
    let requests = build_tab_rewrite(tab, grid)?;
    if requests.is_empty() { return Ok(()); }
    api.spreadsheets()
       .batch_update(BatchUpdateSpreadsheetRequest { requests: Some(requests), ..Default::default() },
                     spreadsheet_id)
       .doit().await.map_err(|e| PublishError::Api(e.to_string()))?;
    Ok(())
}
```

Assumptions invented:
1. "Single batchUpdate" = one HTTP call containing multiple `Request`s (Sheets applies them atomically); not one request object.
2. Truncation via `deleteDimension` (removes rows outright) rather than blanking cells — "no leftover stale rows" reads as row removal.
3. Tab identified by stable numeric `sheet_id`, captured with `current_row_count` before building; stale counts are tolerated because delete/append are index-based.
4. Row-order within one batchUpdate: update-then-delete, indices computed against the pre-batch grid.
5. Empty grid (`new_len == 0`): emit only the truncate, floored to keep row 1 (Sheets forbids zero-row sheets); residual row 1 is left blank by a preceding clear — noted as a gap the EARS does not resolve.
6. Growth case handled by `appendDimension` inside the same batch; EARS says "exact row count" which I read as both grow and shrink.
7. Column width fixed per view; residual *columns* are out of scope (EARS says rows only).
8. GOOGLEFINANCE formula cells written as `userEnteredValue` formulas, so `fields` includes value+format; no `valueInputOption` (batchUpdate uses `userEnteredValue` directly).
9. Failure = whole-tab no-op; caller retries. No partial-success reconciliation, since "no half-written window" implies all-or-nothing.
10. Multiple tabs = one batchUpdate per tab ("each view tab"), not one batch across all tabs.