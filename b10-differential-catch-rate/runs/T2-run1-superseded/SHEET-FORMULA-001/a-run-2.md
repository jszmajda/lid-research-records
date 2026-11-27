```rust
/// A single sheet cell: either an engine-computed value (written as-is)
/// or a live formula string (evaluated by Sheets).
#[derive(Debug, Clone)]
pub enum Cell {
    Value(CellValue),
    Formula(String),
}

#[derive(Debug, Clone)]
pub enum CellValue {
    Text(String),
    Cents(i64),
    Empty,
}

/// 1-based column letters for a holdings row. Engine-written inputs
/// (symbol, quantity, cost_basis, tax_rate_bps) already occupy A–D;
/// this fn only emits the six live-price-dependent formula cells.
pub struct HoldingsCols {
    pub symbol: char, pub quantity: char,
    pub cost_basis: char, pub tax_rate_bps: char,
    pub price: char, pub market_value: char,
    pub unrealized_pnl: char, pub unrealized_pct: char,
    pub est_unrealized_tax: char, pub net_unrealized: char,
}

pub fn formula_cells(c: &HoldingsCols, row: u32) -> [(char, Cell); 6] {
    let r = |col: char| format!("{col}{row}");
    let price = format!(r#"=GOOGLEFINANCE({},"price")"#, r(c.symbol));
    let mv    = format!("={}*{}", r(c.price), r(c.quantity));
    let pnl   = format!("={}-{}", r(c.market_value), r(c.cost_basis));
    let pct   = format!("=IFERROR({}/{},0)", r(c.unrealized_pnl), r(c.cost_basis));
    // tax math stays a spreadsheet formula string authored here, not
    // computed in Rust — sheets-view still owns no accounting/tax logic.
    let tax   = format!("=MAX({},0)*{}/10000", r(c.unrealized_pnl), r(c.tax_rate_bps));
    let net   = format!("={}-{}", r(c.unrealized_pnl), r(c.est_unrealized_tax));
    [(c.price, Cell::Formula(price)), (c.market_value, Cell::Formula(mv)),
     (c.unrealized_pnl, Cell::Formula(pnl)), (c.unrealized_pct, Cell::Formula(pct)),
     (c.est_unrealized_tax, Cell::Formula(tax)), (c.net_unrealized, Cell::Formula(net))]
}
```

Assumptions:
1. `Cell` enum with `Value`/`Formula` variants is the projection primitive; non-listed columns (symbol, quantity, cost basis) are always `Cell::Value`.
2. Row layout is fixed, 1-based, columns known at build time via a `HoldingsCols` struct of column letters rather than dynamic lookup.
3. Formulas reference same-row cells by A1 notation (e.g. `E2`) rather than embedding literal numbers, so Sheets recalculates on row insert/delete.
4. `GOOGLEFINANCE(symbol,"price")` is the price oracle exactly as named in the prompt; no fallback formula (e.g. `IFERROR`) wraps it, so an invalid symbol surfaces Sheets' native `#N/A` — chosen because the spec doesn't mention error handling for price itself, only downstream columns.
5. `unrealized_pct` guards divide-by-zero (`cost_basis == 0`) via `IFERROR(...,0)`, an invented boundary behavior since EARS is silent on zero-cost-basis lots.
6. Tax rate is engine-written (`tax_rate_bps`, basis points) and only referenced by the formula, not computed by Rust — preserving "owns no accounting or tax math."
7. Estimated unrealized tax applies only to gains (`MAX(pnl,0)`), not losses — an invented policy choice, since EARS doesn't specify loss treatment.
8. `net_unrealized = pnl - tax` (post-tax unrealized gain), the natural reading of "net."
9. Sheet formula math is in sheet-native decimal (dollars), diverging from the kernel's integer-Cents domain; this boundary crossing is intentional and undocumented elsewhere in the given EARS.
10. No currency/locale formatting logic included — out of scope for "as formulas vs. values."