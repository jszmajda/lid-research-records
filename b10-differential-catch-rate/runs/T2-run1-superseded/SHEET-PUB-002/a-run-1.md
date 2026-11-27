## Implementation sketch

```rust
use serde_json::{json, Value};

/// Presentation-ready cell value (sheets-view does no accounting/tax math).
#[derive(Clone)]
pub enum CellValue { Str(String), Num(f64), Formula(String), Empty }

pub type Row = Vec<CellValue>;

/// Inputs needed to rewrite one tab atomically.
pub struct TabRewrite<'a> {
    pub sheet_id: i64,        // numeric grid sheetId, not the tab title
    pub start_row: i64,       // 0-indexed first data row (below any header)
    pub new_rows: &'a [Row],
    pub prior_row_count: i64, // rows this tab held after its last publish
}

fn cell_to_json(c: &CellValue) -> Value {
    match c {
        CellValue::Str(s) => json!({ "userEnteredValue": { "stringValue": s } }),
        CellValue::Num(n) => json!({ "userEnteredValue": { "numberValue": n } }),
        CellValue::Formula(f) => json!({ "userEnteredValue": { "formulaValue": f } }),
        CellValue::Empty => json!({}),
    }
}

fn row_to_json(r: &Row) -> Value {
    json!({ "values": r.iter().map(cell_to_json).collect::<Vec<_>>() })
}

/// Builds the `requests` array for ONE `spreadsheets.batchUpdate` call:
/// an UpdateCells writing new_rows, plus (if the tab shrank) an UpdateCells
/// that blanks the residual tail. Both go in the same call so the API
/// applies them as one atomic operation — no partial state is observable.
pub fn build_rewrite_requests(t: &TabRewrite) -> Vec<Value> {
    let new_len = t.new_rows.len() as i64;
    let end_row = t.start_row + new_len;
    let mut reqs = vec![json!({
        "updateCells": {
            "range": { "sheetId": t.sheet_id, "startRowIndex": t.start_row, "endRowIndex": end_row },
            "rows": t.new_rows.iter().map(row_to_json).collect::<Vec<_>>(),
            "fields": "userEnteredValue"
        }
    })];

    if t.prior_row_count > new_len {
        reqs.push(json!({
            "updateCells": {
                "range": { "sheetId": t.sheet_id, "startRowIndex": end_row,
                           "endRowIndex": t.start_row + t.prior_row_count },
                "fields": "userEnteredValue" // no "rows" => blanks cells
            }
        }));
    }
    reqs
}
```

Caller wraps this `Vec<Value>` as the single `requests` field of one `BatchUpdateSpreadsheetRequest` and issues one HTTP call.

## Assumptions

1. Sheets API v4 `spreadsheets.batchUpdate` (structural `Request`s), not `values.batchUpdate` — needed to combine write + truncate atomically.
2. "Single batchUpdate" = one HTTP call with multiple `Request` entries, relying on the API's own atomicity guarantee (unverified here, external dependency).
3. `prior_row_count` is tracked/passed in externally (e.g., read back from the sheet or cached from last publish); this module does no accounting, only projection.
4. Header row is separate/static, not part of `new_rows`/truncation.
5. `new_rows` empty is valid (publishes zero data rows, still truncates prior tail).
6. If tab grew (`prior_row_count <= new_len`), truncation request is omitted (no stale rows exist).
7. Truncation blanks cell values via empty `fields`/no `rows`, rather than deleting dimensions, to avoid resizing GOOGLEFINANCE-bearing columns.
8. Cell values arrive pre-formatted (strings/numbers/formula strings); no numeric/currency conversion here.