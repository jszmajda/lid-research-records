```rust
// sheets-view crate: pure projection of kernel tax output onto the Tax tab.
// No accounting/tax math lives here — only literal-value rendering.

pub type Cents = i64;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TaxTerm { ShortTerm, LongTerm }

/// One kernel-computed tax-lot layer ("stacked" = one row per lot, grouped
/// by symbol, not netted into a single per-symbol figure).
#[derive(Clone, Debug)]
pub struct TaxLotFigure {
    pub symbol: String,
    pub term: TaxTerm,
    pub cost_basis_cents: Cents,
    pub proceeds_cents: Cents,
    pub gain_cents: Cents, // kernel-computed: proceeds - cost_basis
}

/// Kernel output as of its last settle/sync pass — never a live quote.
pub struct TaxSnapshot {
    pub as_of: chrono::DateTime<chrono::Utc>,
    pub lots: Vec<TaxLotFigure>,
}

pub enum CellValue { Text(String), Number(f64) }
pub struct SheetRow { pub cells: Vec<CellValue> }

/// Projects a TaxSnapshot into Tax-tab rows. Every cell is a literal value —
/// never a GOOGLEFINANCE or other formula — so the tab reads as
/// kernel-exact-as-of-sync, distinct from Positions' live formula column.
pub fn project_tax_tab(snapshot: &TaxSnapshot) -> Vec<SheetRow> {
    let mut rows = vec![header_row(snapshot.as_of)];
    if snapshot.lots.is_empty() {
        rows.push(text_row("No tax lots as of last sync"));
        return rows;
    }
    for lot in &snapshot.lots {
        rows.push(SheetRow { cells: vec![
            CellValue::Text(lot.symbol.clone()),
            CellValue::Text(format!("{:?}", lot.term)),
            CellValue::Number(cents_to_dollars(lot.cost_basis_cents)),
            CellValue::Number(cents_to_dollars(lot.proceeds_cents)),
            CellValue::Number(cents_to_dollars(lot.gain_cents)),
        ]});
    }
    rows
}

fn header_row(as_of: chrono::DateTime<chrono::Utc>) -> SheetRow {
    text_row(&format!("Tax — kernel-exact, as of {}", as_of.to_rfc3339()))
}
fn text_row(s: &str) -> SheetRow { SheetRow { cells: vec![CellValue::Text(s.to_string())] } }
fn cents_to_dollars(c: Cents) -> f64 { c as f64 / 100.0 }
```

ASSUMPTIONS (invented, not in the EARS text):
1. `Cents = i64`; conversion to dollars (`/100.0`) happens only at the render boundary, per "Money is integer Cents" from context.
2. "Kernel-exact" interpreted as: every Tax-tab cell is a literal value computed upstream by the kernel — this crate never embeds a formula (contrast with Positions' `GOOGLEFINANCE` column).
3. "Stacked" interpreted as one row per tax lot (grouped by symbol), not a single netted per-symbol total — since no other stacking axis (e.g., short/long-term buckets) was specified.
4. "As-of-last-sync" implemented as a `DateTime<Utc>` on the kernel snapshot, surfaced verbatim in the tab header — distinguishing it from Positions' implicitly "live" (formula-refreshed) values. No staleness threshold/alert was specified, so none is added.
5. Empty-lots edge case: emit a header plus a single placeholder text row rather than an empty tab, so "distinct from Positions" remains visibly true even with no data.
6. `TaxTerm` (short/long-term) invented as a plausible tax dimension since the EARS says "tax-adjusted figures" without naming fields; no wash-sale, carryforward, or other tax-specific logic is assumed since sheets-view owns no tax math.
7. No error/Result type: kernel snapshot is assumed pre-validated; malformed kernel input is out of scope for this projection layer.