```rust
// crates/sheets-view/src/republish.rs
// @spec SHEET-TAB-003

use std::collections::BTreeMap;

pub struct TabPlan {
    pub sheet_id: i64,
    pub title: String,
    pub rows: Vec<Vec<CellValue>>, // fully rendered, incl. GOOGLEFINANCE formula strings
}

/// A filter view we own, keyed by its stable title. Saved in config, not read
/// back from the workbook, so a user-deleted view is restored on republish.
#[derive(Clone)]
pub struct FilterViewSpec {
    pub title: String,
    pub range: GridRange,
    pub sort_specs: Vec<SortSpec>,
    pub criteria: BTreeMap<u32, FilterCriteria>,
}

pub struct ViewTabConfig {
    pub filter_views: Vec<FilterViewSpec>,
    pub protect_editors: Vec<String>, // service account(s) exempt from protection
}

/// Build one atomic batchUpdate for a view tab. Order is load-bearing:
/// clear -> write -> drop basic filter -> re-assert filter views -> protect.
pub fn republish_tab_requests(
    plan: &TabPlan,
    cfg: &ViewTabConfig,
    existing: &ExistingTabState, // filter view ids + protected range ids observed this pass
) -> Vec<Request> {
    let mut reqs = Vec::new();

    // Existing protection would reject our own writes; drop then re-add.
    for id in &existing.protected_range_ids {
        reqs.push(Request::DeleteProtectedRange { id: *id });
    }

    // Regenerated, not patched: nuke every cell so human-inserted rows,
    // manual sorts, and stale trailing rows cannot survive.
    reqs.push(Request::UpdateCells {
        range: whole_sheet(plan.sheet_id),
        fields: "*",
    });
    reqs.push(Request::UpdateCells {
        range: top_left(plan.sheet_id),
        rows: plan.rows.clone(),
        fields: "userEnteredValue,userEnteredFormat",
    });

    // A human-applied basic filter is overwritten by design.
    reqs.push(Request::ClearBasicFilter { sheet_id: plan.sheet_id });

    // Actively re-assert saved filter views: update in place when the title
    // still exists (preserves the user's bookmarked fvid URLs), else recreate.
    for spec in &cfg.filter_views {
        match existing.filter_view_id_by_title.get(&spec.title) {
            Some(&id) => reqs.push(Request::UpdateFilterView { id, spec: spec.clone() }),
            None => reqs.push(Request::AddFilterView { spec: spec.clone() }),
        }
    }

    reqs.push(Request::AddProtectedRange {
        sheet_id: plan.sheet_id,
        warning_only: false,
        editors: cfg.protect_editors.clone(),
    });

    reqs
}
```

Assumptions invented (none stated by the EARS):

1. Read-only is enforced by a full-sheet ProtectedRange with the service account as sole editor, not `warningOnly` — the EARS says "read-only" without naming a mechanism.
2. Regeneration is clear-then-write over the whole sheet rather than a diffing patch; this is what makes inserted rows vanish.
3. Protection must be deleted before writing and re-added after, since our own edits go through the same API surface.
4. Filter views are declared in project config and are the source of truth; ones the user hand-created on the tab are not preserved (the EARS only promises *saved* views we own).
5. Match filter views by title, and prefer update-in-place over delete/recreate so filter-view IDs (and the URLs users bookmark) stay stable. Interpretation chosen because "persist across the rewrite" implies identity continuity, not just re-existence.
6. All requests batch into one atomic `batchUpdate` so a failure leaves no half-cleared tab.
7. Basic filter is unconditionally cleared — cheap and idempotent even when absent.
8. Sheet is assumed to exist with a known `sheet_id`; creation/sizing (grid resize when `rows` exceeds current extent) is another spec's job.
9. `CellValue`, `GridRange`, `SortSpec`, `FilterCriteria`, `Request` are thin local mirrors of the Sheets v4 API types.
10. Empty `plan.rows` still clears and protects — an empty view tab is a valid published state, not an error.
11. No Cents/tax logic appears here; values arrive pre-rendered from the kernel, per the crate boundary.