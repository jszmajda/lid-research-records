```rust
/// SHEET-TAB-001: four read-only view tabs, one row per entity, typed
/// headers, no interleaved summary rows.

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum ViewTab {
    Positions,
    OpenLots,
    Realized,
    Tax,
}

impl ViewTab {
    pub const ALL: [ViewTab; 4] =
        [ViewTab::Positions, ViewTab::OpenLots, ViewTab::Realized, ViewTab::Tax];

    fn sheet_title(self) -> &'static str {
        match self {
            ViewTab::Positions => "Positions",
            ViewTab::OpenLots => "Open Lots",
            ViewTab::Realized => "Realized",
            ViewTab::Tax => "Tax",
        }
    }
}

/// One typed column header: display name plus the Sheets-facing type,
/// used to set per-column number format so filter/sort compare correctly.
pub struct ColumnHeader {
    pub name: &'static str,
    pub kind: ColumnKind,
}

pub enum ColumnKind {
    Text,
    Integer,   // Cents, share counts
    Date,
    Formula,   // e.g. GOOGLEFINANCE cell
}

/// A published tab: header row + one data row per entity, nothing else.
pub struct SheetBand {
    pub tab: ViewTab,
    pub headers: Vec<ColumnHeader>,
    pub rows: Vec<Vec<CellValue>>,
}

pub enum CellValue {
    Text(String),
    Cents(i64),
    Date(String),
    Formula(String),
}

/// Builds the four bands from kernel projections. Each `entities` slice
/// is already one-row-per-entity from the kernel; this function only
/// shapes it for Sheets — no aggregation, no inserted totals/subtotals.
pub fn build_view_tabs(
    positions: Vec<Vec<CellValue>>,
    open_lots: Vec<Vec<CellValue>>,
    realized: Vec<Vec<CellValue>>,
    tax: Vec<Vec<CellValue>>,
) -> Vec<SheetBand> {
    vec![
        SheetBand { tab: ViewTab::Positions, headers: positions_headers(), rows: positions },
        SheetBand { tab: ViewTab::OpenLots, headers: open_lots_headers(), rows: open_lots },
        SheetBand { tab: ViewTab::Realized, headers: realized_headers(), rows: realized },
        SheetBand { tab: ViewTab::Tax, headers: tax_headers(), rows: tax },
    ]
}

fn positions_headers() -> Vec<ColumnHeader> { vec![] /* elided */ }
fn open_lots_headers() -> Vec<ColumnHeader> { vec![] }
fn realized_headers() -> Vec<ColumnHeader> { vec![] }
fn tax_headers() -> Vec<ColumnHeader> { vec![] }
```

Assumptions:
1. "Entity" = one row per ledger entity relevant to that tab (position, lot, realized-event, tax-lot record) — EARS doesn't define "entity" per tab, so I treat it generically via a pre-shaped `Vec<Vec<CellValue>>` input, deferring per-tab schema.
2. "Typed headers" interpreted as header metadata carrying a Sheets value type (text/integer/date/formula) for column formatting, not literal "Type:" strings in header text — ambiguous, chose the formatting-oriented reading since it serves "native filtering/sorting."
3. "No among-data summary rows" means zero inserted totals/subtotals/blank separators between data rows; summary values (if any) must live outside this band (e.g., separate cell range or tab), not enforced in code here beyond omission.
4. Four tabs are fixed and exhaustive (`ViewTab::ALL`) — no dynamic tab list.
5. Empty entity set is valid: zero data rows, header row still published (not asserted/panicking).
6. Money fields use `i64` Cents per project convention; `Formula` variant models the GOOGLEFINANCE oracle cell as raw formula text.
7. This module only shapes data (`sheets-view` concern); it assumes kernel output already excludes accounting/tax computation, per project scope note.
8. No dedup/sort logic invoked — native Sheets sort/filter is relied upon per the "so that," so rows are emitted in kernel-given order.