```rust
/// Gross ordering bucket for a tab; Ord derive gives views < config < event_logs.
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug)]
enum TabCategory { Views = 0, Config = 1, EventLogs = 2 }

/// One tab as known to sheets-view, carrying its live Sheets API sheetId.
struct TabHandle {
    sheet_id: i64,
    category: TabCategory,
    is_positions: bool, // true only for the Positions view tab
}

/// Computes the desired left-to-right sheet_id order: views → config → event logs,
/// Positions first among views. Ties beyond that are stable (input order preserved).
fn desired_order(tabs: &[TabHandle]) -> Vec<i64> {
    let mut idx: Vec<usize> = (0..tabs.len()).collect();
    idx.sort_by_key(|&i| (tabs[i].category, !tabs[i].is_positions));
    idx.into_iter().map(|i| tabs[i].sheet_id).collect()
}

/// Diffs current vs desired order and emits only the moves needed, so a republish
/// with an already-correct order produces zero requests (idempotent reassert).
fn reorder_requests(current: &[i64], desired: &[i64]) -> Vec<sheets4::api::Request> {
    if current == desired { return vec![]; }
    desired.iter().enumerate().filter_map(|(new_idx, &sid)| {
        if current.get(new_idx) == Some(&sid) { return None; } // already in place
        Some(sheets4::api::Request {
            update_sheet_properties: Some(sheets4::api::UpdateSheetPropertiesRequest {
                properties: Some(sheets4::api::SheetProperties {
                    sheet_id: Some(sid), index: Some(new_idx as i32), ..Default::default()
                }),
                fields: Some("index".into()),
            }),
            ..Default::default()
        })
    }).collect()
}
```

Assumptions (invented, none stated by the EARS text):

1. **Category membership is precomputed elsewhere.** `TabCategory` and `is_positions` are assumed already resolved per tab by the sheets-view projection layer; this sketch only orders, doesn't classify.
2. **Tie-break within "views" beyond Positions**: unspecified by EARS — assumed stable (preserves whatever order the projection emitted them in), not alphabetical.
3. **Tie-break within "config" and "event logs"**: same — stable/input order, since EARS only pins Positions' position, not intra-group order.
4. **Missing Positions tab**: not addressed by EARS; assumed out of scope for this function (upstream must guarantee a Positions view exists) rather than erroring here.
5. **Unknown/extra tabs** (e.g., user-added sheet not in any known category): assumed absent from `tabs`; not handled — would need a 4th bucket, but EARS names only three groups.
6. **Idempotency mechanism**: interpreted as "diff against live state, emit nothing when already correct," not "always reassert unconditionally" — cheaper and matches "reasserting ... idempotently" (result-idempotent, not request-idempotent).
7. **Move semantics**: assumed Google Sheets API `index` field semantics (post-removal reinsertion index) match a simple left-to-right target-index assignment; not verified against live API quirks.
8. **Identity key**: sheets matched by stable `sheetId`, not title, since titles could theoretically be edited by a user in the workbook.