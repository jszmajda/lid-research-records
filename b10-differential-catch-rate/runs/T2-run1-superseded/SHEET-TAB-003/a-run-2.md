```rust
/// sheets-view: republish pass for a single view tab.
/// @spec SHEET-TAB-003

pub struct TabId(pub String);      // assumption: sheetId/gid stringified
pub struct RowData(pub Vec<CellValue>);
pub enum CellValue { Empty, Text(String), Number(f64), Formula(String) }

pub struct PreviousExtent { pub rows: u32, pub cols: u32 } // assumption: tracked from last publish, or fetched live

pub trait SheetsClient {
    fn get_extent(&self, tab: &TabId) -> Result<PreviousExtent, SheetsError>;
    fn clear_range(&self, tab: &TabId, rows: u32, cols: u32) -> Result<(), SheetsError>;
    fn clear_basic_filter(&self, tab: &TabId) -> Result<(), SheetsError>;
    fn write_rows(&self, tab: &TabId, rows: &[RowData]) -> Result<(), SheetsError>;
    // Deliberately NO delete_filter_view / no sort-order API exposed here:
    // Filter Views are a distinct sheet resource, untouched by clear/write on the grid.
}

pub fn republish_view_tab(
    client: &impl SheetsClient,
    tab: &TabId,
    rows: &[RowData],
) -> Result<(), SheetsError> {
    // 1. Wipe prior grid contents fully (not just overwrite known rows),
    //    so any human-inserted extra rows and manual-sort ordering are discarded.
    let prev = client.get_extent(tab).unwrap_or(PreviousExtent { rows: 0, cols: 0 });
    client.clear_range(tab, prev.rows.max(rows.len() as u32), prev.cols)?;

    // 2. Basic filters live on the sheet object itself, not as a saved resource;
    //    clear explicitly or a stale filter persists across regeneration.
    client.clear_basic_filter(tab)?;

    // 3. Regenerate from kernel projection only.
    client.write_rows(tab, rows)?;

    // Saved Filter Views are never referenced above — by omission, they survive.
    Ok(())
}
```

Assumptions (invented, not in the EARS text):
1. `TabId`/`RowData`/`CellValue` shapes are placeholders; real crate likely has richer kernel-projection types.
2. "Regenerated" = full clear of the previous data extent, then rewrite — not an in-place diff/patch — so stray human rows beyond the new data's length are actually removed rather than left stale.
3. Basic filter is modeled as sheet-level state requiring an explicit clear call each republish, since it isn't implied by rewriting cell values.
4. Manual sort has no separate API surface: sort order is just row order, so it's discarded implicitly by full rewrite; no explicit "clear sort" call assumed necessary.
5. Filter Views are assumed to be a distinct persisted resource (per real Sheets API semantics) that clear/write on the grid never touches — survival is by construction/omission, not an explicit "preserve" step.
6. If `get_extent` fails (e.g., tab didn't previously exist), fallback is an empty prior extent — no error surfaced, first publish proceeds.
7. Read-only enforcement is scoped to "no mutation API besides republish is exposed by this module" — actual Sheets-level protection (e.g., protected ranges) is out of scope for this sketch.
8. Errors from clear/write are propagated, not partially retried; republish is assumed caller-retriable as a whole, not per-step.
9. Ambiguity: EARS doesn't specify whether "regenerated" clears exactly the new data's bounding box or the historical maximum; chose historical maximum (`prev.rows.max(...)`) since a smaller clear would leave orphaned human rows past the new data.