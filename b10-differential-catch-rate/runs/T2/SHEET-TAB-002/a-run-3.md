```rust
/// SHEET-TAB-002: canonical, idempotent tab ordering.
/// Order: Positions (index 0) < other Views < Config < Event Logs.

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug)]
enum TabGroup { Positions = 0, Views = 1, Config = 2, EventLogs = 3 }

pub struct TabMeta { pub sheet_id: i64, pub title: String, pub current_index: i32 }

fn classify(title: &str) -> TabGroup {
    match title {
        "Positions" => TabGroup::Positions,
        t if t == "Config" || t == "Settings" => TabGroup::Config,
        t if t.starts_with("Log:") || t.ends_with(" Events") || t.ends_with(" Log") => TabGroup::EventLogs,
        _ => TabGroup::Views, // unrecognized tabs default to Views bucket
    }
}

/// Returns only the (sheet_id, target_index) pairs that actually need to move,
/// so republishing against an already-correct order emits zero requests.
pub fn plan_tab_order(existing: &[TabMeta]) -> Vec<(i64, i32)> {
    let mut order: Vec<&TabMeta> = existing.iter().collect();
    // Stable sort: ties within a group keep current relative order.
    order.sort_by_key(|m| (classify(&m.title), m.current_index));

    order
        .into_iter()
        .enumerate()
        .filter_map(|(target_idx, m)| {
            let target_idx = target_idx as i32;
            (target_idx != m.current_index).then_some((m.sheet_id, target_idx))
        })
        .collect()
}

/// Caller (publish/republish path) wraps plan_tab_order's output in
/// UpdateSheetPropertiesRequest{index: target_idx, fields: "index"} batchUpdate
/// entries and sends them in one request, ordered by target_idx ascending
/// (Sheets API applies index moves sequentially, so ascending avoids
/// clobbering positions of not-yet-moved sheets).
```

Assumptions (invented — none of this is stated in the EARS text):

1. **Tab classification mechanism**: EARS gives no way to identify a tab's category. I invented title-string matching (`classify`) as a stand-in; the real sheets-view crate should tag each published tab with an explicit `TabKind` enum at creation time rather than inferring from title text.
2. **"Positions" tab identity**: assumed exactly one sheet literally titled `"Positions"`; if absent, no index-0 tab is forced — group ordering just degrades to whatever occupies the Views bucket.
3. **Multiple views/logs tabs**: EARS specifies only 3 macro-groups; within a group (e.g., several event-log tabs) I assumed stable ordering — preserve whatever relative order they currently have, since the spec doesn't define intra-group order.
4. **Unrecognized/unknown tabs** (not matching any pattern): defaulted to the Views bucket as the least-disruptive fallback rather than erroring or appending at the end.
5. **Idempotency mechanism**: interpreted "reasserting idempotently" as "compute the same canonical target order every time, and no-op (emit zero API calls) when already correct" — rather than, e.g., always re-writing all indices unconditionally.
6. **Move application order**: assumed ascending target-index application avoids the Sheets API's index-shifting side effects during a multi-move batch; not specified by EARS.
7. **Scope**: only sheet `index` is touched — title, color, visibility, and hidden/frozen-row state are out of scope, since EARS-002 only concerns tab *order*.