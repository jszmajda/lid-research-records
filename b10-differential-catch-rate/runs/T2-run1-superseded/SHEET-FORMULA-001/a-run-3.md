```rust
/// Columns rendered on a position-row tab.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
enum ColumnId {
    Symbol, Quantity, CostBasis,
    Price, MarketValue, UnrealizedPnl, UnrealizedPct,
    EstUnrealizedTax, NetUnrealized,
}

/// Exactly the six live-price-dependent columns named in SHEET-FORMULA-001.
fn is_formula_column(col: ColumnId) -> bool {
    matches!(col,
        ColumnId::Price | ColumnId::MarketValue | ColumnId::UnrealizedPnl
        | ColumnId::UnrealizedPct | ColumnId::EstUnrealizedTax | ColumnId::NetUnrealized)
}

enum CellContent { Formula(String), Value(CellValue) }
enum CellValue { Text(String), Number(f64), Integer(i64) }

/// Engine output for one position row. `tax_rate` is engine-computed
/// (sheets-view owns no tax math) and written as a plain value the
/// formula cells reference, not embedded as a literal.
struct PositionRow {
    row_num: u32,          // actual sheet row (post-header)
    symbol: String,
    quantity: i64,
    cost_basis_cents: i64,
    tax_rate: f64,
}

/// price_col/qty_col/basis_col/rate_col: column letters for same-row refs.
fn build_row(row: &PositionRow, price_col: &str, qty_col: &str,
             basis_col: &str, rate_col: &str) -> Vec<(ColumnId, CellContent)> {
    let r = row.row_num;
    let mv = format!("{qty_col}{r}*{price_col}{r}");
    let pnl = format!("({mv}-{basis_col}{r})");
    vec![
        (ColumnId::Symbol, CellContent::Value(CellValue::Text(row.symbol.clone()))),
        (ColumnId::Quantity, CellContent::Value(CellValue::Integer(row.quantity))),
        (ColumnId::CostBasis, CellContent::Value(CellValue::Number(row.cost_basis_cents as f64 / 100.0))),
        (ColumnId::Price, CellContent::Formula(format!("=GOOGLEFINANCE(\"{}\")", row.symbol))),
        (ColumnId::MarketValue, CellContent::Formula(format!("={mv}"))),
        (ColumnId::UnrealizedPnl, CellContent::Formula(format!("={pnl}"))),
        (ColumnId::UnrealizedPct, CellContent::Formula(
            format!("=IFERROR({pnl}/{basis_col}{r},0)"))),
        (ColumnId::EstUnrealizedTax, CellContent::Formula(
            format!("=MAX(0,{pnl})*{rate_col}{r}"))),
        (ColumnId::NetUnrealized, CellContent::Formula(
            format!("={pnl}-MAX(0,{pnl})*{rate_col}{r}"))),
    ]
}
```

Assumptions:
1. "Live-price-dependent columns" = exactly the six named in the EARS text; every other column (Symbol, Quantity, CostBasis, etc.) is engine-value regardless of tab.
2. Formula cells compose via same-row A1 references (chained formulas) rather than each re-deriving GOOGLEFINANCE independently, so the sheet recalculates as one dependency graph on price refresh.
3. Tax math conflict resolved by having the engine compute `tax_rate` (a value) and write it to its own engine-value column; the tax/net-unrealized formulas reference that rate cell rather than embedding tax logic in the formula string — keeps sheets-view free of accounting/tax math while still satisfying "formula" for the live-price-dependent output.
4. Cents converted to `f64` dollars at the value-cell boundary (display-only conversion, not an accounting operation).
5. Division-by-zero (fully divested, cost basis 0) wrapped in `IFERROR(...,0)` for `UnrealizedPct` since EARS is silent on error rendering and a published read-only view showing raw `#DIV/0!` was judged worse than a defined fallback.
6. `row_num` assumed pre-offset for header row(s); column letters passed in rather than computed, since sheet layout ownership is out of scope here.
7. Not handled (explicit gap, not addressed by this spec): GOOGLEFINANCE returning `#N/A` for delisted/invalid tickers, and formula-injection sanitization of `symbol` — assumed handled upstream/elsewhere.