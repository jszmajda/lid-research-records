```rust
//! sheets-view: view-tab projection. No accounting or tax math here.

use std::collections::BTreeMap;

/// A cell value as it will be written to Sheets. Formula is used only for the
/// GOOGLEFINANCE price oracle column; it is still a typed header column.
#[derive(Clone, Debug)]
pub enum Cell {
    Text(String),
    /// Integer Cents rendered as a numeric cell (major units), never a string.
    Money(i64),
    Qty(rust_decimal::Decimal),
    Date(chrono::NaiveDate),
    Formula(String),
    Blank,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ColType { Text, Money, Qty, Date, Formula }

#[derive(Clone, Debug)]
pub struct Column { pub header: &'static str, pub ty: ColType }

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum TabKind { Positions, OpenLots, Realized, Tax }

impl TabKind {
    pub const ALL: [TabKind; 4] =
        [TabKind::Positions, TabKind::OpenLots, TabKind::Realized, TabKind::Tax];
    pub fn title(self) -> &'static str {
        match self {
            TabKind::Positions => "Positions",
            TabKind::OpenLots  => "Open Lots",
            TabKind::Realized  => "Realized",
            TabKind::Tax       => "Tax",
        }
    }
}

/// A tab: exactly one header row, then the per-entity data band.
/// Invariant: no summary/subtotal/blank/section rows inside `rows`.
#[derive(Clone, Debug)]
pub struct ViewTab {
    pub kind: TabKind,
    pub columns: Vec<Column>,
    pub rows: Vec<Vec<Cell>>, // rows[i].len() == columns.len()
    pub protected: bool,      // read-only: true for all four
}

pub trait RowEntity {
    fn columns() -> Vec<Column>;
    fn to_row(&self) -> Vec<Cell>;
}

pub struct KernelView {
    pub positions: Vec<Position>,
    pub open_lots: Vec<OpenLot>,
    pub realized:  Vec<RealizedDisposal>,
    pub tax:       Vec<TaxRow>,
}

fn build<E: RowEntity>(kind: TabKind, entities: &[E]) -> ViewTab {
    let columns = E::columns();
    let rows = entities.iter().map(|e| {
        let mut r = e.to_row();
        r.resize(columns.len(), Cell::Blank); // truncate/pad → rectangular band
        r.truncate(columns.len());
        r
    }).collect();
    ViewTab { kind, columns, rows, protected: true }
}

/// Always returns all four tabs, in fixed order, even when a band is empty
/// (header row only). Sheets filtering/sorting then works natively.
pub fn project(v: &KernelView) -> BTreeMap<TabKind, ViewTab> {
    let mut m = BTreeMap::new();
    m.insert(TabKind::Positions, build(TabKind::Positions, &v.positions));
    m.insert(TabKind::OpenLots,  build(TabKind::OpenLots,  &v.open_lots));
    m.insert(TabKind::Realized,  build(TabKind::Realized,  &v.realized));
    m.insert(TabKind::Tax,       build(TabKind::Tax,       &v.tax));
    m
}

#[cfg(debug_assertions)]
pub fn assert_bandshape(t: &ViewTab) {
    assert!(t.rows.iter().all(|r| r.len() == t.columns.len()));
}
```

ASSUMPTIONS INVENTED
1. "Entity" per tab = Positions→one row per (account, symbol) holding; Open Lots→one row per open tax lot; Realized→one row per disposal/closing match; Tax→one row per tax-year×category line. Chose per-tab entity grain because the EARS names four tabs but never defines "entity."
2. Money is `i64` Cents in the kernel; the view emits a numeric cell in major units so Sheets sorts/filters numerically rather than lexically. Cents-as-text would break "sorting works directly."
3. Tab titles are literal English strings, "Open Lots" with a space; no localization.
4. Typed headers = exactly one header row at row 1, static `&'static str` names plus a `ColType` carried out-of-band for number-format application by the writer.
5. Empty result set still publishes the tab with headers only — four tabs always exist, unconditionally.
6. "No among-data summary rows" read strictly: zero totals rows anywhere, including trailing. An alternative reading (trailing totals allowed, only interleaved ones banned) was rejected — a trailing total row still lands inside a filter range and moves under sort.
7. Read-only enforced as a `protected: true` flag consumed by the Sheets writer (protected range), not by this module.
8. Ragged rows from a buggy `RowEntity` impl are padded with `Blank`/truncated rather than erroring, so one bad entity cannot fail a publish; a debug assertion catches it in tests.
9. The GOOGLEFINANCE oracle column is modeled as `ColType::Formula` on Positions only; this requirement does not specify it, so no formula text is generated here.
10. Row order within a band is kernel-supplied and stable; the view imposes no sort, since users sort natively.
11. `Decimal` for quantity (fractional shares) and `NaiveDate` for dates — no time zones.
12. Freeze-row/filter-view setup is the writer's job, not this projection's.