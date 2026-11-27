```rust
// crates/sheets-view/src/tabs/tax.rs
// @spec SHEET-FORMULA-004
use crate::{Cents, TabGrid, Cell, Kernel Tax types};

/// Kernel-exact tax figures: no GOOGLEFINANCE formulas, all literal Cents
/// values stamped from the last completed sync of the kernel ledger.
pub struct TaxTabInput<'a> {
    pub as_of: KernelSyncStamp,          // event-log seq + UTC timestamp of last sync
    pub lots: &'a [RealizedLotRow],      // kernel-computed, already stacked
    pub totals: TaxTotals,               // kernel-computed rollups
}

pub struct RealizedLotRow {
    pub symbol: String,
    pub acquired: NaiveDate,
    pub disposed: NaiveDate,
    pub qty: Qty,
    pub proceeds: Cents,
    pub basis: Cents,          // adjusted basis (wash/corp-action already applied by kernel)
    pub gain: Cents,           // proceeds - basis, kernel-computed; view never recomputes
    pub term: Term,            // Short | Long, kernel-classified
    pub wash_disallowed: Cents,
}

pub struct TaxTotals {
    pub short_gain: Cents, pub long_gain: Cents,
    pub wash_disallowed: Cents, pub net_gain: Cents,
}

pub fn render_tax_tab(input: &TaxTabInput) -> TabGrid {
    let mut g = TabGrid::new("Tax");
    // Provenance banner — makes "as-of-last-sync, not live" legible, and
    // distinguishes this tab from Positions' GOOGLEFINANCE estimate.
    g.push_row([Cell::text(format!(
        "Kernel-exact, as of last sync {} (event #{}). Figures are stacked and do NOT \
         track live prices; see Positions for the live market estimate.",
        input.as_of.utc.format("%Y-%m-%d %H:%M UTC"), input.as_of.seq))]);
    g.push_header(["Symbol","Acquired","Disposed","Qty","Proceeds","Adj Basis",
                   "Wash Disallowed","Gain/Loss","Term"]);
    for l in input.lots {                       // preserve kernel order (the stack)
        g.push_row([Cell::text(&l.symbol), Cell::date(l.acquired), Cell::date(l.disposed),
                    Cell::qty(l.qty), Cell::money(l.proceeds), Cell::money(l.basis),
                    Cell::money(l.wash_disallowed), Cell::money(l.gain),
                    Cell::text(l.term.as_str())]);
    }
    g.push_totals(["Total","","","", "", "", Cell::money(input.totals.wash_disallowed),
                   Cell::money(input.totals.net_gain), ""]);
    g.push_row([Cell::money(input.totals.short_gain), Cell::money(input.totals.long_gain)]);
    g
}
```

Interpretation chosen: "kernel-exact (stacked, as-of-last-sync)" = the view emits **literal Cents values** produced by the kernel at the last settled sync, never a formula; "distinct from the Positions live estimate" is satisfied both structurally (zero `=GOOGLEFINANCE` cells on this tab) and legibly (an explicit as-of provenance banner naming the contrast). Chose this over "Tax shows a delta vs. Positions" because the requirement says *distinct from*, not *reconciled against*.

Assumptions invented:
1. `Cents` is `i64`; `Cell::money` renders a signed decimal literal, not a formula.
2. "Stacked" = kernel-ordered realized-lot rows (lot stack / disposal order), preserved verbatim; the view never sorts or aggregates.
3. Kernel supplies `gain`, `term`, adjusted basis, and wash-sale disallowance already computed — sheets-view does zero tax math (per crate boundary).
4. `as_of` carries both event-log sequence number and UTC timestamp; formatted `%Y-%m-%d %H:%M UTC`.
5. Empty `lots` → banner + header + zero totals row (tab always rendered, never omitted).
6. No live-price input is accepted by this function at all — unrepresentable rather than merely unused.
7. Sync staleness is not flagged/thresholded here (no requirement text for it); the banner states the timestamp and lets the reader judge.
8. Term buckets limited to Short/Long; no collectibles/1256 categories.
9. Output is a read-only `TabGrid`; publishing/write-back is a caller concern.
10. Negative gains render as negative Cents; no separate loss column.