```rust
// sheets-view: Positions tab projection (SHEET-FORMULA-003)

/// Header labels; post-tax columns carry an explicit "(Est.)" marker.
pub const HEADERS: [&str; 3] = [
    "Unrealized P&L",
    "Est. Tax Rate",
    "Net Unrealized (Est.)",
];

/// One position's inputs as sheets-view receives them: a cell reference for
/// the (already live, GOOGLEFINANCE-backed) pre-tax P&L, and the per-position
/// effective unrealized tax rate as written by the `tax` crate.
pub struct PositionRow {
    pub pnl_cell: String,        // e.g. "F12", pre-tax Unrealized P&L cell/formula
    pub est_tax_rate: Option<f64>, // fraction in [0,1]; written by `tax`; None = no rate available
}

/// Column letters for this fixed layout.
const PNL_COL: &str = "F";
const RATE_COL: &str = "G";

/// Emits the live, sheet-native formula for Net Unrealized so it recalculates
/// whenever the underlying GOOGLEFINANCE-driven P&L or the tax-rate cell changes.
/// sheets-view never performs the multiplication itself — it only wires cell refs.
pub fn net_unrealized_formula(row: usize) -> String {
    format!("={PNL_COL}{row}*(1-{RATE_COL}{row})")
}

/// Value written into the Est. Tax Rate cell for this row.
/// `tax` owns the actual computation; sheets-view passes it through unchanged.
pub fn est_tax_rate_cell_value(row: &PositionRow) -> f64 {
    row.est_tax_rate.unwrap_or(0.0)
}
```

Assumptions (invented, not in the EARS text):

1. **"Live"** is interpreted as: Net Unrealized is a spreadsheet formula (`=F{row}*(1-G{row})`) recalculated by Sheets itself, mirroring the GOOGLEFINANCE pattern — not a value precomputed in Rust. This is the only reading consistent with "sheets-view owns no accounting or tax math," since doing the multiplication in Rust would itself be tax math.
2. `Est. Tax Rate` is a bare fraction in `[0, 1]` written into its own cell by `tax`; sheets-view does not validate, clamp, or interpret it — it trusts `tax` to have produced a sane value. Out-of-range input (e.g. negative or >1) is passed through unclamped.
3. Pre-tax `Unrealized P&L` is itself a cell reference/formula (not a raw `Cents` literal), since it's already live-priced elsewhere on the tab; sheets-view just threads the cell address through.
4. `est_tax_rate: Option<f64>` models "no rate available" (e.g. zero/undefined basis, position `tax` hasn't priced yet) as `None`, defaulting to `0.0` so `Net Unrealized == Unrealized P&L`; the column is still labelled an estimate regardless.
5. Column layout (`F`=P&L, `G`=rate) is illustrative/fixed for this sketch; real placement comes from the tab's column-assignment logic elsewhere.
6. "Labelled estimates" is satisfied purely via static header text (`"(Est.)"` suffix) on the post-tax column(s) only — no per-cell annotation or footnote mechanism assumed.
7. Currency/percentage number-formatting (Cents vs. dollars, percent display) is assumed handled by cell-format calls elsewhere, not by this function's return types.