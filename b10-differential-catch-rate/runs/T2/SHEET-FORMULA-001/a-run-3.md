```rust
/// Column order fixed; letters derived from index (A=0).
#[derive(Clone, Copy, PartialEq, Eq)]
enum Column {
    Ticker, Quantity, CostBasisCents,      // engine values
    Price, MarketValueCents,                // live-dependent
    UnrealizedPnlCents, UnrealizedPct,
    EstUnrealizedTaxCents, NetUnrealizedCents,
}
const ORDER: [Column; 9] = [
    Column::Ticker, Column::Quantity, Column::CostBasisCents,
    Column::Price, Column::MarketValueCents, Column::UnrealizedPnlCents,
    Column::UnrealizedPct, Column::EstUnrealizedTaxCents, Column::NetUnrealizedCents,
];

enum CellContent {
    Value(CellValue),
    Formula(String),
}
enum CellValue { Text(String), Cents(i64), Number(f64) }

struct LedgerRow {
    ticker: String,
    quantity: f64,
    cost_basis: i64, // Cents
    tax_rate: f64,   // engine-computed, used only as a formula literal operand
}

fn col_letter(c: Column) -> char {
    (b'A' + ORDER.iter().position(|x| *x == c).unwrap() as u8) as char
}

fn project_row(row: &LedgerRow, r: u32) -> Vec<(Column, CellContent)> {
    let (tick, qty, cb, price, mv, pnl) = (
        col_letter(Column::Ticker), col_letter(Column::Quantity),
        col_letter(Column::CostBasisCents), col_letter(Column::Price),
        col_letter(Column::MarketValueCents), col_letter(Column::UnrealizedPnlCents),
    );
    vec![
        (Column::Ticker, CellContent::Value(CellValue::Text(row.ticker.clone()))),
        (Column::Quantity, CellContent::Value(CellValue::Number(row.quantity))),
        (Column::CostBasisCents, CellContent::Value(CellValue::Cents(row.cost_basis))),
        (Column::Price, CellContent::Formula(
            format!("=IFERROR(GOOGLEFINANCE({tick}{r},\"price\")*100,\"\")"))),
        (Column::MarketValueCents, CellContent::Formula(
            format!("={price}{r}*{qty}{r}"))),
        (Column::UnrealizedPnlCents, CellContent::Formula(
            format!("={mv}{r}-{cb}{r}"))),
        (Column::UnrealizedPct, CellContent::Formula(
            format!("=IFERROR({pnl}{r}/{cb}{r},\"\")"))),
        (Column::EstUnrealizedTaxCents, CellContent::Formula(
            format!("=MAX({pnl}{r},0)*{}", row.tax_rate))),
        (Column::NetUnrealizedCents, CellContent::Formula(
            format!("={pnl}{r}-{}{r}", col_letter(Column::EstUnrealizedTaxCents)))),
    ]
}
```

Assumptions:
1. Column layout is fixed/known at build time, so formulas can reference sibling cells by A1 address — required since formulas must chain (price→market value→P&L→tax→net).
2. `Cents` is `i64`; price formula multiplies GOOGLEFINANCE's dollar output by 100 to stay in the same unit as engine-written cost basis (interpretation choice — EARS doesn't state unit handling inside formulas).
3. Ticker/quantity/cost-basis are ordinary engine-written values, not "live-price-dependent," per the requirement's own column list.
4. Tax rate is engine-computed but only its *value* is spliced as a formula literal (not tax logic itself), keeping tax math out of the formula and satisfying "sheets-view owns no ... tax math."
5. `IFERROR` wraps GOOGLEFINANCE and the %-P&L division defensively (invalid ticker, zero cost basis) — errors surface as blank rather than crashing the sheet; engine does not suppress or pre-validate.
6. No special-casing for closed/zero-quantity positions — formulas still write; #N/A/blank is acceptable degraded output, consistent with sheets-view being read-only projection, not a validator.
7. Row index `r` is caller-supplied (1-based sheet row), not computed here.