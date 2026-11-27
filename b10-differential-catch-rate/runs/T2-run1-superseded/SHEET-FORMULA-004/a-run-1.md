```rust
// --- Money convention (workspace-wide) ---
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct Cents(pub i64);

/// One kernel-computed, tax-adjusted line, pinned to the last settle/sync pass.
/// sheets-view performs no accounting/tax math here — this is a pure projection.
#[derive(Clone, Debug)]
pub struct TaxTabRow {
    pub label: String,
    pub short_term_adj: Cents,   // stacked layer: short-term tax adjustment
    pub long_term_adj: Cents,    // stacked layer: long-term tax adjustment
    pub total_adj: Cents,        // stacked total = short_term_adj + long_term_adj
    pub as_of_sync: Option<chrono::DateTime<chrono::Utc>>, // per-row override; None -> use snapshot default
}

/// Kernel-produced snapshot as of the last marks read-back settle pass.
pub struct TaxSnapshot {
    pub rows: Vec<TaxTabRow>,
    pub last_sync: Option<chrono::DateTime<chrono::Utc>>, // None = never settled yet
}

pub struct SheetCellRow {
    pub label: String,
    pub short_term_cents: i64,
    pub long_term_cents: i64,
    pub total_cents: i64,
    pub as_of_label: String, // rendered timestamp or "not yet synced"
}

/// Projects kernel-exact tax figures onto the Tax tab as literal values —
/// never a GOOGLEFINANCE or other live formula — so the tab stays pinned
/// to `last_sync` and is visually/structurally distinct from the Positions
/// tab's live GOOGLEFINANCE-driven estimate.
pub fn project_tax_tab(snapshot: &TaxSnapshot) -> Vec<SheetCellRow> {
    snapshot.rows.iter().map(|row| {
        let as_of = row.as_of_sync.or(snapshot.last_sync);
        SheetCellRow {
            label: row.label.clone(),
            short_term_cents: row.short_term_adj.0,
            long_term_cents: row.long_term_adj.0,
            total_cents: row.total_adj.0,
            as_of_label: as_of
                .map(|t| t.to_rfc3339())
                .unwrap_or_else(|| "not yet synced".to_string()),
        }
    }).collect()
}
```

Assumptions (all invented, not stated by the EARS text):

1. "Kernel-exact" = written as literal values, never a spreadsheet formula — the defining contrast with Positions' GOOGLEFINANCE cell.
2. "Stacked" interpreted as short-term/long-term tax-adjustment layers summed into a total, since "tax-adjusted figures" implies cost-basis/holding-period layering. Alternative reading (rows stacked chronologically by settle pass) rejected as less tied to "tax-adjusted."
3. "As-of-last-sync" = timestamp of the most recent marks read-back settle pass; carried per-row with fallback to the snapshot-level `last_sync`.
4. Never-synced state: `last_sync: None` and no per-row override renders `"not yet synced"` rather than a blank or zeroed cell, to avoid implying a false kernel-exact value.
5. `Cents(i64)` matches the stated integer-cents money convention; no `f64` anywhere.
6. `TaxSnapshot` is assumed pre-computed entirely upstream (kernel); this module performs zero arithmetic, consistent with "sheets-view... owns no accounting or tax math."
7. Distinctness from Positions is implemented structurally (separate types, no formula field, no live price dependency) rather than via a UI flag, since the EARS gives no UI detail to anchor a labeling requirement.
8. Row ordering/grouping (e.g., by lot vs. by symbol) is left unspecified by the EARS; `label: String` is a placeholder key, not a designed identifier scheme.