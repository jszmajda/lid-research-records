```rust
// crates/sheets-view/src/tax_tab.rs
// @spec SHEET-FORMULA-004

use crate::{Cents, TabGrid, Cell, SyncStamp};

/// Kernel-computed, as-of-last-sync tax figures. All money is integer Cents.
/// The kernel produces these; this module only projects them.
pub struct TaxRow {
    pub lot_id: String,
    pub symbol: String,
    pub qty: i64,                 // scaled shares (1e6 = 1 share)
    pub cost_basis: Cents,
    pub proceeds_or_mark: Cents,  // stacked mark at last settle
    pub realized_gain: Cents,
    pub unrealized_gain: Cents,
    pub holding: Holding,         // Short | Long
    pub tax_adjustment: Cents,    // washes/adjustments, kernel-computed
}

pub enum Holding { Short, Long }

pub struct TaxView {
    pub rows: Vec<TaxRow>,
    pub as_of: SyncStamp,          // last settle timestamp, kernel-supplied
}

/// Renders the Tax tab. Every money cell is a LITERAL from the kernel —
/// no GOOGLEFINANCE formula, no arithmetic here. That literalness IS the
/// "distinct from the Positions live estimate" requirement.
pub fn render_tax_tab(view: &TaxView) -> TabGrid {
    let mut g = TabGrid::new("Tax");
    g.push_row(vec![Cell::note(format!(
        "Kernel-exact, as of last sync {}. Not live; see Positions for live estimate.",
        view.as_of.to_rfc3339()
    ))]);
    g.push_row(header());
    for r in &view.rows {
        g.push_row(vec![
            Cell::text(&r.lot_id),
            Cell::text(&r.symbol),
            Cell::qty(r.qty),
            Cell::money(r.cost_basis),
            Cell::money(r.proceeds_or_mark),
            Cell::money(r.realized_gain),
            Cell::money(r.unrealized_gain),
            Cell::text(match r.holding { Holding::Short => "Short", Holding::Long => "Long" }),
            Cell::money(r.tax_adjustment),
        ]);
    }
    g.push_row(totals(&view.rows)); // sums of Cents, i128 accumulator, saturating
    g
}
```

INTERPRETATION CHOSEN: "kernel-exact" = the Tax tab contains zero formulas; Positions may hold `=GOOGLEFINANCE(...)`, Tax holds only settled literals. "Stacked" read as lot-level rows that aggregate to totals (lot stacking), not as stacked-bar formatting. "Distinct" read as satisfied by construction (no live cell) plus an explicit as-of banner, not by a separate diffing column — a diff against a live estimate would reintroduce liveness into Tax.

ASSUMPTIONS INVENTED:
1. `Cents` is a newtype over i64; totals accumulate in i128 and saturate rather than panic on overflow.
2. Kernel supplies all tax math; this module does no tax logic beyond column summation — arguably even summation belongs in the kernel, so totals are a candidate to move if the crate boundary is read strictly.
3. `SyncStamp` exists and is populated by the settle pass; if absent (never synced) the banner reads "never synced" and rows render empty rather than erroring.
4. Quantity scale 1e6 fixed-point; no fractional-cent representation anywhere.
5. Holding period is a kernel-classified enum, not derived from dates here.
6. Empty ledger → header + banner only, no error.
7. Wash-sale/other adjustments collapse into one `tax_adjustment` column; jurisdiction, tax year filtering, and per-account partitioning are out of scope of this EARS.
8. Tab is fully rewritten each publish (read-only, no user edits preserved).
9. Cell formatting (currency display) is a sheet number-format concern, applied by `Cell::money`, not string formatting here.