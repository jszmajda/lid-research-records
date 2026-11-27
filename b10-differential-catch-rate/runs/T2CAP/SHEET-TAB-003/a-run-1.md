```rust
// crates/sheets-view/src/republish.rs
// @spec SHEET-TAB-003

use std::collections::BTreeMap;

pub struct FilterViewSpec {
    pub title: String,                 // stable identity key
    pub range: GridRange,
    pub criteria: BTreeMap<u32, FilterCriterion>,
    pub sort_specs: Vec<SortSpec>,
}

pub struct TabPublish {
    pub sheet_id: i64,
    pub tab_title: String,
    pub values: Vec<Vec<CellValue>>,   // kernel projection, incl. GOOGLEFINANCE formula col
    pub saved_filter_views: Vec<FilterViewSpec>, // desired post-republish state
}

#[derive(Debug)]
pub enum ViewError { Api(String), Conflict { tab: String } }

/// Republish is destructive-by-design: the tab's grid is cleared and rewritten,
/// tab protection is (re)asserted, and every saved Filter View is re-asserted.
/// Any basic filter, manual sort, or human-inserted row is dropped.
pub fn republish_tab(api: &mut dyn SheetsApi, tab: &TabPublish) -> Result<(), ViewError> {
    let mut reqs = Vec::new();

    // 1. Drop transient user state that must NOT survive: basic filter + any
    //    rows/cols the human added beyond the projection's shape.
    reqs.push(Request::ClearBasicFilter { sheet_id: tab.sheet_id });
    reqs.push(Request::UpdateSheetProperties {
        sheet_id: tab.sheet_id,
        row_count: tab.values.len() as u32,
        column_count: tab.values.first().map_or(1, |r| r.len()) as u32,
    });

    // 2. Rewrite the whole grid (values + formulas), USER_ENTERED so the
    //    GOOGLEFINANCE column stays a live formula, not a literal string.
    reqs.push(Request::UpdateCells { sheet_id: tab.sheet_id, values: &tab.values });

    // 3. Re-assert read-only: protect the full sheet, editors = owner only,
    //    warning_only = false. Idempotent — delete existing then add.
    reqs.push(Request::DeleteProtectedRangesForSheet { sheet_id: tab.sheet_id });
    reqs.push(Request::AddProtectedRange { sheet_id: tab.sheet_id, warning_only: false });

    // 4. Re-assert saved Filter Views by title. Delete-then-add (not update):
    //    the rewrite can invalidate stored ranges, so identity is the title and
    //    the spec is authoritative. Views present in Sheets but absent from
    //    `saved_filter_views` are deleted — the publisher owns the tab.
    for existing in api.list_filter_views(tab.sheet_id)? {
        reqs.push(Request::DeleteFilterView { id: existing.id });
    }
    for fv in &tab.saved_filter_views {
        reqs.push(Request::AddFilterView { sheet_id: tab.sheet_id, spec: fv });
    }

    api.batch_update(reqs).map_err(|e| ViewError::Api(e.to_string()))
}
```

Assumptions invented:
1. "Saved Filter Views" = Sheets `FilterView` objects; identity key is `title` (Sheets IDs are unstable across delete/add).
2. The desired filter-view set is supplied by the caller (config/kernel), not read back from the sheet — so re-assertion is authoritative, and unknown views are deleted rather than preserved. Alternate reading (read-back and restore whatever the human saved) rejected: "actively re-asserts" implies a declared source of truth.
3. "Read-only" is enforced via a full-sheet ProtectedRange with `warning_only=false`, not by document-level ACL.
4. All mutations go in one `batchUpdate` for atomicity; partial failure leaves the tab unchanged.
5. Human-inserted rows are removed by resetting the grid dimensions to the projection's shape, not by diffing.
6. Empty projection (`values` empty) is legal: grid collapses to 1x1 and views are still re-asserted; no special-case error.
7. Values written with `USER_ENTERED` so the GOOGLEFINANCE column remains a formula.
8. Ragged `values` rows are not validated here; column count taken from row 0.
9. `ViewError::Conflict` reserved for concurrent-edit detection; not exercised by this requirement.
10. No accounting/tax math anywhere in this module, per crate boundary.