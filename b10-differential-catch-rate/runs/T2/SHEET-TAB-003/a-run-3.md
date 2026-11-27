```rust
//! sheets-view: tab republish (@spec SHEET-TAB-003)

/// Kernel-projected content for one tab, already tax/accounting-free.
pub struct ViewTabContent {
    pub sheet_id: i64,
    pub rows: Vec<Vec<CellValue>>, // row 0 = header; includes GOOGLEFINANCE formula cells verbatim
}

pub enum CellValue {
    Cents(i64),
    Text(String),
    Formula(String), // e.g. "=GOOGLEFINANCE(...)", passed through opaquely
}

/// One republish cycle: full clear + rewrite + basic-filter reset.
/// Filter Views are never referenced, which is what lets them survive.
pub fn republish_requests(prev_row_count: usize, content: &ViewTabContent) -> Vec<BatchUpdateRequest> {
    let mut reqs = vec![
        // Wipe the whole used range first so a human-inserted row (which
        // extends past kernel's row count) can't just be left in place.
        BatchUpdateRequest::DeleteDimensionRange {
            sheet_id: content.sheet_id,
            dimension: Dimension::Rows,
            start_index: 0,
            end_index: prev_row_count.max(content.rows.len()),
        },
        BatchUpdateRequest::UpdateCells {
            sheet_id: content.sheet_id,
            rows: content.rows.clone(),
            fields: "*".into(), // full overwrite, not a merge — kills manual sort order too
        },
        // basicFilter (Data > Create a filter) lives on sheet properties,
        // separate from saved filterViews; clearing it each cycle is what
        // overwrites a "basic filter."
        BatchUpdateRequest::ClearBasicFilter { sheet_id: content.sheet_id },
        // Deliberately absent: any request touching `filterViews`. Omission
        // is the preservation mechanism the spec calls out.
    ];
    reqs.retain(|_| true); // no-op placeholder for future ordering hooks
    reqs
}

pub enum Dimension { Rows, Columns }
pub enum BatchUpdateRequest {
    DeleteDimensionRange { sheet_id: i64, dimension: Dimension, start_index: usize, end_index: usize },
    UpdateCells { sheet_id: i64, rows: Vec<Vec<CellValue>>, fields: String },
    ClearBasicFilter { sheet_id: i64 },
}
```

Assumptions:
1. "Read-only" is enforced by regeneration overwrite, not Sheets ACL/ProtectedRange — text frames it as an effect of republish, not an access-control feature; no protection API call included.
2. Filter Views (`filterViews`) are Sheets-API-distinct from `basicFilter`; survival is achieved purely by never including a filter-view-touching request in the batch — not by explicit copy/restore logic.
3. Full-range delete-then-rewrite chosen over cell-level diffing, since diffing risks accidentally preserving a manually inserted row or sort order.
4. `prev_row_count` must be tracked/queried by the caller (not shown) to size the delete; assumed available from prior publish state.
5. Manual sort has no separate persisted representation once basicFilter is cleared and rows rewritten in kernel order — no dedicated "undo sort" call needed.
6. `CellValue::Formula` passes GOOGLEFINANCE strings through opaquely; sheets-view does no evaluation (per crate boundary).
7. No concurrency/locking model — last republish wins; out of scope for this EARS.
8. Malformed/empty `content.rows` (zero rows) is valid input — treated as "regenerate to empty tab," not an error.