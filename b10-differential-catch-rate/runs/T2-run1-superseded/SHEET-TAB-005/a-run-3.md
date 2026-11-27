```rust
// crate: sheets-view
// Populates "Tax · Reserve Summary" per (Jurisdiction, Tax Year).
// No tax math: every figure is a direct pass-through of tax::annual_report.

use kernel::money::Cents;
use tax::annual_report::{AnnualReportRow, Jurisdiction, TaxYear};

pub const RESERVE_SUMMARY_BAND: &str = "Tax · Reserve Summary";

pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

/// Projects annual_report rows 1:1 into band rows, sorted by
/// (Jurisdiction, Tax Year) for stable sheet layout.
pub fn build_reserve_summary_rows(report: &[AnnualReportRow]) -> Vec<ReserveSummaryRow> {
    let mut rows: Vec<_> = report.iter().map(|r| ReserveSummaryRow {
        jurisdiction: r.jurisdiction.clone(),
        tax_year: r.tax_year,
        accrued: r.accrued,
        moved: r.moved,
        paid: r.paid,
        outstanding: r.outstanding,
        shortfall: r.shortfall,
    }).collect();
    rows.sort_by(|a, b| (&a.jurisdiction, a.tax_year).cmp(&(&b.jurisdiction, b.tax_year)));
    rows
}

pub fn publish_reserve_summary(
    writer: &mut impl SheetWriter,
    report: &[AnnualReportRow],
) -> Result<(), SheetsViewError> {
    writer.clear_band(RESERVE_SUMMARY_BAND)?;
    for row in build_reserve_summary_rows(report) {
        writer.append_row(RESERVE_SUMMARY_BAND, &[
            cell(&row.jurisdiction), cell(&row.tax_year),
            cell(&row.accrued), cell(&row.moved), cell(&row.paid),
            cell(&row.outstanding), cell(&row.shortfall),
        ])?;
    }
    Ok(())
}
```

Assumptions (invented, none given in the EARS):
1. `tax::annual_report` exposes a slice/`Vec<AnnualReportRow>` with fields named `jurisdiction`, `tax_year`, `accrued`, `moved`, `paid`, `outstanding`, `shortfall` — the exact API shape wasn't specified.
2. `Jurisdiction` and `TaxYear` are `Clone + Ord` value types; `Cents` is the workspace's shared integer-cents money type.
3. Uniqueness per `(Jurisdiction, Tax Year)` is guaranteed upstream by `tax::annual_report`; sheets-view does not dedupe or aggregate duplicates (would be math) — it only sorts for stable output.
4. Empty/missing combinations: if `tax::annual_report` omits a `(Jurisdiction, Tax Year)`, no row is emitted — sheets-view never zero-fills or infers defaults, since synthesizing a value would itself be tax math.
5. Ordering ambiguity: "per (Jurisdiction, Tax Year)" is read as the row-grouping key, not a mandated sort order; I chose lexicographic (Jurisdiction, then Tax Year) sort for deterministic sheet layout, an assumption beyond the spec text.
6. Column order follows the requirement's listed order: accrued, moved, paid, outstanding, shortfall.
7. Failure handling: if the upstream report call/data is invalid, the function propagates `SheetsViewError` rather than substituting a fallback value — silently coercing bad input would risk manufacturing figures.
8. `SheetWriter`/`cell()`/`SheetsViewError` are assumed pre-existing crate abstractions for tab I/O and value formatting, not GOOGLEFINANCE-formula cells (this band is static values, per "consumed as pure values").