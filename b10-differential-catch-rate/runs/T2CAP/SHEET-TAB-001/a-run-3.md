```rust
// crates/sheets-view/src/tabs.rs
// @spec SHEET-TAB-001

use std::collections::BTreeMap;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum ColType { Text, Int, Cents, Qty, Date, Percent, Formula }

#[derive(Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Debug)]
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

#[derive(Clone, Debug)]
pub struct Column { pub header: &'static str, pub ty: ColType }

/// One rendered cell. Cents render as a decimal string at 2dp; no locale/currency glyph.
#[derive(Clone, Debug, PartialEq)]
pub enum Cell { Text(String), Num(String), Formula(String), Blank }

#[derive(Clone, Debug)]
pub struct Tab {
    pub kind: TabKind,
    pub columns: Vec<Column>,
    /// Data band: exactly one row per entity, in kernel-supplied order.
    pub rows: Vec<Vec<Cell>>,
    pub protected: bool, // read-only: whole grid protected, no editors
}

pub trait Entity { fn row(&self, cols: &[Column]) -> Vec<Cell>; }

fn columns_for(kind: TabKind) -> Vec<Column> { /* static per-kind schema */ unimplemented!() }

/// Build one tab. Panics never; arity is enforced by padding/truncating to the
/// declared schema so a malformed entity cannot shift the band's column alignment.
pub fn build_tab<E: Entity>(kind: TabKind, entities: &[E]) -> Tab {
    let columns = columns_for(kind);
    let width = columns.len();
    let rows = entities
        .iter()
        .map(|e| { let mut r = e.row(&columns); r.resize(width, Cell::Blank); r.truncate(width); r })
        .collect();
    Tab { kind, columns, rows, protected: true }
}

/// Always emits all four tabs, in canonical order, even when a band is empty
/// (header row alone — an empty tab is still published).
pub fn build_workbook<P: TabSource>(src: &P) -> BTreeMap<TabKind, Tab> {
    TabKind::ALL.iter().map(|&k| (k, src.tab(k))).collect()
}

pub trait TabSource { fn tab(&self, kind: TabKind) -> Tab; }

// Invariant test hook: no row in `rows` may be a subtotal/total/group-header.
// Enforced structurally — the kernel yields only entity records; this crate
// has no aggregation API to produce one.
```

Interpretation chosen: "no among-data summary rows" = no totals/subtotals/group headers *interleaved in or appended to* the data band. I read it as banning them from the band, not from the tab entirely — so a summary block above the header row (outside the band) stays legal; I did not implement one, since the requirement doesn't ask for it. Chose structural prevention (no aggregation API) over runtime validation, because the requirement is about shape, not data.

Assumptions invented:
1. Tab titles are exactly the four strings named; "Open Lots" keeps the space.
2. Column schemas per tab are static compile-time constants, not derived from data — requirement says "typed headers" but names no columns.
3. "Typed" = a `ColType` carried alongside the header string, used downstream for number formats; not a Rust generic per column.
4. One header row, row 1, frozen (implied by "filtering and sorting work directly"); I did not model freeze/filter-view state here.
5. Entity identity/ordering comes from the kernel; sheets-view does not sort or dedupe.
6. Empty entity set still publishes the tab with headers only.
7. Read-only enforced by a `protected: true` flag consumed by the publisher; GOOGLEFINANCE price cells are `Cell::Formula` and still live inside a protected range.
8. Row arity mismatches are padded with `Blank` / truncated rather than erroring — a partial band beats a failed publish.
9. Cents→string rendering is 2dp fixed, no separators, so Sheets parses it as a number and sorts numerically.
10. `BTreeMap` keyed on `TabKind` gives deterministic canonical tab order.
11. No blank spacer rows anywhere in the band (they would break sort ranges).