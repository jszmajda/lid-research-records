```rust
/// Positions tab, live post-tax columns (@spec SHEET-FORMULA-003).
/// sheets-view emits *formula strings* for cells it owns; it does not
/// compute P&L or tax — those live upstream (kernel, `tax` crate).
pub struct PositionRowRefs {
    pub row: u32,          // 1-based sheet row
    pub market_value_col: &'static str, // e.g. "F" (GOOGLEFINANCE-driven)
    pub cost_basis_col: &'static str,   // e.g. "E"
    pub est_tax_rate_col: &'static str, // e.g. "H", written by `tax`
}

pub struct PositionFormulas {
    pub unrealized_pl: String,   // pre-tax
    pub net_unrealized: String,  // live post-tax estimate
}

pub const UNREALIZED_PL_HEADER: &str = "Unrealized P&L";
pub const NET_UNREALIZED_HEADER: &str = "Net Unrealized (Est.)";
pub const EST_TAX_RATE_HEADER: &str = "Est. Tax Rate";

pub fn position_formulas(r: &PositionRowRefs) -> PositionFormulas {
    let pl_cell = format!("{}{}", "PL_PLACEHOLDER", r.row); // see assumption 2
    let unrealized_pl = format!(
        "={mv}{row}-{cb}{row}",
        mv = r.market_value_col, cb = r.cost_basis_col, row = r.row
    );
    let net_unrealized = format!(
        "=IFERROR({pl}*(1-{tax}{row}),\"\")",
        pl = format!("{col}{row}", col = pl_col_of(&unrealized_pl), row = r.row),
        tax = r.est_tax_rate_col, row = r.row
    );
    let _ = pl_cell;
    PositionFormulas { unrealized_pl, net_unrealized }
}

// Placeholder: real code resolves the Unrealized P&L column letter from
// the sheet layout rather than string-parsing the formula.
fn pl_col_of(_f: &str) -> &'static str { "G" }
```

Assumptions (invented, not in the EARS text):

1. **Formula, not precompute**: "live" + the GOOGLEFINANCE-oracle context means Unrealized P&L and Net Unrealized are spreadsheet formulas referencing a market-value cell (itself GOOGLEFINANCE-derived), not values computed in Rust — consistent with "sheets-view owns no accounting or tax math."
2. **Est. Tax Rate is a plain written value**, not a formula — "written by `tax`" means the kernel/tax crate computes and hands sheets-view a number to place in its own column; sheets-view only *references* that cell.
3. **Rate representation**: assumed the tax crate supplies a plain fraction (0.0–1.0) already fit for `1-rate` arithmetic in-sheet; no basis-points conversion needed since it's not `Cents`.
4. **Missing/errored inputs**: wrapped in `IFERROR(...,"")` — if GOOGLEFINANCE errors or tax rate is blank (position not yet marked/settled by the marks read-back pass), Net Unrealized renders blank rather than propagating `#N/A`/`#REF!`.
5. **Labelling**: chose header suffix `(Est.)` on both post-tax columns to satisfy "post-tax columns shall be labelled estimates"; pre-tax P&L header carries no suffix.
6. **No clamping of Est. Tax Rate**: sheets-view treats out-of-range values (e.g. negative, >1) as an upstream `tax`-crate bug, not something it silently corrects — no accounting/tax math performed here.
7. **Column letters are caller-supplied** (from a layout module), not hardcoded knowledge in this function.