```rust
/// SHEET-TAB-001: four read-only view tabs, one row per entity, no
/// interleaved summary rows, typed headers for native Sheets filter/sort.

pub enum ViewTab { Positions, OpenLots, Realized, Tax }

impl ViewTab {
    fn sheet_name(&self) -> &'static str {
        match self {
            ViewTab::Positions => "Positions",
            ViewTab::OpenLots => "Open Lots",
            ViewTab::Realized => "Realized",
            ViewTab::Tax => "Tax",
        }
    }
}

/// A typed column header; Sheets needs a stable type per column for
/// filter/sort to behave (e.g. numeric compare vs. lexicographic).
pub enum ColumnType { Text, Integer, Cents, Date, Percent }

pub struct ColumnSpec { pub name: &'static str, pub ty: ColumnType }

/// One row = one entity (position, lot, realized event, or tax line).
/// Cell values are pre-formatted kernel output; sheets-view does no math.
pub enum CellValue { Text(String), Integer(i64), Cents(i64), Date(String), Percent(f64), Empty }

pub struct SheetTabData {
    pub tab: ViewTab,
    pub headers: Vec<ColumnSpec>,
    pub rows: Vec<Vec<CellValue>>, // no summary/blank/subtotal rows mixed in
}

/// Publishes the four tabs from kernel-projected rows. Pure assembly:
/// takes already-computed per-entity rows and lays them into the
/// data-band + header shape the spec requires. Does not compute
/// positions/lots/realized/tax values itself.
pub fn build_view_tabs(
    positions: Vec<Vec<CellValue>>,
    open_lots: Vec<Vec<CellValue>>,
    realized: Vec<Vec<CellValue>>,
    tax: Vec<Vec<CellValue>>,
) -> Vec<SheetTabData> {
    vec![
        SheetTabData { tab: ViewTab::Positions, headers: positions_headers(), rows: positions },
        SheetTabData { tab: ViewTab::OpenLots, headers: open_lots_headers(), rows: open_lots },
        SheetTabData { tab: ViewTab::Realized, headers: realized_headers(), rows: realized },
        SheetTabData { tab: ViewTab::Tax, headers: tax_headers(), rows: tax },
    ]
}

fn positions_headers() -> Vec<ColumnSpec> {
    vec![
        ColumnSpec { name: "Symbol", ty: ColumnType::Text },
        ColumnSpec { name: "Quantity", ty: ColumnType::Integer },
        ColumnSpec { name: "Market Value", ty: ColumnType::Cents },
    ]
}
fn open_lots_headers() -> Vec<ColumnSpec> {
    vec![
        ColumnSpec { name: "Symbol", ty: ColumnType::Text },
        ColumnSpec { name: "Open Date", ty: ColumnType::Date },
        ColumnSpec { name: "Cost Basis", ty: ColumnType::Cents },
    ]
}
fn realized_headers() -> Vec<ColumnSpec> {
    vec![
        ColumnSpec { name: "Close Date", ty: ColumnType::Date },
        ColumnSpec { name: "Gain/Loss", ty: ColumnType::Cents },
    ]
}
fn tax_headers() -> Vec<ColumnSpec> {
    vec![
        ColumnSpec { name: "Year", ty: ColumnType::Integer },
        ColumnSpec { name: "ST Gain", ty: ColumnType::Cents },
        ColumnSpec { name: "LT Gain", ty: ColumnType::Cents },
    ]
}
```

Assumptions:
1. "Per-entity" row identity means one entity = one row within each tab; column sets differ per tab (positions vs. lots vs. realized events vs. tax lines are different entity kinds), so headers are tab-specific, not shared.
2. Empty input (zero entities) yields a header-only tab, not an error or placeholder row — satisfies "no among-data summary rows" trivially.
3. "Typed headers" means each column declares a single logical type for the whole column (enforced by `ColumnType`), not that the header cell itself carries a data type in Sheets.
4. "No among-data summary rows" is interpreted as: no subtotal/blank-separator/grand-total rows interleaved with entity rows; a summary could still exist elsewhere (e.g. a separate tab or a frozen header), just not inside this data band.
5. Row order is whatever order the kernel supplies (assumed already deterministic); this module does no sorting — Sheets' native sort is expected to be the sort mechanism per the "so native filtering/sorting work" rationale.
6. Cents values are passed through as already-computed `i64` — no currency formatting/aggregation happens here, consistent with sheets-view owning no accounting math.
7. GOOGLEFINANCE live-price and marks read-back settle pass are out of scope for this sketch — assumed injected upstream into the `Cents`/market-value fields before rows reach this module.
8. "Read-only" is enforced at the Sheets-API/publish layer (not modeled here) — this sketch only produces the data+header structure to be written.
9. No explicit handling for malformed/partial kernel rows (e.g. mismatched column count) — assumed kernel output is already validated upstream; this module trusts row-vector length matches header length.