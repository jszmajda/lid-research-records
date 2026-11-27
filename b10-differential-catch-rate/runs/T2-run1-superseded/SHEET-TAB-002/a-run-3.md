```rust
/// Logical grouping that fixes the left-to-right macro order of tabs.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum TabGroup { Views = 0, Config = 1, EventLogs = 2 }

/// Metadata the sheets-view crate already holds for each published tab.
#[derive(Debug, Clone)]
struct TabMeta { sheet_id: i64, name: String, group: TabGroup }

/// Compute desired 0-based sheet indices: group ascending (Views, Config,
/// EventLogs); within Views, a tab named "Positions" is forced first;
/// all other ties keep stable input order to minimize churn.
fn desired_order(tabs: &[TabMeta]) -> Vec<i64> {
    let mut indexed: Vec<(usize, &TabMeta)> = tabs.iter().enumerate().collect();
    indexed.sort_by_key(|(orig_idx, t)| {
        let is_positions = t.group == TabGroup::Views && t.name == "Positions";
        (t.group, !is_positions, *orig_idx)
    });
    indexed.into_iter().map(|(_, t)| t.sheet_id).collect()
}

struct MoveSheetRequest { sheet_id: i64, new_index: i64 }

/// Idempotent reassertion: only emit a move for a sheet whose current
/// index differs from its desired index. A no-op republish yields zero
/// requests.
fn reorder_requests(current: &[TabMeta], desired_ids: &[i64]) -> Vec<MoveSheetRequest> {
    let current_index: std::collections::HashMap<i64, usize> =
        current.iter().enumerate().map(|(i, t)| (t.sheet_id, i)).collect();
    desired_ids.iter().enumerate()
        .filter_map(|(want_idx, &id)| {
            (current_index.get(&id).copied() != Some(want_idx))
                .then(|| MoveSheetRequest { sheet_id: id, new_index: want_idx as i64 })
        })
        .collect()
}
```

Assumptions invented:

1. Each `TabMeta` already carries a `TabGroup` assigned by the sheets-view projector at creation time (not inferred from tab name) — the EARS states the group order, not a classification rule.
2. "Positions" is matched by exact tab name; assumed normally unique. If zero Views tabs are named "Positions," the leftmost Views tab is whatever sorts first with no error. If duplicates exist, the first in input order wins and the rest sort after it — no panic, since the spec defines no conflict policy.
3. Secondary ordering within a group (and among non-Positions Views tabs) is stable/input-preserving rather than alphabetical, to avoid gratuitous reordering on each republish; the spec is silent on this.
4. Idempotency is implemented via an index diff: a move request is only emitted when current index ≠ desired index, so an unchanged tab set produces zero Sheets API calls on repeat publish.
5. Sheet indices are 0-based, matching the Google Sheets API's `index` field on sheet properties.
6. An empty tab list is a no-op, not an error.
7. A tab with no recognized `TabGroup` is treated as a caller bug (sheets-view is assumed to tag every tab it creates); no fallback bucket is defined here.
8. This sketch only computes the request diff; batching into a single `batchUpdate` call and actually issuing it is assumed to be the caller's responsibility.