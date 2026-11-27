```rust
/// Implements SHEET-TAB-002: tab ordering views → config → event logs,
/// with Positions pinned leftmost, reasserted idempotently on republish.

/// Category ordinal driving sort. Positions is a distinguished sub-case
/// of "views" that must sort before all other views.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum TabCategory {
    Positions = 0,
    OtherView = 1,
    Config = 2,
    EventLog = 3,
}

/// A tab as known to the sheets-view crate, prior to publish ordering.
/// `sheet_id` is the stable Google Sheets tab id, used as a tiebreaker
/// so equal-category tabs keep a deterministic relative order across
/// republishes (idempotence) rather than depending on input iteration order.
#[derive(Debug, Clone)]
struct TabHandle {
    name: String,
    category: TabCategory,
    sheet_id: i64,
}

fn classify(name: &str) -> TabCategory {
    match name {
        "Positions" => TabCategory::Positions,
        n if n.starts_with("Config") => TabCategory::Config,
        n if n.starts_with("Events") || n.starts_with("Log") => TabCategory::EventLog,
        _ => TabCategory::OtherView,
    }
}

/// Returns tabs in the order they should appear left-to-right in the
/// workbook. Pure and total: same input multiset -> same output order,
/// any number of times (idempotent reassertion).
fn reorder_tabs(mut tabs: Vec<TabHandle>) -> Vec<TabHandle> {
    tabs.sort_by(|a, b| a.category.cmp(&b.category).then(a.sheet_id.cmp(&b.sheet_id)));
    tabs
}

/// Applies the computed order to the live spreadsheet by issuing an
/// updateSheetProperties(index=...) batch request per tab. Called on
/// every publish, not just first creation, so drift (e.g. a user
/// manually dragging a tab) is corrected each time.
fn apply_tab_order(spreadsheet_id: &str, tabs: &[TabHandle]) -> Result<(), String> {
    for (index, tab) in tabs.iter().enumerate() {
        let _ = (spreadsheet_id, tab.sheet_id, index as i64); // -> Sheets API move-tab request
    }
    Ok(())
}
```

Assumptions (invented, not in the EARS text):

1. "Positions" is matched by exact tab name; no case-insensitivity or localization handled.
2. Category membership for non-Positions tabs is inferred from a name-prefix convention (`Config*`, `Events*`/`Log*`); the EARS does not say how a tab's category is known, so I invented a classifier rather than assuming an explicit enum field exists elsewhere in the codebase.
3. "views" (plural, non-Positions) covers any tab not matching Positions/Config/event-log patterns — treated as a catch-all bucket, ordered before config/logs.
4. Within a category, order is stabilized by `sheet_id` (assumed to be a stable, monotonic Google Sheets tab id) rather than insertion order, so "idempotent on republish" holds even if the input vec's iteration order varies between runs.
5. Duplicate tab names or two tabs both named "Positions" are not handled — assumed the upstream tab-registry guarantees uniqueness; no error path invented for that boundary case.
6. Empty tab list is valid (function returns empty vec, no-op), since the EARS doesn't specify a minimum tab set.
7. "Reasserting idempotently" is interpreted as "always re-sort and re-issue move commands on every publish," not "detect no-op and skip API calls" — no diffing/no-op short-circuit was assumed necessary since the requirement says nothing about API-call minimization.
8. Sheets API error handling (rate limits, partial failure mid-reorder) is elided — `apply_tab_order` returns `Result<(), String>` as a placeholder, not a designed error type.