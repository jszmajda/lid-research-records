```rust
// crates/sheets-view/src/publish.rs
// @spec SHEET-PUB-002

use google_sheets4::api::{
    BatchUpdateSpreadsheetRequest, DeleteDimensionRequest, DimensionRange, GridCoordinate,
    Request, RowData, UpdateCellsRequest,
};

pub struct TabTarget {
    pub sheet_id: i32,        // numeric sheetId, not title (batchUpdate is id-addressed)
    pub current_row_count: u32, // grid row count read at plan time
    pub column_count: u32,
}

pub struct ViewGrid {
    pub rows: Vec<RowData>, // header row included by the caller, already projected
}

#[derive(Debug, thiserror::Error)]
pub enum PublishError {
    #[error("view exceeds sheet column width: {0} > {1}")]
    TooWide(u32, u32),
    #[error("sheets api: {0}")]
    Api(String),
}

/// Build the *single* batchUpdate that makes `tab` exactly `grid`.
/// Two requests, one atomic call: overwrite the new window, then delete the tail.
pub fn build_rewrite(
    tab: &TabTarget,
    grid: &ViewGrid,
    fields: &str, // e.g. "userEnteredValue,userEnteredFormat"
) -> Result<BatchUpdateSpreadsheetRequest, PublishError> {
    let new_len = grid.rows.len() as u32;
    let mut requests = Vec::with_capacity(2);

    // 1. Write rows [0, new_len). Absent for an empty view.
    if new_len > 0 {
        requests.push(Request {
            update_cells: Some(UpdateCellsRequest {
                start: Some(GridCoordinate {
                    sheet_id: Some(tab.sheet_id),
                    row_index: Some(0),
                    column_index: Some(0),
                }),
                rows: Some(grid.rows.clone()),
                fields: Some(fields.to_string()),
                ..Default::default()
            }),
            ..Default::default()
        });
    }

    // 2. Truncate residual tail [new_len, current_row_count).
    // Sheets forbids a zero-row grid, so always keep >= 1 row.
    let keep = new_len.max(1);
    if tab.current_row_count > keep {
        requests.push(Request {
            delete_dimension: Some(DeleteDimensionRequest {
                range: Some(DimensionRange {
                    sheet_id: Some(tab.sheet_id),
                    dimension: Some("ROWS".into()),
                    start_index: Some(keep as i32),
                    end_index: Some(tab.current_row_count as i32),
                }),
            }),
            ..Default::default()
        });
    }
    // Growth beyond current_row_count needs no AppendDimension: updateCells
    // auto-expands the grid. (Assumption; see list.)

    Ok(BatchUpdateSpreadsheetRequest {
        requests: Some(requests),
        include_spreadsheet_in_response: Some(false),
        ..Default::default()
    })
}

/// Exactly one API round-trip per tab. Caller loops tabs; failure of one tab
/// leaves that tab untouched, never half-written.
pub async fn publish_tab(
    api: &impl SheetsApi,
    spreadsheet_id: &str,
    tab: &TabTarget,
    grid: &ViewGrid,
) -> Result<(), PublishError> {
    let req = build_rewrite(tab, grid, "userEnteredValue,userEnteredFormat")?;
    if req.requests.as_ref().map_or(true, |r| r.is_empty()) {
        return Ok(()); // no-op: empty view, already-minimal tab
    }
    api.batch_update(spreadsheet_id, req).await.map_err(PublishError::Api)
}
```

Interpretation chosen: "single batchUpdate" = one HTTP call **per tab** (atomic per tab), not one call for the whole workbook. Sheets applies a batchUpdate's requests atomically, so write+truncate land together or not at all — that is what "no half-written window" buys. A workbook-wide single call would also satisfy the text, but the phrase "rewrite *each* view tab as a single batchUpdate" scopes atomicity to the tab.

Assumptions invented:
1. `TabTarget.sheet_id` numeric and `current_row_count` are known from a prior spreadsheet metadata read; SHEET-PUB-002 does not say where they come from.
2. Truncation = `deleteDimension` on ROWS (removes rows) rather than clearing values in place. "Exact row count" reads as grid dimension, not blanked cells.
3. Sheets rejects a 0-row grid, so `keep = max(new_len, 1)`; an empty view leaves one residual row rather than erroring.
4. Empty view (`rows.is_empty()`) emits no updateCells, only truncation — no error.
5. Growth: `updateCells` implicitly expands rows; no `appendDimension` emitted. If the target API rejects out-of-grid writes, an `AppendDimensionRequest` must precede request 1.
6. `fields` mask defaults to value+format; formulas (the GOOGLEFINANCE column) travel as `userEnteredValue` formula strings.
7. Column overflow (`TooWide`) is declared but not checked here — column truncation is out of scope for this EARS.
8. No retry/backoff policy; caller owns transient-failure retry (safe: the operation is idempotent).
9. Frozen header rows / conditional formats attached below `keep` are collateral damage of `deleteDimension`; assumed absent.
10. `SheetsApi` is an injected trait for testability; not defined here.