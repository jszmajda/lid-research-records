```rust
// @spec SHEET-TAB-001
// sheets-view crate: projects kernel output into four read-only tab bands.
// Owns no accounting/tax math — pure reshaping of already-computed rows.

pub enum TabKind { Positions, OpenLots, Realized, Tax }

/// Declared type for a header cell; drives Sheets number format, not data validation.
pub enum ColumnType { Text, Cents, Quantity, Percent, Date, Formula }

pub struct ColumnHeader { pub name: &'static str, pub ty: ColumnType }

pub enum CellValue {
    Text(String),
    Cents(i64),
    Quantity(f64),
    Percent(f64),
    Date(chrono::NaiveDate),
    Formula(String), // e.g. GOOGLEFINANCE(...) oracle cell
}

/// One row per entity at this tab's grain (symbol for Positions, lot for Open Lots, etc).
pub struct EntityRow { pub entity_id: String, pub cells: Vec<CellValue> }

/// A single published tab: typed header row + entity rows, nothing else.
pub struct TabBand { pub kind: TabKind, pub headers: Vec<ColumnHeader>, pub rows: Vec<EntityRow> }

impl TabBand {
    /// Construction guarantees the invariant this spec cares about: the band
    /// is exactly [header, row_1 .. row_n] — no blank/subtotal/trailing rows,
    /// regardless of whether `entities` is empty.
    pub fn new(kind: TabKind, headers: Vec<ColumnHeader>, entities: Vec<EntityRow>) -> Self {
        debug_assert!(entities.iter().all(|r| r.cells.len() == headers.len()));
        Self { kind, headers, rows: entities }
    }
}

pub fn publish_tabs(
    positions: Vec<EntityRow>,
    open_lots: Vec<EntityRow>,
    realized: Vec<EntityRow>,
    tax: Vec<EntityRow>,
) -> [TabBand; 4] {
    [
        TabBand::new(TabKind::Positions, positions_headers(), positions),
        TabBand::new(TabKind::OpenLots, open_lots_headers(), open_lots),
        TabBand::new(TabKind::Realized, realized_headers(), realized),
        TabBand::new(TabKind::Tax, tax_headers(), tax),
    ]
}

fn positions_headers() -> Vec<ColumnHeader> {
    vec![
        ColumnHeader { name: "Symbol", ty: ColumnType::Text },
        ColumnHeader { name: "Quantity", ty: ColumnType::Quantity },
        ColumnHeader { name: "Cost Basis", ty: ColumnType::Cents },
        ColumnHeader { name: "Live Price", ty: ColumnType::Formula },
    ]
}
fn open_lots_headers() -> Vec<ColumnHeader> { vec![] /* elided, same pattern */ }
fn realized_headers() -> Vec<ColumnHeader> { vec![] }
fn tax_headers() -> Vec<ColumnHeader> { vec![] }
```

ASSUMPTIONS:
1. "Entity" is tab-local grain, not a single global concept: one symbol for Positions, one lot for Open Lots, one closed-lot event for Realized, one taxable line for Tax. The spec doesn't define grain per tab, so `EntityRow` is generic over whatever the kernel already emits as one-row-per-thing for that tab.
2. "Typed headers" means each header cell carries a declared `ColumnType` used to set the column's Sheets number format (currency, percent, date) — not that header text itself has a runtime type.
3. "No among-data summary rows" is interpreted as: no totals/subtotal rows anywhere inside the band, including a trailing grand-total row — the band is strictly `[header] ++ [one row per entity]`. Any totals belong elsewhere (e.g., a separate dashboard tab), out of scope here.
4. Empty entity list is valid, not an error: the band is header-only with zero data rows.
5. Row order is whatever the kernel provides (assumed stable/sorted); the spec only requires filter/sort compatibility, not a mandated order.
6. Money fields use `i64` Cents per project convention; `Quantity`/`Percent` use `f64` since fractional shares/percentages aren't in scope of this spec.
7. The four `TabKind` variants are fixed and exhaustive — no provision for dynamic/additional tabs.
8. "Read-only" is enforced upstream (sheet protection / publish pipeline), not by this data structure; this sketch only guarantees shape, not access control.
9. `Formula` cell type exists to carry the GOOGLEFINANCE oracle string mentioned in the broader system context, even though this EARS text doesn't mention pricing — included as a plausible Positions column, not asserted as required by SHEET-TAB-001 itself.