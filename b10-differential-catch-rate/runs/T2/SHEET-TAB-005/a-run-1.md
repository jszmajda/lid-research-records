```rust
// sheets-view crate — Tax · Reserve Summary band projection.
// Pure pass-through: no tax computation, only shaping tax::annual_report
// figures into sheet rows/cells.

use crate::money::Cents;
use tax::annual_report::{AnnualReportLine, Jurisdiction, TaxYear};

/// One row of the band, keyed by (Jurisdiction, TaxYear).
pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

/// Projects annual_report lines into band rows. Performs no arithmetic —
/// outstanding/shortfall are copied verbatim from the tax crate's figures,
/// never recomputed here.
pub fn build_reserve_summary_band(report: &[AnnualReportLine]) -> Vec<ReserveSummaryRow> {
    let mut rows: Vec<ReserveSummaryRow> = report
        .iter()
        .map(|l| ReserveSummaryRow {
            jurisdiction: l.jurisdiction.clone(),
            tax_year: l.tax_year,
            accrued: l.accrued,
            moved: l.moved,
            paid: l.paid,
            outstanding: l.outstanding,
            shortfall: l.shortfall,
        })
        .collect();

    // Deterministic sheet ordering for stable diffs across publishes.
    rows.sort_by(|a, b| a.jurisdiction.cmp(&b.jurisdiction).then(a.tax_year.cmp(&b.tax_year)));
    rows
}

/// Renders rows to the tab writer's generic cell grid for this band.
pub fn render_band(rows: &[ReserveSummaryRow]) -> Vec<Vec<CellValue>> {
    rows.iter()
        .map(|r| vec![
            CellValue::Text(r.jurisdiction.to_string()),
            CellValue::Text(r.tax_year.to_string()),
            CellValue::Cents(r.accrued),
            CellValue::Cents(r.moved),
            CellValue::Cents(r.paid),
            CellValue::Cents(r.outstanding),
            CellValue::Cents(r.shortfall),
        ])
        .collect()
}
```

Assumptions:
1. `tax::annual_report` yields one `AnnualReportLine` per `(Jurisdiction, TaxYear)`, already deduplicated/merged — sheets-view does not aggregate.
2. `Jurisdiction`: small `Clone + Ord + Display` type (code/enum); `TaxYear`: `Copy + Ord + Display` (e.g. `u16` newtype).
3. All five figures are already `Cents` (signed integer) upstream — sheets-view does no unit conversion or scaling.
4. "Consumed as pure values" interpreted strictly: no recomputation of `outstanding` from `accrued − moved − paid`, no derivation of `shortfall` — even if internally inconsistent in the source, values are copied as-is; sheets-view trusts the kernel/tax crate.
5. Keys absent from `annual_report`'s output produce no row — no synthesized zero-rows for missing `(Jurisdiction, TaxYear)` combinations; existence of a combo is the tax crate's decision.
6. Row order isn't specified by the EARS — chose jurisdiction-then-year ascending sort for reproducible sheet output.
7. `CellValue` (with `Text`/`Cents` variants) and the tab writer are assumed pre-existing sheets-view infrastructure; currency formatting of `Cents` is out of scope here.
8. No validation/error path specified for malformed figures (e.g. negative `accrued`) — pass-through; rejecting bad data, if wanted, belongs to `tax::annual_report`, not this projection.
9. "Band" taken as a row-block within an existing tab (not a separate sheet); `render_band` returns rows for the writer to place at that block's location.