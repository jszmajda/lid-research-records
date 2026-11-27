```rust
/// One EARS-SHEET-PUB-002 publish = exactly one Sheets `batchUpdate` call
/// containing (a) an UpdateCells for the new window and, only if the
/// previous publish was larger, (b) an UpdateCells that clears the
/// residual tail. Both requests target the same sheetId, so the API
/// applies them as one atomic transaction — no half-written window is
/// ever observable.

#[derive(Clone, Debug)]
pub enum CellValue { Empty, Text(String), Number(i64 /* Cents where applicable */), Formula(String) }

pub struct GridRange { pub sheet_id: i64, pub start_row: i32, pub end_row: i32, pub start_col: i32, pub end_col: i32 }
pub struct UpdateCellsReq { pub range: GridRange, pub rows: Vec<Vec<CellValue>>, pub fields: &'static str }
pub enum Request { UpdateCells(UpdateCellsReq) }
pub struct BatchUpdate { pub requests: Vec<Request> }

/// `prev_extent` = (row_count, col_count) from the last successful publish
/// of this tab, supplied by the caller (sheets-view holds no accounting
/// state, only its own last-write bookkeeping).
pub fn build_tab_publish(
    tab_id: i64,
    rows: &[Vec<CellValue>],
    prev_extent: (i32, i32),
) -> BatchUpdate {
    let new_rows = rows.len() as i32;
    let new_cols = rows.iter().map(|r| r.len()).max().unwrap_or(0) as i32;
    let (prev_rows, prev_cols) = prev_extent;

    let mut requests = vec![Request::UpdateCells(UpdateCellsReq {
        range: GridRange { sheet_id: tab_id, start_row: 0, end_row: new_rows, start_col: 0, end_col: new_cols },
        rows: rows.to_vec(),
        fields: "userEnteredValue,userEnteredFormat",
    })];

    // Truncate stale tail left by a previously-larger publish.
    if prev_rows > new_rows || prev_cols > new_cols {
        requests.push(Request::UpdateCells(UpdateCellsReq {
            range: GridRange {
                sheet_id: tab_id,
                start_row: new_rows.min(prev_rows),
                end_row: prev_rows.max(new_rows),
                start_col: 0,
                end_col: prev_cols.max(new_cols),
            },
            rows: vec![],       // empty rows + this fields mask clears cells
            fields: "userEnteredValue",
        }));
    }

    BatchUpdate { requests }
}
```

Assumptions invented:
1. `prev_extent` (previous row/col count) is tracked by sheets-view itself and passed in — the crate owns no accounting/tax math but must own enough write-state to know what to truncate.
2. Truncation clears cell *values* (`UpdateCells` with empty rows) rather than `deleteDimension`, to avoid shifting grid structure or breaking references from other tabs/sheets.
3. "Single batchUpdate" = one `spreadsheets.batchUpdate` HTTP call with an ordered `requests` array (≤2 entries here); atomicity is delegated to the Sheets API's own request-array semantics.
4. GridRange end indices are exclusive (API convention).
5. If new extent ≥ previous in both dimensions (growth-only), no truncation request is emitted — no stale tail exists.
6. Zero-row publish (`rows` empty) still emits the write request (0×0 range) plus a full-clear truncation over the entire previous extent.
7. `tab_id` (numeric sheetId) is already resolved upstream; this function isn't responsible for tab-name→id lookup.
8. GOOGLEFINANCE formula cells are re-emitted as `CellValue::Formula` on every publish (idempotent overwrite), since the requirement treats the whole tab body as one rewritten range, not the formula column as persistent/exempt.
9. On API rejection, the caller retries the whole `BatchUpdate` (no partial-request replay), preserving the no-half-written-window guarantee.