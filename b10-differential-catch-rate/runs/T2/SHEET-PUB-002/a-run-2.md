```rust
use google_sheets4::api::{
    BatchUpdateSpreadsheetRequest, CellData, GridCoordinate, Request,
    RowData as ApiRowData, UpdateCellsRequest,
};

/// One already-rendered cell for a view tab (kernel output, projected).
pub enum Cell {
    Text(String),
    Cents(i64),
    Formula(String), // e.g. GOOGLEFINANCE(...)
    Empty,
}
pub struct SheetRow(pub Vec<Cell>);

/// Rewrites the data region of `sheet_id` (below `header_rows`) with
/// `new_rows`, then clears any rows from `new_rows.len()` up through
/// `prev_row_count` so no stale tail survives. Both ops go in ONE
/// `batchUpdate` call.
pub fn rewrite_view_tab(
    sheet_id: i64,
    header_rows: u32,
    col_count: u32,
    prev_row_count: u32,
    new_rows: &[SheetRow],
) -> BatchUpdateSpreadsheetRequest {
    let write_count = new_rows.len() as u32;
    let mut requests = vec![Request {
        update_cells: Some(UpdateCellsRequest {
            rows: Some(new_rows.iter().map(to_api_row).collect()),
            fields: Some("userEnteredValue".into()),
            start: Some(GridCoordinate {
                sheet_id: Some(sheet_id),
                row_index: Some(header_rows as i32),
                column_index: Some(0),
            }),
            ..Default::default()
        }),
        ..Default::default()
    }];

    if prev_row_count > write_count {
        let clear_start = header_rows + write_count;
        let stale = (prev_row_count - write_count) as usize;
        requests.push(Request {
            update_cells: Some(UpdateCellsRequest {
                rows: Some(vec![blank_row(col_count); stale]),
                fields: Some("userEnteredValue".into()),
                start: Some(GridCoordinate {
                    sheet_id: Some(sheet_id),
                    row_index: Some(clear_start as i32),
                    column_index: Some(0),
                }),
                ..Default::default()
            }),
            ..Default::default()
        });
    }
    BatchUpdateSpreadsheetRequest { requests: Some(requests), ..Default::default() }
}

fn to_api_row(r: &SheetRow) -> ApiRowData { /* map Cell -> CellData */ ApiRowData::default() }
fn blank_row(n: u32) -> ApiRowData { ApiRowData { values: Some(vec![CellData::default(); n as usize]) } }
```

Assumptions (all invented, none stated by the EARS text):

1. "batchUpdate" = Sheets `spreadsheets.batchUpdate` (structural/cell API), not `values.batchUpdate` — needed to clear formula cells, not just values.
2. Truncation = clearing cell contents (`UpdateCellsRequest` writing empty `CellData`), not `deleteDimension`. Chose clear-not-delete so row indices of other tabs/absolute references never shift; "truncate the tail" read as "blank it out," not "remove rows from the grid."
3. `prev_row_count` (prior write's row extent) is supplied by the caller/state, not looked up here — EARS doesn't say how prior extent is tracked, so this function assumes it's already known.
4. Header rows are never touched; only the data region below them.
5. Stale rows are cleared across the full `col_count`, including the GOOGLEFINANCE formula column, since it's per-row and would otherwise reference orphaned data.
6. If `new_rows.len() >= prev_row_count`, no clear request is appended — batchUpdate still fires with just the write, satisfying "single batchUpdate" trivially.
7. "Single batchUpdate" = one HTTP call to the API, even though its `requests` vec holds up to two `Request` entries — the atomicity claim is about round-trips, not about a single `Request` struct.
8. Both `new_rows.len() == 0` and `prev_row_count == 0` are legal; function degrades to a no-op or clear-only batchUpdate.
9. Rows are rectangular (`col_count` uniform); ragged input isn't handled.
10. No retry/error handling for partial API failure — out of scope for this requirement, which only constrains request shape.