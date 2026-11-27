# Rust Implementation: Sheet-Tab-001

```rust
/// Publishable read-only view tab to Google Sheets
pub struct TabView {
    pub name: &'static str,           // "Positions", "Open Lots", "Realized", "Tax"
    pub headers: Vec<String>,         // Typed column headers
    pub rows: Vec<Vec<String>>,       // One row per entity; no summary rows
}

/// Aggregated per-entity accounting view for all tabs
pub struct EntityTabRow {
    pub entity: String,               // Ticker/symbol identifier
    pub position: Vec<String>,        // For Positions tab
    pub open_lots: Vec<String>,       // For Open Lots tab
    pub realized: Vec<String>,        // For Realized tab
    pub tax: Vec<String>,             // For Tax tab
}

/// Publish four read-only tabs from aggregated entity data
pub fn publish_sheet_tabs(entities: Vec<EntityTabRow>) -> Vec<TabView> {
    vec![
        TabView {
            name: "Positions",
            headers: vec!["Entity".into(), "Quantity".into(), "CostBasis".into(), "CurrentValue".into(), "UnrealizedGain".into()],
            rows: entities.iter().map(|e| {
                let mut row = vec![e.entity.clone()];
                row.extend(e.position.iter().cloned());
                row
            }).collect(),
        },
        TabView {
            name: "Open Lots",
            headers: vec!["Entity".into(), "OpenLotCount".into(), "TotalOpenQty".into(), "TotalOpenBasis".into()],
            rows: entities.iter().map(|e| {
                let mut row = vec![e.entity.clone()];
                row.extend(e.open_lots.iter().cloned());
                row
            }).collect(),
        },
        TabView {
            name: "Realized",
            headers: vec!["Entity".into(), "SoldLotCount".into(), "TotalProceeds".into(), "TotalCostBasis".into(), "RealizedGain".into()],
            rows: entities.iter().map(|e| {
                let mut row = vec![e.entity.clone()];
                row.extend(e.realized.iter().cloned());
                row
            }).collect(),
        },
        TabView {
            name: "Tax",
            headers: vec!["Entity".into(), "LongTermGain".into(), "ShortTermGain".into(), "TotalTaxableGain".into()],
            rows: entities.iter().map(|e| {
                let mut row = vec![e.entity.clone()];
                row.extend(e.tax.iter().cloned());
                row
            }).collect(),
        },
    ]
}
```

## Assumptions (Explicit Inventory)

1. **Entity identifier**: String (ticker/symbol); assumes non-empty, deduplicated by caller.
2. **One row per entity per tab**: "Open Lots" and "Realized" aggregated by entity (e.g., sum/count of lots, not one row per individual lot), since requirement mandates "one row per entity."
3. **Values in Cents**: All numeric fields serialized as integer Cents (per project context), converted to strings for Sheets.
4. **Missing entities**: EntityTabRow must exist for every entity appearing in any tab; missing data is empty string or "0" (caller responsibility).
5. **Header uniformity**: All rows for a given tab have the same column count; no sparse rows.
6. **No null/missing handling in function**: Assumes caller validates; empty row vectors treated as empty data cells.
7. **GOOGLEFINANCE already live**: The "live-price oracle" via GOOGLEFINANCE is handled outside this function (in caller or Sheets formula); this function publishes static data rows only.
8. **Marks read-back settle pass**: Separate from tab publication; this function does not verify settlement status.

## Ambiguity Resolution

**"One row per entity"** interpreted literally: Open Lots/Realized are per-entity summaries (lot count, total proceeds), not per-lot rows. Alternative (one row per individual lot) would violate "one row per entity" requirement and break filtering/sorting by entity.

---

**Path**: `{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key` (from working directory; no files read or written per instruction).