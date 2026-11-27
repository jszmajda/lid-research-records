```rust
// sheets-view: one tab = one batchUpdate. No accounting math here.
pub struct TabPlan {
    pub sheet_id: i32,
    pub rows: Vec<RowData>,      // row 0 = header; every row padded to `width`
    pub width: i32,
    pub current_rows: i32,       // gridProperties.rowCount read at plan time
    pub current_cols: i32,
}

pub fn rewrite_tab(p: &TabPlan) -> BatchUpdateSpreadsheetRequest {
    let target = (p.rows.len() as i32).max(1); // Sheets forbids a 0-row grid
    let mut reqs = Vec::new();

    // 1. grow first, so the write can never run past the grid
    if p.current_rows < target {
        reqs.push(Request::AppendDimension { sheet_id: p.sheet_id, dimension: Rows,
                                             length: target - p.current_rows });
    }
    if p.current_cols < p.width {
        reqs.push(Request::AppendDimension { sheet_id: p.sheet_id, dimension: Columns,
                                             length: p.width - p.current_cols });
    }
    // 2. write the whole window; `fields` clears anything not supplied
    reqs.push(Request::UpdateCells {
        start: GridCoordinate { sheet_id: p.sheet_id, row_index: 0, column_index: 0 },
        rows: p.rows.clone(),
        fields: "userEnteredValue,userEnteredFormat,note".into(),
    });
    // 3. truncate the residual tail to the exact row count
    let grown = p.current_rows.max(target);
    if grown > target {
        reqs.push(Request::DeleteDimension { sheet_id: p.sheet_id, dimension: Rows,
                                             start_index: target, end_index: grown });
    }
    if p.current_cols > p.width {
        reqs.push(Request::DeleteDimension { sheet_id: p.sheet_id, dimension: Columns,
                                             start_index: p.width, end_index: p.current_cols });
    }
    BatchUpdateSpreadsheetRequest { requests: reqs, ..Default::default() }
}

pub async fn publish(api: &Sheets, book: &str, p: &TabPlan) -> Result<(), PublishError> {
    api.batch_update(book, rewrite_tab(p)).await?; // no partial fallback: all-or-nothing
    Ok(())
}
```

Interpretation chosen: "single batchUpdate" = atomicity mechanism — grow/write/truncate are ordered requests in one call, never separate API calls, and no retry path writes a subset. Truncation = `DeleteDimension` (removes rows outright) rather than blanking, so no stale formatting or leftover GOOGLEFINANCE formulas survive.

Assumptions invented:
- Row/column counts come from a caller-supplied snapshot (`current_rows/current_cols`); a concurrent human edit between read and write is out of scope.
- Rows are pre-padded to uniform `width` by the projector; short rows would otherwise leave stale trailing cells.
- Header row counts toward "exact row count"; empty result set = header only.
- Empty grid clamped to 1 row (API minimum) rather than deleting the sheet.
- Column tail also truncated (requirement says rows; symmetry assumed).
- `fields` mask includes format+note so stale styling is cleared; conditional formats, filters, and frozen-row settings are preserved and not managed here.
- Cents already rendered to display strings/values upstream; price column emitted as `formulaValue`.
- Errors propagate; caller may re-run the whole publish — idempotent by construction.