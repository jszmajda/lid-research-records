```rust
/// SHEET-TAB-003: view tabs are read-only and regenerated; only saved
/// Sheets Filter Views survive a republish.
pub struct ViewTab { pub sheet_id: i64, pub title: String }

pub struct FilterViewSpec {
    pub filter_view_id: Option<i64>,
    pub title: String,
    pub range: GridRange,
    pub sort_specs: Vec<SortSpec>,
    pub criteria: std::collections::HashMap<i64, FilterCriteria>,
}

pub async fn republish_view_tab(
    client: &mut SheetsClient,
    tab: &ViewTab,
    rows: Vec<Row>,
) -> Result<(), PublishError> {
    // 1. Snapshot the ONLY survivors: saved Filter Views.
    let saved_filter_views = client.get_filter_views(tab.sheet_id).await?;

    // 2. "Regenerated" = delete-and-recreate the whole tab. This is what
    //    destroys any basic filter, manual sort, or human-inserted row —
    //    they live only in the old sheet object, which is gone.
    client.delete_sheet(tab.sheet_id).await?;
    let new_sheet_id = client.add_sheet(&tab.title).await?;

    // 3. Kernel-projected rows are the sole source of content/order.
    client.write_rows(new_sheet_id, &rows).await?;
    // No basic filter or sort is ever (re)installed — read-only is
    // enforced by never writing one back, not by an ACL.

    // 4. Reapply ONLY the saved Filter Views, rebound to the new sheet id.
    for fv in saved_filter_views {
        client.add_filter_view(new_sheet_id, fv.rebind(new_sheet_id)).await?;
    }
    Ok(())
}
```

Assumptions (invented, not in the EARS text):

1. "Regenerated" = delete-and-recreate the tab's sheet object per publish, not an in-place cell clear — the only reading that guarantees basic filter, sort, and inserted rows are all destroyed without enumerating each individually.
2. Filter Views are the single explicitly-snapshotted/restored object (via `get_filter_views`/`add_filter_view`); basic filters and sort specs are deliberately NOT snapshotted — their disappearance IS the "overwritten by design" behavior.
3. Filter View identity across republish is carried by title+criteria (via `rebind`), not a stable `filter_view_id`, since the sheet itself is new; no collision handling if two saved views share a title (first-write-wins, unspecified by EARS).
4. "Read-only" is enforced by convention only (never writing a filter/protected-range back) — no Sheets ACL/protected-range lock is assumed available or required.
5. Human-inserted rows need no explicit detection: they have no counterpart in kernel-projected `rows`, so delete-and-recreate drops them implicitly.
6. No rollback/compensating transaction if `write_rows` or filter-view reapplication fails after `add_sheet` succeeds; republish is assumed idempotent/retriable since output is fully derived from kernel state + saved filter views.
7. `GridRange` in a saved Filter View needs only sheet_id rebinding (row/col bounds unchanged), assuming column layout is stable across republishes.