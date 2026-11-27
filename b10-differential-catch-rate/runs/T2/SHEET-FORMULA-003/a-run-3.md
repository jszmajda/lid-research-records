```rust
//! sheets-view: Positions tab row emitter for SHEET-FORMULA-003.
//! Projects kernel/tax output into two post-tax-labelled Sheets cells.
//! No accounting or tax math performed here — only formula/text emission.

pub struct PositionsRowRefs {
    pub row: u32,               // 1-based sheet row for A1 formula refs
    pub unrealized_pnl_col: &'static str, // pre-tax P&L cell, e.g. "H"
    pub est_tax_rate_col: &'static str,   // written by `tax`, e.g. "I"
}

pub const EST_TAX_RATE_HEADER: &str = "Est. Tax Rate (estimate)";
pub const NET_UNREALIZED_HEADER: &str = "Net Unrealized (estimate)";
// Pre-tax header intentionally unsuffixed — spec labels only post-tax columns.
pub const UNREALIZED_PNL_HEADER: &str = "Unrealized P&L";

impl PositionsRowRefs {
    /// Live Sheets formula: recalculates whenever pre-tax P&L (price-driven)
    /// or Est. Tax Rate (tax-written) changes — no value computed in Rust.
    pub fn net_unrealized_formula(&self) -> String {
        format!(
            "={p}{r}*(1-{t}{r})",
            p = self.unrealized_pnl_col,
            t = self.est_tax_rate_col,
            r = self.row,
        )
    }
}
```

Assumptions (invented, not in the EARS text):

1. `Est. Tax Rate` is a plain numeric fraction (0.0–1.0) written into its own cell by `tax`; sheets-view treats it as opaque input, no range validation.
2. "Live" is interpreted as a native Sheets formula (like GOOGLEFINANCE), not a value computed once in Rust at publish time — so it recalculates whenever either referenced cell changes. Ambiguity: the EARS could instead mean a plain value refreshed on each kernel publish cycle; I chose the formula reading for consistency with the "live-price oracle" pattern elsewhere in the system.
3. Only the two post-tax-named columns (`Est. Tax Rate`, `Net Unrealized`) get the "estimate" label; pre-tax `Unrealized P&L` does not, since the spec says "the post-tax columns."
4. Pre-tax `Unrealized P&L` cell already exists/is populated by logic outside this spec's scope; this function only references it by column letter.
5. Blank/missing `Est. Tax Rate` (e.g., new position `tax` hasn't priced yet) is left to surface as a native Sheets `#VALUE!`/blank-as-zero — no defensive handling, since sheets-view owns no tax math and this is a display-only estimate.
6. Formula-based computation runs in Sheets' floating point, not integer Cents; acceptable because the column is explicitly an "estimate," not authoritative ledger data (which stays in Cents in the kernel).
7. Column letters (`H`, `I`) are illustrative constants; real code would resolve them from a header/column map at publish time rather than hardcoding.
8. One row per currently-open position assumed; closed/zero-share filtering happens upstream and is out of scope here.