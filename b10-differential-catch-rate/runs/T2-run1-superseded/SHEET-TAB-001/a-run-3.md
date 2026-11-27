```rust
/// @spec SHEET-TAB-001
/// Publishes four read-only view tabs, each a flat per-entity data band:
/// one row per entity, typed headers, no interleaved summary rows.

pub enum TabKind { Positions, OpenLots, Realized, Tax }

impl TabKind {
    fn sheet_name(&self) -> &'static str {
        match self {
            TabKind::Positions => "Positions",
            TabKind::OpenLots => "Open Lots",
            TabKind::Realized => "Realized",
            TabKind::Tax => "Tax",
        }
    }
}

/// One row per entity (position, lot, realized event, or tax line).
pub trait ViewRow {
    fn headers() -> Vec<CellType>;
    fn to_cells(&self) -> Vec<CellValue>;
}

pub enum CellType { Text, Cents, Quantity, Date, Formula }
pub enum CellValue { Text(String), Cents(i64), Quantity(f64), Date(String), Formula(String) }

pub struct SheetTab {
    pub name: &'static str,
    pub headers: Vec<CellType>,
    pub rows: Vec<Vec<CellValue>>,
}

/// Builds a tab as header row + contiguous data band; no blank/summary rows
/// permitted between data rows.
pub fn build_tab<R: ViewRow>(kind: TabKind, entities: &[R]) -> SheetTab {
    SheetTab {
        name: kind.sheet_name(),
        headers: R::headers(),
        rows: entities.iter().map(R::to_cells).collect(),
    }
}

/// Publishes all four tabs read-only (protected range / no user edit).
pub fn publish_all_tabs(
    positions: &[PositionRow],
    open_lots: &[OpenLotRow],
    realized: &[RealizedRow],
    tax: &[TaxRow],
) -> Vec<SheetTab> {
    vec![
        build_tab(TabKind::Positions, positions),
        build_tab(TabKind::OpenLots, open_lots),
        build_tab(TabKind::Realized, realized),
        build_tab(TabKind::Tax, tax),
    ]
}
```

ASSUMPTIONS:
1. "Entity" is generic per tab: Positions=security/instrument, Open Lots=lot, Realized=realized-gain event, Tax=tax line item. EARS doesn't define entity per tab.
2. Zero entities → tab published with header row only, zero data rows (empty band is not itself a "summary row").
3. "Typed headers" means each column declares a data type (Text/Cents/Quantity/Date/Formula) rather than all-string; exact type enum invented.
4. "Read-only" implemented via a protected-range/publish step outside this sketch (not shown) — assumed handled by the sheets-view publish layer, not this data-shaping function.
5. No sorting/ordering requirement stated, so row order is assumed to be caller/kernel-supplied and preserved as-is (stable, not re-sorted here).
6. "No among-data summary rows" interpreted strictly as: no blank rows, subtotal rows, or section headers interleaved within the data band — totals, if any, would need a separate mechanism outside these four tabs (not addressed, since none is specified).
7. GOOGLEFINANCE formula column (mentioned in target description, not in this EARS) assumed to appear only in Positions as a `CellValue::Formula` cell — invented since this EARS doesn't mention it directly.
8. Money fields typed as `i64` Cents per target's stated convention.
9. One row strictly means one entity maps to exactly one row (no multi-row-per-entity wrapping), so wide entities must fit in a single row's columns.
10. Ambiguity: "per-entity data band" could mean one band per tab (chosen) vs. multiple bands per tab grouped by category; chose single contiguous band per tab as the simpler, EARS-literal reading.