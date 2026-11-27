```rust
// sheets-view/src/tab_order.rs
// @spec SHEET-TAB-002

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum TabCategory { View = 0, Config = 1, EventLog = 2 }

#[derive(Debug, Clone)]
pub struct TabSpec {
    pub sheet_id: i64,
    pub title: String,
    pub current_index: i64,
}

fn category_of(title: &str) -> TabCategory {
    match title {
        "Config" => TabCategory::Config,
        t if t.starts_with("Events") || t.starts_with("Log") => TabCategory::EventLog,
        _ => TabCategory::View, // unknown tabs default to View (see assumptions)
    }
}

/// Deterministic target order: category-major (View < Config < EventLog),
/// Positions pinned first within View, alphabetical tiebreak elsewhere.
/// Same input always yields same output -> idempotent by construction.
fn canonical_key(t: &TabSpec) -> (TabCategory, u8, String) {
    let cat = category_of(&t.title);
    let pin = if cat == TabCategory::View && t.title == "Positions" { 0 } else { 1 };
    (cat, pin, t.title.clone())
}

/// Returns only the move requests needed to reach canonical order; empty
/// if already correct, so re-running on republish is a safe no-op.
pub fn reassert_order(mut tabs: Vec<TabSpec>) -> Vec<(i64 /*sheet_id*/, i64 /*new_index*/)> {
    let mut desired = tabs.clone();
    desired.sort_by_key(canonical_key);

    tabs.sort_by_key(|t| t.current_index);
    desired
        .into_iter()
        .enumerate()
        .filter_map(|(idx, spec)| {
            let idx = idx as i64;
            (spec.current_index != idx).then_some((spec.sheet_id, idx))
        })
        .collect()
}
```

Assumptions (invented, not stated in the EARS):
1. Three fixed categories exist: View, Config, EventLog; membership is inferred from title prefix/exact-match since the EARS doesn't enumerate tab names.
2. Unknown/future tab titles default to View (appended after known views) rather than erroring, so publish never fails on an uncategorized tab — a stricter reading could instead reject unknown tabs.
3. "Positions... leftmost (landing) tab" is interpreted as global index 0 (View sorts first overall, Positions sorts first within View).
4. Order within Config and EventLog, and within View besides Positions, is unspecified by the EARS; alphabetical-by-title is chosen for determinism/idempotency, not because the requirement implies it.
5. Multiple event-log tabs are assumed possible (plural "logs" in the requirement text); ordered alphabetically among themselves.
6. Idempotency is implemented by diffing current vs. desired index and emitting zero requests when already correct, rather than unconditionally re-issuing moves — chosen so republish is cheap and side-effect-free when nothing changed.
7. If a "Positions" tab is absent, no special error handling is defined; the pin key simply never matches, degrading silently to plain alphabetical View ordering — an alternative would be to treat this as a hard invariant violation and return `Err`.
8. Sheet identity is keyed by stable `sheet_id`, not title, assuming titles could theoretically collide/rename across publishes.