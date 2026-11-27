```rust
/// Sheet cell: either an engine-written literal or a live formula string.
pub enum CellValue { Num(f64), Text(String), Empty }
pub enum Cell { Value(CellValue), Formula(String) }

pub struct Position {
    pub symbol: String,
    pub qty: i64,
    pub cost_basis_cents: i64,
    pub realized_pnl_cents: i64,
    pub row: u32, // 1-based sheet row for cell refs
}

// Fixed column layout for this tab.
const COL_QTY: &str = "B";
const COL_PRICE: &str = "C";
const COL_COST: &str = "D";
const COL_MV: &str = "E";
const COL_PNL: &str = "F";
const COL_TAXRATE: &str = "H"; // engine-written rate, referenced by formula

pub fn render_row(p: &Position) -> Vec<(&'static str, Cell)> {
    let r = p.row;
    let (qty, cost, price, mv, pnl) = (
        format!("{COL_QTY}{r}"), format!("{COL_COST}{r}"),
        format!("{COL_PRICE}{r}"), format!("{COL_MV}{r}"), format!("{COL_PNL}{r}"),
    );
    vec![
        ("symbol", Cell::Value(CellValue::Text(p.symbol.clone()))),
        ("quantity", Cell::Value(CellValue::Num(p.qty as f64))),
        ("cost_basis", Cell::Value(CellValue::Num(p.cost_basis_cents as f64 / 100.0))),
        ("realized_pnl", Cell::Value(CellValue::Num(p.realized_pnl_cents as f64 / 100.0))),
        ("price", if p.symbol.trim().is_empty() {
            Cell::Value(CellValue::Empty)
        } else {
            Cell::Formula(format!("=GOOGLEFINANCE(\"{}\")", p.symbol))
        }),
        ("market_value", Cell::Formula(format!("={price}*{qty}"))),
        ("unrealized_pnl", Cell::Formula(format!("={mv}-{cost}"))),
        ("unrealized_pct", Cell::Formula(format!("=IF({cost}=0,\"\",{pnl}/{cost})"))),
        ("est_unrealized_tax", Cell::Formula(format!("={pnl}*{COL_TAXRATE}{r}"))),
        ("net_unrealized", Cell::Formula(format!("={pnl}-({pnl}*{COL_TAXRATE}{r})"))),
    ]
}
```

Assumptions:
1. `Cell` enum (Value vs Formula) is the mechanism satisfying "as formulas" vs "as values"; sheets-view writes `Value` variants literally and `Formula` variants as formula strings, matching its role of projection-only (no math performed in Rust for these six columns).
2. The six named columns are exactly: price, market_value, unrealized_pnl, unrealized_pct, est_unrealized_tax, net_unrealized — all Formula. Everything else (symbol, quantity, cost_basis, realized_pnl) is Value, per "all other columns."
3. Cents→dollars conversion for Value cells happens engine-side via `f64` division by 100; sheet-native numeric type is assumed acceptable for display (EARS doesn't specify Sheets NUMBER vs currency formatting).
4. Formulas reference sibling cells (price cell, qty cell, cost cell) rather than re-embedding `GOOGLEFINANCE` per formula — chosen interpretation to keep one live-price fetch per row and let dependent formulas chain, since EARS doesn't specify formula composition, only that these columns must *be* formulas.
5. Tax rate (`COL_TAXRATE`) is treated as an engine-written value column feeding into the tax/net-unrealized formulas; it is not itself live-price-dependent, so it stays a Value elsewhere, but est_unrealized_tax/net_unrealized still qualify as formulas since they depend on price transitively.
6. Empty/blank symbol: price cell falls back to `CellValue::Empty` rather than a formula (avoids a guaranteed `#N/A` from `GOOGLEFINANCE("")`); downstream formulas (market_value etc.) still reference the empty cell and will show blank/zero/error naturally — no special-casing propagated further, since EARS doesn't define invalid-symbol behavior.
7. Zero cost basis: guarded with `IF(cost=0,"",...)` in unrealized_pct only, to avoid div-by-zero; treated as the sole numeric edge case implied by "formula" semantics.
8. Row/column addressing (`row: u32`, fixed letter constants) assumes a stable, pre-allocated tab layout owned by sheets-view, consistent with "projects kernel output to tabs."