```rust
/// One Positions-tab row's cell formulas, assembled from kernel + tax
/// output. sheets-view does no accounting/tax math itself — it only
/// stitches cell references into Sheets formula strings so the live
/// GOOGLEFINANCE price keeps both P&L figures recalculating in-sheet.
pub struct PositionCells {
    pub price_cell: String,      // GOOGLEFINANCE cell, e.g. "B2" (dollars, f64)
    pub qty_cell: String,        // "C2" (shares, may be fractional)
    pub cost_basis_cell: String, // "D2" (Cents, i64)
}

pub struct TaxInput {
    /// Per-position effective unrealized tax rate, fraction in [0.0, 1.0],
    /// written by `tax`. `None` = tax hasn't produced a rate yet (e.g.
    /// zero-basis or newly opened position).
    pub est_tax_rate: Option<f64>,
}

pub struct PositionRowFormulas {
    pub unrealized_pnl: String,  // Cents-valued formula
    pub est_tax_rate: String,    // literal value or "N/A"
    pub net_unrealized: String,  // formula or "N/A"
}

pub const HEADERS: [&str; 3] = [
    "Unrealized P&L",
    "Est. Tax Rate (estimate)",
    "Net Unrealized (estimate)",
];

pub fn build_position_formulas(c: &PositionCells, tax: &TaxInput) -> PositionRowFormulas {
    let pnl_expr = format!("({}*100*{})-{}", c.price_cell, c.qty_cell, c.cost_basis_cell);
    let unrealized_pnl = format!("={pnl_expr}");
    match tax.est_tax_rate {
        Some(r) => PositionRowFormulas {
            unrealized_pnl: unrealized_pnl.clone(),
            est_tax_rate: format!("={r}"),
            net_unrealized: format!("=({pnl_expr})*(1-{r})"),
        },
        None => PositionRowFormulas { unrealized_pnl, est_tax_rate: "N/A".into(), net_unrealized: "N/A".into() },
    }
}
```

Assumptions:
1. "Live" means Sheets-recalculated formulas referencing the GOOGLEFINANCE price cell, not Rust-precomputed values — consistent with GOOGLEFINANCE being the live-price oracle and sheets-view owning no accounting math.
2. Both `Unrealized P&L` and `Net Unrealized` are emitted as formula strings; `Est. Tax Rate` is a plain value cell written upstream by `tax` and merely referenced, never recomputed here.
3. `Est. Tax Rate` type: `f64` fraction in `[0.0, 1.0]`, not a percentage; sheets-view trusts the kernel/tax invariant and does not validate or clamp it (no accounting/tax math in this crate).
4. GOOGLEFINANCE price is in dollars; formula multiplies by 100 to reach Cents, matching Money's integer-Cents representation.
5. Missing tax rate (`None`) — interpreted as "not yet computed," not zero — renders both post-tax cells as literal `"N/A"` rather than a misleading `0` or a formula that would show `$0.00`.
6. "Post-tax columns" (plural) is read as both `Est. Tax Rate` and `Net Unrealized`, so both headers carry the "(estimate)" label; `Unrealized P&L` stays unlabelled as the pre-tax figure.
7. Cell/column layout (which letter holds price/qty/cost-basis) is caller-supplied via `PositionCells`; no fixed column scheme is assumed beyond per-row addressing.
8. Number formatting (currency, percent, bold) is out of scope for this function — it returns formula/label strings only, formatting applied elsewhere in sheets-view.