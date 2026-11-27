```rust
use google_sheets_api::FilterView;

/// Regenerates a read-only view tab, reapplying saved filter views.
/// User edits (rows, manual sorts) are discarded by design.
pub struct ViewTabRegeneration {
    sheet_id: String,
    tab_gid: u32,
}

impl ViewTabRegeneration {
    /// Regenerate tab data while persisting saved Sheets Filter Views.
    pub async fn republish(
        &self,
        client: &SheetsClient,
        new_data: Vec<Vec<String>>,
    ) -> Result<(), Box<dyn std::error::Error>> {
        // 1. Fetch & preserve existing filter view specs
        let filter_specs = client
            .get_filter_views(&self.sheet_id, self.tab_gid)
            .await?;

        // 2. Clear all data (user rows, manual sorts → overwritten by design)
        client.clear_range(&self.sheet_id, self.tab_gid).await?;

        // 3. Write regenerated data
        client
            .append_values(&self.sheet_id, self.tab_gid, new_data)
            .await?;

        // 4. Re-assert filter views (persist across rewrite)
        for spec in filter_specs {
            client
                .upsert_filter_view(&self.sheet_id, self.tab_gid, spec)
                .await?;
        }

        Ok(())
    }
}
```

**Assumptions (explicitly listed):**

1. **FilterView type** — Maps to Google Sheets API `FilterView` with `filterCriteria`, `sortSpecs`, `range`; assumed serializable and API-roundtrippable.
2. **SheetsClient** — Async HTTP wrapper; `get_filter_views()` returns *all* filters on tab; `upsert_filter_view()` creates/updates atomically.
3. **Filter durability** — Filters are uniquely identified by tab+gid; re-assertion by spec is deterministic (API idempotent on re-send).
4. **Error on filter re-assertion** — If regenerated data removed a column a filter references, `upsert_filter_view()` fails; caller must handle (requirement silent on this — assume fail-fast).
5. **No column-mapping logic** — Filters are reapplied verbatim; if tab schema changes, filters may become invalid (requirement implies acceptance of this risk).
6. **Empty tab handling** — If `new_data` is empty, tab clears and filters are reapplied to empty sheet (no-op; by design).
7. **Concurrency** — Single-threaded; concurrent republishes will race on step 1–4 (requirement is silent; assume external serialization).
8. **Transactional atomicity** — Steps 2–4 are not atomic; if step 3 fails, data is written but filters are not restored (requirement doesn't specify recovery).

**Requirement Interpretation:** "saved Sheets Filter Views" means the *specification* (filterCriteria + sortSpecs), not the live state. "Persist across rewrite" means re-assert them after data regeneration so Sheets does not auto-clear them. User sorts/rows overwrite → they are cleared in step 2 (by-design read-only semantics).