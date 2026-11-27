```rust
/// SHEET-TAB-003: view tabs are read-only & regenerated; only saved
/// Sheets FilterView objects survive republish. Basic filters, manual
/// sorts, and human-inserted rows are wiped by full-range overwrite.

pub struct ViewTab {
    pub sheet_id: i64,
    pub header: Vec<String>,
    pub data_range: GridRange, // A1-independent, sheet-relative
}

pub trait SheetsClient {
    fn get_filter_views(&self, spreadsheet_id: &str, sheet_id: i64) -> Vec<FilterView>;
    fn get_basic_filter(&self, spreadsheet_id: &str, sheet_id: i64) -> Option<BasicFilter>;
    fn clear_basic_filter(&self, spreadsheet_id: &str, sheet_id: i64) -> Result<(), PublishError>;
    fn clear_range(&self, spreadsheet_id: &str, range: &GridRange) -> Result<(), PublishError>;
    fn write_values(&self, spreadsheet_id: &str, sheet_id: i64, header: &[String], rows: &[Vec<CellValue>]) -> Result<(), PublishError>;
}

/// Regenerates one view tab's content. Never touches sheet identity or
/// FilterView objects — those live outside the data range we overwrite,
/// so they survive untouched. Basic filter is explicitly stripped since
/// it is not a "saved Filter View" per the spec's distinction.
pub fn republish_tab(
    client: &dyn SheetsClient,
    spreadsheet_id: &str,
    tab: &ViewTab,
    rows: Vec<Vec<CellValue>>,
) -> Result<(), PublishError> {
    if client.get_basic_filter(spreadsheet_id, tab.sheet_id).is_some() {
        client.clear_basic_filter(spreadsheet_id, tab.sheet_id)?;
    }
    client.clear_range(spreadsheet_id, &tab.data_range)?;
    client.write_values(spreadsheet_id, tab.sheet_id, &tab.header, &rows)?;

    debug_assert!(
        !client.get_filter_views(spreadsheet_id, tab.sheet_id).is_empty()
            || rows.is_empty(),
        "saved FilterViews must survive republish untouched"
    );
    Ok(())
}
```

Assumptions invented:
- `FilterView`/`BasicFilter`/`GridRange`/`CellValue`/`PublishError` are opaque types from a Sheets-API wrapper crate; not defined here.
- "Saved Filter Views" = Google Sheets API `FilterView` objects (persisted, keyed by `filterViewId`), distinct from the single per-sheet `basicFilter`. This is the load-bearing ambiguity resolution: the EARS text names both "Filter Views" (preserved) and "a basic filter" (destroyed) as different concepts, matching the Sheets API's actual object model.
- Manual sort and human-inserted rows have no persisted API object to check for — they're implicitly destroyed as a side effect of `clear_range` + `write_values` overwriting the full data range; no explicit code models them.
- FilterViews are preserved automatically (not re-created) because they reference the sheet by ID/range, not by cell content, and we never delete/recreate the sheet — only its data range is cleared and rewritten.
- Basic filter is unconditionally cleared rather than reapplied, since the spec lists it among overwritten artifacts.
- Fallback on empty `rows`: header is still written, data range cleared to empty; not treated as an error.
- No retry/backoff logic modeled — `PublishError` propagates to caller; that policy is out of scope for this EARS.
- The debug assertion is best-effort guardrail only, not enforced in release builds.