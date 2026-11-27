```rust
//! sheets-view: Tax tab projection. Kernel-exact, as-of-last-sync.
//! @spec SHEET-FORMULA-004

use crate::{Cents, TabGrid, Row, Cell};

/// Kernel output for the Tax tab. Every field is already computed by the
/// kernel from the event log at `as_of`; sheets-view does NO tax math.
pub struct TaxView {
    pub as_of: SyncStamp,              // last settled sync (marks read-back)
    pub lots: Vec<TaxLotRow>,          // stacked: per lot, in kernel order
}

pub struct TaxLotRow {
    pub symbol: String,
    pub lot_id: LotId,
    pub acquired: NaiveDate,
    pub qty: Qty,                      // kernel decimal, not f64
    pub cost_basis: Cents,             // adjusted basis (wash-sale etc.)
    pub proceeds: Option<Cents>,       // Some => closed lot
    pub realized_gain: Option<Cents>,
    pub unrealized_gain: Cents,        // vs. settled mark at as_of
    pub term: Term,                    // Short | Long, kernel-classified
    pub wash_disallowed: Cents,
}

/// Project kernel tax output into a literal-value grid.
/// Emits NO formulas — in particular no GOOGLEFINANCE — so the tab can never
/// drift from the kernel between syncs.
pub fn render_tax_tab(v: &TaxView) -> TabGrid {
    let mut rows = Vec::with_capacity(v.lots.len() + 4);

    // Provenance banner: makes "distinct from Positions live estimate" visible.
    rows.push(Row::banner(format!(
        "Kernel-exact, as of last sync {} — static values, not live. \
         Positions tab shows a live GOOGLEFINANCE estimate and will differ.",
        v.as_of.render()
    )));
    rows.push(Row::header(&[
        "Symbol", "Lot", "Acquired", "Qty", "Adj Basis", "Proceeds",
        "Realized", "Unrealized (@sync)", "Term", "Wash Disallowed",
    ]));

    for l in &v.lots {
        rows.push(Row::new(vec![
            Cell::text(&l.symbol),
            Cell::text(&l.lot_id.to_string()),
            Cell::date(l.acquired),
            Cell::qty(l.qty),
            Cell::money(l.cost_basis),
            l.proceeds.map_or(Cell::blank(), Cell::money),
            l.realized_gain.map_or(Cell::blank(), Cell::money),
            Cell::money(l.unrealized_gain),
            Cell::text(l.term.as_str()),
            Cell::money(l.wash_disallowed),
        ]));
    }

    // Totals are kernel-supplied via stacked sum of the same Cents; summing
    // integer Cents here is exact and introduces no tax judgment.
    rows.push(Row::total_of(&rows));
    TabGrid::new("Tax", rows)
}
```

ASSUMPTIONS (all invented):
1. "Kernel-exact" = literal Cents values only; the Tax tab emits zero spreadsheet formulas, unlike Positions' GOOGLEFINANCE column. Chosen interpretation of "distinct from the Positions live estimate."
2. "Stacked" = per-tax-lot rows (lot stack) rendered in kernel order, with totals appended — not a pivot/aggregate-only view.
3. "As-of-last-sync" = the settled marks timestamp from the read-back pass; rendered in a banner so a reader cannot mistake it for live.
4. Kernel supplies all tax classification (short/long, wash-sale disallowance, adjusted basis); sheets-view only formats.
5. Money is `Cents` (i64); quantities are a kernel decimal type, never f64.
6. Open lots: `proceeds`/`realized_gain` are `None` → blank cells, not zero (zero would read as a realized wash).
7. Empty `lots` → banner + header + zeroed totals row, never an error or an empty tab.
8. Totals computed by integer summation in-view; asserted no-op relative to kernel totals if kernel also supplies them.
9. No currency conversion, no per-year tax bracket math, no estimated-tax-owed figure — none is implied by the requirement.
10. `SyncStamp` renders in a fixed format; a missing stamp (never-synced workbook) renders "NEVER SYNCED" and the tab body is suppressed.
11. Cross-tab consistency is not enforced at render time; the banner is the only reconciliation of the two figures.

AMBIGUITY: "tax-adjusted figures" could mean after-tax valuations (value minus estimated liability) rather than tax-basis-adjusted lots. I chose basis-adjusted lots because the crate owns no tax math and an after-tax valuation would require rate assumptions the kernel is not stated to hold.