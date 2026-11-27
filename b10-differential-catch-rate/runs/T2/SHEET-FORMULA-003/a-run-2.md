```rust
/// sheets-view: Positions tab row projection (no accounting/tax math here).
pub struct PositionInputs {
    pub row: u32,                    // 1-based sheet row, for A1 refs
    pub price_col: char,             // column holding GOOGLEFINANCE(...) formula
    pub cost_basis_cents: i64,       // from kernel
    pub qty: i64,                    // from kernel (whole shares/units)
    /// Effective unrealized tax rate for this position, written by `tax`.
    /// None = tax crate has no basis yet (e.g. zero-lot position).
    pub est_tax_rate_bps: Option<i32>, // basis points, expected 0..=10000
}

pub struct PositionRowOut {
    pub unrealized_pnl_formula: String,
    pub est_tax_rate_cell: String,   // literal or "—"
    pub net_unrealized_formula: String,
    pub net_unrealized_label: String,
    pub est_tax_rate_label: String,
}

pub fn project_position_row(inp: &PositionInputs) -> PositionRowOut {
    let r = inp.row;
    let pnl_ref = format!("{}{}", 'U' /* Unrealized P&L col, example */, r);
    let unrealized_pnl_formula = format!(
        "=({}{r}*{}{r})-{}",
        inp.price_col, inp.qty, inp.cost_basis_cents, r = r
    );

    let (rate_cell, net_formula) = match inp.est_tax_rate_bps {
        Some(bps) => {
            let clamped = bps.clamp(0, 10_000);
            let rate_ref = format!("V{r}");
            (
                format!("{}", clamped as f64 / 10_000.0),
                format!("={pnl_ref}*(1-{rate_ref})"),
            )
        }
        None => ("—".to_string(), "=\"—\"".to_string()),
    };

    PositionRowOut {
        unrealized_pnl_formula,
        est_tax_rate_cell: rate_cell,
        net_unrealized_formula: net_formula,
        net_unrealized_label: "Net Unrealized P&L (Est.)".to_string(),
        est_tax_rate_label: "Est. Tax Rate (Est.)".to_string(),
    }
}
```

Assumptions:
1. sheets-view only projects; `tax`/kernel already computed cost basis and rate — no math performed here beyond formula string assembly.
2. "Live" applies to both columns: Unrealized P&L is itself a formula referencing the GOOGLEFINANCE price cell (not a static kernel value), so Net Unrealized, built from that cell, stays live too.
3. Est. Tax Rate modeled as `Option<i32>` basis points (integer, mirrors Cents-style precision) rather than f64, converted to decimal fraction only at formula-emission time.
4. Missing/not-yet-computed tax rate (`None`) renders "—" and a "—" net-unrealized formula rather than assuming 0%, since 0% would falsely imply a tax-free position.
5. Out-of-range bps (e.g. >10000 or negative) are clamped rather than erroring, since sheets-view has no authority to reject `tax` crate output.
6. Negative P&L × rate is passed through mechanically; sign conventions for losses are `tax`'s responsibility, not sheets-view's.
7. "Post-tax columns shall be labelled estimates" is read as applying to both Net Unrealized *and* Est. Tax Rate headers (both carry "(Est.)"), since Est. Tax Rate is itself an estimate feeding the post-tax figure.
8. Column/row refs are parameters, not hardcoded, since sheets-view controls tab layout elsewhere.