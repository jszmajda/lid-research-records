```rust
/// @spec SHEET-FORMULA-001
/// Builds one sheet row: live-price-dependent columns become GOOGLEFINANCE-
/// backed formula strings; all other columns are engine-computed literal values.

pub enum CellValue {
    Formula(String),
    Number(i64),      // Cents, or basis points for percentages
    Text(String),
}

pub struct Position {
    pub symbol: String,
    pub quantity: i64,        // whole shares * 10^scale, per ledger convention
    pub cost_basis_cents: i64,
    pub tax_rate_bps: i64,    // engine-supplied estimated rate, basis points
    pub price_row: u32,       // 1-based row this position occupies on the sheet
}

const PRICE_COL: &str = "B";
const QTY_COL: &str = "C";
const COST_BASIS_COL: &str = "D";
const TAX_RATE_COL: &str = "E"; // engine-written, not a formula target itself

pub fn render_row(p: &Position) -> Vec<(&'static str, CellValue)> {
    let r = p.price_row;
    let mv = format!("={PRICE_COL}{r}*{QTY_COL}{r}");
    let upnl = format!("=F{r}-{COST_BASIS_COL}{r}");
    let upct = format!("=IF({COST_BASIS_COL}{r}=0,\"\",G{r}/{COST_BASIS_COL}{r})");
    let est_tax = format!("=MAX(G{r},0)*{TAX_RATE_COL}{r}");
    let net_upnl = format!("=G{r}-I{r}");

    vec![
        ("symbol", CellValue::Text(p.symbol.clone())),
        ("price", CellValue::Formula(format!(
            "=GOOGLEFINANCE(\"{}\",\"price\")", p.symbol
        ))),
        ("quantity", CellValue::Number(p.quantity)),
        ("cost_basis", CellValue::Number(p.cost_basis_cents)),
        ("tax_rate_bps", CellValue::Number(p.tax_rate_bps)),
        ("market_value", CellValue::Formula(mv)),
        ("unrealized_pnl", CellValue::Formula(upnl)),
        ("unrealized_pct", CellValue::Formula(upct)),
        ("est_unrealized_tax", CellValue::Formula(est_tax)),
        ("net_unrealized", CellValue::Formula(net_upnl)),
    ]
}
```

Assumptions:
1. "Formula" means a literal Sheets formula string beginning with `=`, written via the sheets-view crate's cell-writer, not pre-computed by the kernel.
2. GOOGLEFINANCE's ticker argument is the ledger's `symbol` as-is; no exchange-prefix mapping/sanitization is specified, so none is added.
3. Downstream formula columns (market value, P&L, etc.) reference the price cell's sheet coordinates rather than re-embedding GOOGLEFINANCE calls — cheaper and avoids redundant live calls; EARS doesn't forbid this.
4. Division-by-zero (zero cost basis) in unrealized % is guarded with `IF(...=0,"")` since EARS is silent on that edge case; treated as reasonable defensive default, not accounting logic (the formula still lives entirely in-sheet).
5. Tax rate is engine-computed and written as a plain value; only the *result* (estimated unrealized tax) must be a live-price-dependent formula, since it depends on unrealized P&L, which depends on price.
6. "Net unrealized" = unrealized P&L minus estimated unrealized tax; no other definition is given.
7. Money type is `i64` cents per project convention; percentages/rates use basis points to stay integer, though the % *column itself* is a formula (ratio), not an engine value, so its cell type is a formula string, not Cents.
8. Column letters (B–J) are placeholder layout assumptions; real column assignment belongs to sheets-view's schema, not this requirement.
9. GOOGLEFINANCE failure/staleness (e.g., `#N/A` for a delisted symbol) is left to Sheets' native error propagation into dependent formulas — no engine-side fallback value is invented, since EARS doesn't specify one and injecting a synthetic fallback would blur the formula/value boundary the spec draws.