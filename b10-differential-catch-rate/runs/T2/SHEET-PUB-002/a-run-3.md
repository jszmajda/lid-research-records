```rust
// sheets-view: single-batchUpdate tab rewrite (SHEET-PUB-002)

use serde_json::{json, Value};

pub struct TabTarget {
    pub sheet_id: i64,
    pub start_row: usize,   // first data row (0-based, below header)
    pub start_col: usize,
    pub num_cols: usize,
}

/// Cell payload for one row, already projected by the kernel.
/// Formula cells (e.g. GOOGLEFINANCE) carry `formula`, literal cells carry `value`.
pub enum Cell {
    Value(Value),
    Formula(String),
}

fn cell_data(c: &Cell) -> Value {
    match c {
        Cell::Value(v) => json!({ "userEnteredValue": { "stringValue": v.to_string() } }),
        Cell::Formula(f) => json!({ "userEnteredValue": { "formulaValue": f } }),
    }
}

/// Builds one batchUpdate request body that writes `rows` and truncates any
/// stale rows below them, in a single atomic call.
pub fn rewrite_tab_request(
    tab: &TabTarget,
    rows: &[Vec<Cell>],
    previous_row_count: usize,
) -> Value {
    let new_row_count = rows.len();
    let mut requests = Vec::new();

    // 1. Write the new window.
    requests.push(json!({
        "updateCells": {
            "rows": rows.iter().map(|r| json!({ "values": r.iter().map(cell_data).collect::<Vec<_>>() })).collect::<Vec<_>>(),
            "fields": "userEnteredValue",
            "range": {
                "sheetId": tab.sheet_id,
                "startRowIndex": tab.start_row,
                "endRowIndex": tab.start_row + new_row_count,
                "startColumnIndex": tab.start_col,
                "endColumnIndex": tab.start_col + tab.num_cols,
            }
        }
    }));

    // 2. Truncate residual tail, if any, in the same batch.
    if previous_row_count > new_row_count {
        requests.push(json!({
            "updateCells": {
                "fields": "userEnteredValue",
                "range": {
                    "sheetId": tab.sheet_id,
                    "startRowIndex": tab.start_row + new_row_count,
                    "endRowIndex": tab.start_row + previous_row_count,
                    "startColumnIndex": tab.start_col,
                    "endColumnIndex": tab.start_col + tab.num_cols,
                }
            }
        }));
    }

    json!({ "requests": requests })
}
```

Assumptions:
1. "Truncate" = clear cell content/value (empty `updateCells`, no CellData), not delete row dimensions — preserves tab formatting/frozen rows.
2. `previous_row_count` is supplied by the caller (tracked from prior publish or read via `spreadsheets.get` gridProperties); this function has no persistence of its own.
3. First-ever publish: `previous_row_count = 0`, so branch 2 never fires.
4. `rows.len() == 0` is valid: writes zero rows, still truncates full prior extent.
5. `previous_row_count < new_row_count` (data grew): truncation request omitted entirely rather than emitted as a no-op/negative range.
6. "Single batchUpdate" is interpreted literally as one `spreadsheets.batchUpdate` HTTP call carrying both requests in its `requests` array — not two separate API calls — satisfying "no half-written window."
7. GOOGLEFINANCE formula cells are passed in as `Cell::Formula` by the caller; this function is agnostic to which columns are formulas vs. literals (no accounting/tax logic here, per sheets-view's scope).
8. Column range (`start_col`/`num_cols`) is fixed per tab schema and doesn't change between publishes — only row count varies.
9. Money values render as `stringValue` placeholders in this sketch; real Cents formatting/currency NumberFormat is assumed handled elsewhere or via additional `userEnteredFormat` fields omitted here for brevity.
10. Retry/network-failure semantics (partial application if Sheets API itself errors mid-batch) are out of scope — assumed handled by an outer retry-with-full-rebuild wrapper, since the requirement only constrains the request shape, not transport failure recovery.