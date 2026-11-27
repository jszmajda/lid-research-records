```rust
// crate: sheets-view — projects tax::annual_report figures into the
// "Tax · Reserve Summary" band. Holds no tax math: every value is
// consumed verbatim from the kernel and only reshaped/sorted for display.

use tax::annual_report::{AnnualReportRow, Jurisdiction, TaxYear};
use crate::money::Cents;

/// One row of the `Tax · Reserve Summary` band, keyed by (Jurisdiction, Tax Year).
pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

/// Pure projection: `tax::annual_report` rows -> band rows, sorted for
/// stable sheet layout. No computation, filtering, or validation of the
/// figures themselves.
pub fn build_reserve_summary_band(
    reports: &[AnnualReportRow],
) -> Vec<ReserveSummaryRow> {
    let mut rows: Vec<ReserveSummaryRow> = reports
        .iter()
        .map(|r| ReserveSummaryRow {
            jurisdiction: r.jurisdiction.clone(),
            tax_year: r.tax_year,
            accrued: r.accrued,
            moved: r.moved,
            paid: r.paid,
            outstanding: r.outstanding,
            shortfall: r.shortfall,
        })
        .collect();

    rows.sort_by(|a, b| {
        (&a.jurisdiction, a.tax_year).cmp(&(&b.jurisdiction, b.tax_year))
    });
    rows
}
```

Assumptions invented:
1. `tax::annual_report` exposes one `AnnualReportRow` per `(Jurisdiction, Tax Year)` already, so no grouping/aggregation is needed here — the view only reshapes and orders.
2. All five figures (accrued, moved, paid, outstanding, shortfall) are `Cents` per project-wide integer-money convention; no float/currency conversion.
3. `Jurisdiction` is `Clone + Ord`-ish (e.g. an enum or interned string newtype) and `TaxYear` is a small `Copy` integer type, enabling the sort-by-tuple key.
4. Output ordering is `(Jurisdiction, Tax Year)` ascending — chosen because the requirement states the key in that order and sheet bands need deterministic row order; not specified explicitly, so this is my interpretation.
5. No suppression of zero, negative, or "unexpected" shortfall/outstanding values — since this crate "owns no accounting or tax math," it must not apply business judgment like hiding non-positive shortfalls.
6. Duplicate or missing `(Jurisdiction, Tax Year)` pairs in the source are passed through as-is (possible duplicate rows in output); dedup/validation is treated as `tax::annual_report`'s responsibility, not the view's.
7. Full band replace on each publish (matches read-only, oracle-plus-settle publishing model elsewhere in the system) rather than incremental diff/update — no prior-state comparison performed.
8. Function is infallible: given a well-formed slice from the kernel, no `Result`/error path is modeled, since the spec describes pure value consumption with no validation duty.