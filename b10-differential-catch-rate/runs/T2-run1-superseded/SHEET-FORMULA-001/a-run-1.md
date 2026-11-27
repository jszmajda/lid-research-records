```rust
/// EARS SHEET-FORMULA-001
/// Fixed left-to-right layout; enum order == sheet column letters (A, B, C...).
#[derive(Clone, Copy, PartialEq, Eq)]
pub enum Column {
    Symbol, Quantity, CostBasisCents,          // engine-written
    Price, MarketValueCents, UnrealizedPnlCents,
    UnrealizedPct, EstUnrealizedTaxCents, NetUnrealizedCents, // formulas
}

const ORDER: [Column; 9] = [
    Column::Symbol, Column::Quantity, Column::CostBasisCents,
    Column::Price, Column::MarketValueCents, Column::UnrealizedPnlCents,
    Column::UnrealizedPct, Column::EstUnrealizedTaxCents, Column::NetUnrealizedCents,
];

impl Column {
    fn is_live_price_dependent(self) -> bool {
        matches!(self, Column::Price | Column::MarketValueCents | Column::UnrealizedPnlCents
            | Column::UnrealizedPct | Column::EstUnrealizedTaxCents | Column::NetUnrealizedCents)
    }
    fn letter(self) -> char {
        (b'A' + ORDER.iter().position(|c| *c == self).unwrap() as u8) as char
    }
}

pub enum CellContent { Value(EngineValue), Formula(String) }
pub enum EngineValue { Text(String), Cents(i64) }

pub struct HoldingRow { pub symbol: String, pub quantity: i64, pub cost_basis_cents: i64, pub tax_rate_bp: i64 }

pub fn render_row(row: &HoldingRow, sheet_row: u32) -> Vec<(Column, CellContent)> {
    use Column::*;
    let r = |c: Column| format!("{}{sheet_row}", c.letter());
    let q = format!("\"{}\"", row.symbol.replace('"', "\"\""));
    vec![
        (Symbol, CellContent::Value(EngineValue::Text(row.symbol.clone()))),
        (Quantity, CellContent::Value(EngineValue::Cents(row.quantity))),
        (CostBasisCents, CellContent::Value(EngineValue::Cents(row.cost_basis_cents))),
        (Price, CellContent::Formula(format!("=GOOGLEFINANCE({q})"))),
        (MarketValueCents, CellContent::Formula(format!("=ROUND({}*{}*100)", r(Quantity), r(Price)))),
        (UnrealizedPnlCents, CellContent::Formula(format!("={}-{}", r(MarketValueCents), r(CostBasisCents)))),
        (UnrealizedPct, CellContent::Formula(format!("=IF({0}=0,0,{1}/{0})", r(CostBasisCents), r(UnrealizedPnlCents)))),
        (EstUnrealizedTaxCents, CellContent::Formula(format!("=ROUND(MAX(0,{})*{}/10000)", r(UnrealizedPnlCents), row.tax_rate_bp))),
        (NetUnrealizedCents, CellContent::Formula(format!("={}-{}", r(UnrealizedPnlCents), r(EstUnrealizedTaxCents)))),
    ]
}
```

Assumptions invented:
1. The six formula columns are exactly those named in the requirement text; every other column (symbol, quantity, cost basis, presumably lot/date fields not shown) is `EngineValue`.
2. Formulas reference sibling cells in the same row (A1 notation) rather than recomputing from scratch, so only `Price` touches `GOOGLEFINANCE`; downstream formulas chain off it — chosen because "live-price-dependent" implies derivation from one live input, not five independent oracle calls.
3. Column order fixes A1 letters; I invented an order (identity fields first, then the six) since the EARS doesn't specify sheet layout.
4. `tax_rate_bp` is an engine-supplied scalar baked into the formula as a literal, not itself a formula column (not named in the requirement).
5. `MarketValueCents` assumes `GOOGLEFINANCE` returns dollars (float) and multiplies by 100 to reach Cents; unvalidated unit assumption.
6. Divide-by-zero guarded only for `UnrealizedPct` (cost basis = 0 → 0); no handling for `GOOGLEFINANCE` returning `#N/A` (delisted/invalid ticker) — assumed to propagate natively per Sheets semantics, out of scope for this requirement.
7. No handling of negative/short quantities or missing symbols; ticker string is quote-escaped but not format-validated.
8. Formula argument separator assumed comma (US locale); semicolon-locale sheets unhandled.
9. Actual Sheets API batch-write/serialization is out of scope — function only classifies cell content per requirement.