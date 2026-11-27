Assumptions I had to invent (stated up front since the harness consumes this as data):

1. Sheets access goes through a `SheetsClient` trait wrapping the real API (e.g. `google-sheets4`), so the sketch is testable without network I/O.
2. Tabs are identified by a stable `tab_name: &str`; the caller resolves it to a numeric `sheet_id` (creating the tab if absent — not shown).
3. "Regenerated" = full clear-then-rewrite of the tab's data range each publish, not an incremental diff. This is the only reading that makes "manual sort / inserted row is overwritten" true unconditionally.
4. Saved **Filter Views** are Sheets API `FilterView` objects, distinct from a **basic filter** (`BasicFilter`, one per sheet) and from row/column sort metadata. Because clearing/rewriting cell values never touches `FilterView` objects, "survival" requires no special-case code — only that we never emit a `DeleteFilterViewRequest`. I made this an explicit non-action, asserted via a comment and a debug_assert on the request builder never including that variant.
5. Read-only is enforced softly via a `ProtectedRange` (`warning_only: true`) covering the full data grid, editors restricted to the publishing service account — Sheets can't hard-block a sheet owner, so "read-only" is best-effort, not a hard guarantee.
6. Boundary case: if kernel output is empty, we still clear the full previous range (so a stale human row isn't left behind) and write zero data rows.
7. Cents are pre-formatted to display strings by the caller; this module only places them.

```rust
/// Republishes one view tab: full clear + rewrite. Only FilterView objects
/// (never touched here) persist across calls; BasicFilter, sort order, and
/// any human-inserted rows are discarded because the whole grid is replaced.
pub struct ViewRow {
    pub cells: Vec<String>,       // pre-formatted Cents / labels
    pub finance_formula: Option<String>, // e.g. =GOOGLEFINANCE(...)
}

pub trait SheetsClient {
    fn clear_range(&mut self, sheet_id: i64, a1_range: &str) -> Result<(), SheetsError>;
    fn write_rows(&mut self, sheet_id: i64, start_row: u32, rows: &[ViewRow]) -> Result<(), SheetsError>;
    fn set_protected_range(&mut self, sheet_id: i64, warning_only: bool) -> Result<(), SheetsError>;
    // Intentionally NO delete_filter_view / delete_basic_filter methods exist
    // on this trait: republish must never target FilterView objects.
}

pub fn republish_tab(
    client: &mut dyn SheetsClient,
    sheet_id: i64,
    max_prior_rows: u32, // high-water mark, so stray human rows are cleared too
    rows: &[ViewRow],
) -> Result<(), SheetsError> {
    let clear_range = format!("A1:Z{}", max_prior_rows.max(1));
    client.clear_range(sheet_id, &clear_range)?; // wipes basic filter/sort/human rows
    client.write_rows(sheet_id, 1, rows)?;
    client.set_protected_range(sheet_id, true)?; // soft read-only
    Ok(())
}
```

Ambiguity chosen: "regenerated" implies clear-then-rewrite (not merge/diff), since that is the only mechanism guaranteeing overwrite of sort/filter/human-row state as the EARS demands.