# Rust Implementation Sketch: SHEET-TAB-003

```rust
use google_sheets::{Sheets, models::{FilterView, UpdateFilterViewRequest}};

/// Regenerates a read-only view tab while re-asserting saved Filter Views.
/// 
/// On republish: clears data → writes new data → restores filter views.
/// This ensures filter metadata (but not manual edits) survive the rewrite.
pub async fn republish_view_tab(
    sheets: &Sheets,
    spreadsheet_id: &str,
    sheet_id: u32,
    new_data: Vec<Vec<String>>,  // Row-major grid
) -> Result<()> {
    // 1. Capture filter views before clearing (FilterView includes ID, range, criteria)
    let saved_filters = fetch_sheet_filters(sheets, spreadsheet_id, sheet_id).await?;

    // 2. Clear all data in sheet
    sheets.clear_range(spreadsheet_id, sheet_id, "A:Z").await?;

    // 3. Write new data (overwrites manual sorts, inserted rows by design)
    let row_count = new_data.len() as u32;
    let col_count = new_data.iter().map(|r| r.len()).max().unwrap_or(1) as u32;
    sheets.write_range(
        spreadsheet_id,
        sheet_id,
        "A1",
        new_data,
    ).await?;

    // 4. Re-assert each saved filter (filter views reference by ID and persist)
    for filter in saved_filters {
        // Clamp filter range to new data bounds to skip filters that outlived their columns
        if filter.range.end_column_index <= col_count && filter.range.end_row_index <= row_count {
            sheets.update_filter_view(
                spreadsheet_id,
                sheet_id,
                filter.filter_view_id,
                filter,  // Recreate with original criteria/sort
            ).await.ok();  // Silently skip if invalid (column deleted, etc.)
        }
    }

    Ok(())
}

async fn fetch_sheet_filters(
    sheets: &Sheets,
    spreadsheet_id: &str,
    sheet_id: u32,
) -> Result<Vec<FilterView>> {
    let sheet = sheets.get_sheet(spreadsheet_id, sheet_id).await?;
    Ok(sheet.filter_views.unwrap_or_default())
}
```

## Assumptions (Explicit List)

1. **API availability**: Google Sheets API v4 (or equivalent Rust crate) with `clear_range`, `write_range`, `update_filter_view` methods.
2. **Filter View structure**: FilterView includes `filter_view_id`, `range` (start/end row/column indices), and criteria/sort config that can be re-applied.
3. **Data type**: `Vec<Vec<String>>` represents row-major grid; empty rows/cols are sparse or padded uniformly.
4. **Range clearing**: "A:Z" clears columns A–Z; unbounded columns beyond are assumed absent or ignored.
5. **Column/row bounds**: New data dimensions may differ from old; filter views referencing deleted columns are gracefully skipped (`.ok()` suppression).
6. **No row insertion recovery**: Human-inserted rows are intentionally lost; this is by-design overwrite, not append.
7. **Read-only enforcement**: Enforced via Google Sheets UI/API protections (not shown here); this code assumes external permission model.
8. **Error tolerance**: Filter view restoration errors (e.g., criteria invalid for new data) are silently ignored; core republish succeeds if data write succeeds.
9. **Filter view identity**: Filter views survive by ID across rewrites; Google Sheets assigns IDs immutably.
10. **No intermediate saves**: No checkpointing; if step 4 fails, filters may be stale, but data is already written.

## EARS Interpretation

**"re-asserts saved Sheets Filter Views so they persist across the rewrite"** → Filter Views are metadata objects stored separate from cell data; this code fetches them before clearing, then re-applies them post-write. The Sheets API treats filter views as durable objects keyed by ID, so they "persist" as long as their range is valid.

**"a basic filter, a manual sort, or a human-inserted row on a view tab is overwritten by design"** → Manual edits to the sheet itself are lost because we clear and rewrite all cells. Filter Views (which are not cell edits) are re-applied, so the user's saved filter *definitions* survive even though the *data* they filter is refreshed.

Human-inserted rows or manual column sorts are not stored as FilterView metadata; they're just cell state, so they're lost on rewrite—as intended.

---

{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key