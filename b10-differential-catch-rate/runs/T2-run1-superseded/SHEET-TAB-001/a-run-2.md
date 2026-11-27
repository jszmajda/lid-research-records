```rust
/// Row-oriented projection of kernel output into the four published Sheets tabs.
/// sheets-view owns no accounting/tax math — it only shapes and writes rows.

pub enum CellValue {
    Text(String),
    Cents(i64),          // money as integer cents
    IntQty(i64),         // share/lot counts
    LiveFormula(String), // e.g. GOOGLEFINANCE oracle cell
}

pub struct ViewTab {
    pub name: &'static str,        // "Positions" | "Open Lots" | "Realized" | "Tax"
    pub headers: Vec<(&'static str, ColumnType)>, // typed header row
    pub rows: Vec<Vec<CellValue>>, // one row per record, no blank/summary rows
}

pub enum ColumnType { Text, Money, Quantity, Formula }

pub fn build_positions_tab(rows: &[kernel::Position]) -> ViewTab {
    let mut r: Vec<_> = rows.iter().collect();
    r.sort_by(|a, b| (&a.entity_id, &a.symbol).cmp(&(&b.entity_id, &b.symbol))); // deterministic order
    ViewTab {
        name: "Positions",
        headers: vec![
            ("Entity", ColumnType::Text), ("Symbol", ColumnType::Text),
            ("Shares", ColumnType::Quantity), ("CostBasisCents", ColumnType::Money),
            ("LivePrice", ColumnType::Formula), ("MarketValueCents", ColumnType::Money),
        ],
        rows: r.into_iter().map(|p| vec![
            CellValue::Text(p.entity_id.clone()),
            CellValue::Text(p.symbol.clone()),
            CellValue::IntQty(p.shares),
            CellValue::Cents(p.cost_basis_cents),
            CellValue::LiveFormula(format!("=GOOGLEFINANCE(\"{}\")", p.symbol)),
            CellValue::Cents(p.market_value_cents),
        ]).collect(),
    }
}
// build_open_lots_tab / build_realized_tab / build_tax_tab follow the same shape,
// each consuming its own kernel record type with no cross-record aggregation.

pub fn publish_view_tabs(k: &kernel::Snapshot) -> [ViewTab; 4] {
    [
        build_positions_tab(&k.positions),
        build_open_lots_tab(&k.open_lots),
        build_realized_tab(&k.realized),
        build_tax_tab(&k.tax),
    ]
    // writer applies Sheets API protected-range (read-only) + native filter view per tab
}
```

Assumptions:
1. "Per-entity data band ... one row per entity" is read as "one row per natural record of that tab's kind" (position, open lot, realized event, tax lot) — not literally one row per legal/account entity, since Open Lots/Realized inherently have multiple rows per entity; literal reading would contradict the tab's purpose.
2. "No among-data summary rows" = zero subtotal/total/blank rows anywhere in the data body; the header row (row 1, preceding data) is not "among" data and is required by "typed headers."
3. "Typed headers" = each header carries a declared `ColumnType` used to apply Sheets number/currency formatting on publish; the literal cell text is still a plain string label.
4. Read-only is enforced at publish time via Sheets protected-range/API, not encoded in the Rust type — sheets-view has no permission model of its own.
5. GOOGLEFINANCE oracle formula appears only on Positions (only tab needing a live price); other tabs carry static kernel values.
6. Row order is deterministic (sorted by entity_id, then symbol/lot-id) so re-publish is diff-stable for Sheets sort/filter state.
7. Empty kernel input → tab published with header row only, zero data rows; no placeholder "no data" row (that would itself be a non-data summary/status row).
8. Money is `i64` cents per project convention; share/lot quantities are plain integers, not `Cents`.
9. Tab names are exact literals including the space in "Open Lots"; used as Sheets tab titles verbatim.