```rust
/// One row of the Positions tab, as emitted by sheets-view.
/// sheets-view does no accounting/tax math itself: `unrealized_pnl_cell`
/// and `est_tax_rate` are read verbatim from kernel/`tax` output. The
/// post-tax value is emitted as a *sheet formula* referencing those cells
/// so Sheets recomputes it live whenever the GOOGLEFINANCE-driven
/// Unrealized P&L cell changes — sheets-view never evaluates it in Rust.
pub struct PositionRow {
    pub symbol: String,
    /// A1 reference to the cell holding pre-tax Unrealized P&L (Cents,
    /// itself a formula derived from GOOGLEFINANCE market value − basis).
    pub unrealized_pnl_cell: String,
    /// Per-position effective unrealized tax rate written by `tax`.
    /// `None` when `tax` has not produced an estimate for this position.
    pub est_tax_rate: Option<f64>,
    /// A1 reference to the cell holding `est_tax_rate`.
    pub est_tax_rate_cell: String,
}

pub const HEADER_UNREALIZED_PNL: &str = "Unrealized P&L";
pub const HEADER_NET_UNREALIZED: &str = "Net Unrealized (est.)";
pub const HEADER_EST_TAX_RATE: &str = "Est. Tax Rate (est.)";

/// Builds the live formula for the Net Unrealized cell.
pub fn net_unrealized_formula(row: &PositionRow) -> String {
    match row.est_tax_rate {
        Some(_) => format!(
            "={}*(1-{})",
            row.unrealized_pnl_cell, row.est_tax_rate_cell
        ),
        // No tax estimate yet: surface as an explicit gap, not a silent 0%.
        None => "=NA()".to_string(),
    }
}
```

Assumptions:
1. `est_tax_rate` is a fraction in `[0.0, 1.0)` (not basis points); sheets-view does not clamp or validate it — that's `tax`'s job, per the crate boundary in the prompt.
2. Net Unrealized is delivered as a **spreadsheet formula string**, not a precomputed `Cents` value in Rust, because (a) it must be "live" like the GOOGLEFINANCE column, and (b) `Cents × f64` multiplication/rounding is accounting math, which sheets-view is stated to not own.
3. Missing/unavailable tax estimate (`None`) is interpreted as a legitimate state (e.g., new position, `tax` hasn't run) and rendered as `=NA()` rather than assumed 0% — avoids silently overstating post-tax gains.
4. "the post-tax columns shall be labelled estimates" (plural) is read as applying to both `Net Unrealized` and `Est. Tax Rate`, since both carry estimated, not realized, information; I chose an `"(est.)"` header suffix as the labelling mechanism (spec doesn't specify format, so any visibly-distinct label satisfies it).
5. No special-casing for negative Unrealized P&L (a loss): the same multiplicative formula applies uniformly; the spec gives no separate rule for loss positions.
6. `unrealized_pnl_cell`/`est_tax_rate_cell` are plain A1 references on the same row, assuming sheets-view already lays out pre-tax P&L and tax rate in fixed columns before this formula is written — column layout itself is out of scope for this sketch.
7. This sketch covers row/formula construction only, not the full tab-writer or header-styling pipeline.