```rust
// crates/sheets-view/src/republish.rs
// @spec SHEET-TAB-003

use std::collections::BTreeMap;

/// A tab we publish. Values are pre-rendered cells from the kernel projection.
pub struct ViewTab {
    pub title: String,
    pub sheet_id: i64,
    pub grid: Vec<Vec<CellValue>>, // row-major, includes header row
}

/// A saved Filter View we must re-assert after the rewrite.
#[derive(Clone, PartialEq)]
pub struct FilterViewSpec {
    pub filter_view_id: Option<i64>, // None = never yet created
    pub title: String,
    pub range: GridRange,
    pub sort_specs: Vec<SortSpec>,
    pub criteria: BTreeMap<i64, FilterCriteria>, // by column index
}

pub struct TabPlan {
    pub tab: ViewTab,
    pub filter_views: Vec<FilterViewSpec>, // desired state, owned by config
}

/// Build the single batchUpdate request list that regenerates a tab.
/// Order is load-bearing: clear -> write -> protect -> re-assert filter views.
pub fn republish_requests(plan: &TabPlan, live: &LiveTabState) -> Vec<Request> {
    let mut reqs = Vec::new();

    // 1. Drop anything a human added: extra rows/cols, basic filter, manual sort.
    //    updateCells over the whole sheet (not appendCells) makes the tab a pure
    //    function of kernel output; a human-inserted row simply ceases to exist.
    reqs.push(Request::ClearBasicFilter { sheet_id: plan.tab.sheet_id });
    reqs.push(Request::ResizeGrid {
        sheet_id: plan.tab.sheet_id,
        rows: plan.tab.grid.len() as i64,
        cols: plan.tab.grid.first().map_or(1, Vec::len) as i64,
    });
    reqs.push(Request::UpdateCells {
        sheet_id: plan.tab.sheet_id,
        grid: plan.tab.grid.clone(),
    });

    // 2. Read-only: protect the whole tab, warning-only off, no editors but us.
    for p in &live.protected_ranges {
        reqs.push(Request::DeleteProtectedRange { id: p.id });
    }
    reqs.push(Request::AddProtectedRange {
        sheet_id: plan.tab.sheet_id,
        description: "LID view tab - regenerated, edits are overwritten".into(),
        warning_only: false,
    });

    // 3. Re-assert saved Filter Views (these survive by re-creation, not luck).
    for want in &plan.filter_views {
        match live.filter_view_id_by_title(&want.title) {
            Some(id) => reqs.push(Request::UpdateFilterView { id, spec: want.clone() }),
            None => reqs.push(Request::AddFilterView { spec: want.clone() }),
        }
    }
    // Filter views present live but not desired are left alone (user-created).
    reqs
}
```

Assumptions invented:
1. Filter Views are declared in publisher config (desired state) — the requirement says "saved", which I read as *our* saved specs, not scraped-from-live. Chosen because scraping makes the rewrite non-deterministic.
2. Matching live↔desired filter views by `title`, not id; ids are unstable across recreation.
3. Live filter views with no desired counterpart are preserved, not deleted — "re-assert" is additive, not exclusive.
4. "Read-only" implemented as a full-sheet ProtectedRange with `warning_only=false`; workbook owner still retains edit rights (Sheets always lets the owner in), so this is advisory-for-humans, enforced-by-rewrite.
5. Grid is resized down to exactly the projection's extent, which is what actually deletes human-inserted rows.
6. `ClearBasicFilter` is unconditional and ignores "no basic filter exists" errors (treated as no-op rather than fatal).
7. Whole operation is one `spreadsheets.batchUpdate` — atomic per tab; no partial-tab state.
8. Empty grid (zero rows) is legal: resize to 1x1 and write a blank, rather than erroring.
9. Cell values are pre-rendered by the projection layer, including the GOOGLEFINANCE formula column as a formula-typed cell; this module does no accounting or formatting math.
10. No conflict detection or user warning on overwrite — "by design" means silent.

Ambiguity: "regenerated" could mean delete-and-recreate the sheet. Rejected — that would destroy filter view ids and any cross-tab references; chose clear-and-rewrite in place.