```rust
// @spec SHEET-TAB-002
// Reasserts workbook tab order: views... , Positions leftmost within/overall,
// then config, then event logs. Idempotent: computes a diff against current
// indices and emits move-ops only for tabs not already in place.

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum TabGroup {
    Views = 0,
    Config = 1,
    EventLogs = 2,
}

#[derive(Debug, Clone)]
struct TabSpec {
    sheet_id: i64,
    title: String,
    group: TabGroup,
    current_index: i32,
}

#[derive(Debug, PartialEq, Eq)]
enum ReorderError {
    MissingPositionsTab,
}

/// Returns (sheet_id, target_index) pairs for tabs whose current index
/// differs from the desired order. Empty result = already correctly ordered.
fn compute_reorder(tabs: &[TabSpec]) -> Result<Vec<(i64, i32)>, ReorderError> {
    if !tabs.iter().any(|t| t.group == TabGroup::Views && t.title == "Positions") {
        return Err(ReorderError::MissingPositionsTab);
    }

    let mut ordered: Vec<&TabSpec> = tabs.iter().collect();
    // Sort key: group first, then "is this Positions?" (false sorts before
    // true) to force Positions leftmost within Views, then stable by
    // pre-existing index to preserve relative order otherwise.
    ordered.sort_by_key(|t| (t.group, t.title != "Positions", t.current_index));

    Ok(ordered
        .into_iter()
        .enumerate()
        .filter_map(|(i, t)| {
            let idx = i as i32;
            (t.current_index != idx).then_some((t.sheet_id, idx))
        })
        .collect())
}
```

Assumptions (every one invented, none given by the EARS text):

1. Tab-to-group classification (`TabGroup`) is supplied externally per tab; the spec names the groups but not how a tab is recognized as belonging to one.
2. "Positions" is identified by exact title match `"Positions"` within the Views group; no ID/marker field was specified, so I invented title-matching as the discriminator.
3. Missing Positions tab is treated as a hard error (`MissingPositionsTab`) rather than silently reordering without it, since the requirement mandates it must exist and be leftmost.
4. Intra-group order (for non-Positions Views, for Config tabs, for multiple event-log tabs e.g. per-year) is unspecified by the EARS, so I chose stable preservation of existing relative order via `current_index` as tiebreaker rather than inventing a naming/date sort.
5. Idempotency is implemented as a diff: only sheets whose computed index disagrees with `current_index` produce a move instruction; a fully-correct workbook yields an empty op list, satisfying "reasserting... idempotently" without emitting no-op API calls.
6. `sheet_id: i64` and `current_index: i32` assume Google Sheets API's native `sheetId`/`index` integer types; actual `batchUpdate(UpdateSheetPropertiesRequest)` wiring is omitted as out-of-scope plumbing.
7. Duplicate titles / multiple "Positions"-titled tabs are not defended against — first match wins implicitly via `any()`, undefined behavior for the pathological duplicate case since EARS gives no guidance.
8. "Republish" is assumed to invoke this function each time (not only on structural change), so cost of a no-op call is acceptable — no caching/short-circuit added beyond the diff itself.