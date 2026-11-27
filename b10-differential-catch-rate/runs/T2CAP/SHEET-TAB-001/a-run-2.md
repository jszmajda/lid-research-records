```rust
// crates/sheets-view/src/tabs.rs
// @spec SHEET-TAB-001

#[derive(Copy, Clone, PartialEq, Eq, Hash, Debug)]
pub enum TabKind { Positions, OpenLots, Realized, Tax }

impl TabKind {
    /// Fixed publication order; tab title as it appears in the workbook.
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

/// Header cell: name + the type the column's data cells must all carry.
#[derive(Clone, Debug)]
pub struct Header { pub name: &'static str, pub ty: CellType }

#[derive(Copy, Clone, PartialEq, Eq, Debug)]
pub enum CellType { Text, Integer, Cents, Qty, Date, Formula }

#[derive(Clone, Debug)]
pub enum Cell { Text(String), Integer(i64), Cents(i64), Qty(i128), Date(NaiveDate), Formula(String), Blank }

/// One rendered tab: exactly one header row, then the data band.
#[derive(Clone, Debug)]
pub struct TabGrid { pub kind: TabKind, pub headers: Vec<Header>, pub rows: Vec<Vec<Cell>> }

pub trait TabProjection {
    const KIND: TabKind;
    fn headers() -> Vec<Header>;
    /// Entities in the tab's canonical order; one row each.
    fn rows(kernel: &KernelOutput) -> Vec<Vec<Cell>>;
}

#[derive(Debug)]
pub enum TabError {
    Arity  { kind: TabKind, row: usize, got: usize, want: usize },
    CellType { kind: TabKind, row: usize, col: usize, want: CellType, got: CellType },
}

pub fn build_tab<P: TabProjection>(kernel: &KernelOutput) -> Result<TabGrid, TabError> {
    let headers = P::headers();
    let rows = P::rows(kernel);
    for (r, row) in rows.iter().enumerate() {
        if row.len() != headers.len() {
            return Err(TabError::Arity { kind: P::KIND, row: r, got: row.len(), want: headers.len() });
        }
        for (c, cell) in row.iter().enumerate() {
            // Blank is the universal empty; everything else must match the header type.
            if !matches!(cell, Cell::Blank) && cell.ty() != headers[c].ty {
                return Err(TabError::CellType { kind: P::KIND, row: r, col: c, want: headers[c].ty, got: cell.ty() });
            }
        }
    }
    Ok(TabGrid { kind: P::KIND, headers, rows })
}

/// All four tabs, always all four, in fixed order — an empty band is still published.
pub fn build_all(kernel: &KernelOutput) -> Result<Vec<TabGrid>, TabError> {
    Ok(vec![
        build_tab::<PositionsTab>(kernel)?,
        build_tab::<OpenLotsTab>(kernel)?,
        build_tab::<RealizedTab>(kernel)?,
        build_tab::<TaxTab>(kernel)?,
    ])
}
```

Assumptions invented:
1. "Entity" = the tab's natural row unit (Positions→symbol/account position, Open Lots→open lot, Realized→closing disposal, Tax→tax-year line); requirement doesn't name them.
2. Column sets per tab are left to per-tab `TabProjection` impls — the EARS constrains shape, not content.
3. "Typed headers" interpreted as: one header row whose cells declare a column type enforced across the band (the structural reading), not merely Sheets number-format application; format application is a downstream concern that consumes `Header.ty`.
4. "No among-data summary rows" enforced structurally by construction — no total/subtotal row can be emitted because rows come only from per-entity projection. Assumed totals, if wanted, live outside the band (above the header or on another tab); this sketch emits none.
5. Empty result set still publishes the tab with its header row (zero data rows) rather than skipping it.
6. Fixed tab order and exact titles ("Open Lots" with a space) assumed from the EARS's enumeration order.
7. `Cell::Blank` allowed in any typed column as the missing-value representation; no other type coercion permitted — mismatch is a hard `TabError`, not a silent stringification, because a wrong-typed cell breaks native sort/filter (the requirement's stated purpose).
8. Row ordering delegated to the projection; sorting deliberately not imposed since Sheets sorting is the user-facing mechanism.
9. Read-only-ness (protected ranges, no user-editable cells) assumed to be applied by the publisher that consumes `TabGrid`; not modeled here beyond the absence of any write-back path.
10. `Cell::Formula` variant retained so the GOOGLEFINANCE price column can be a per-row formula and still count as one row per entity.
11. `KernelOutput`, `NaiveDate`, and `Cell::ty()` assumed to exist; money as integer `Cents(i64)`, quantities as scaled `i128`.
12. Header names are `&'static str` — assumed static, not locale- or config-driven.