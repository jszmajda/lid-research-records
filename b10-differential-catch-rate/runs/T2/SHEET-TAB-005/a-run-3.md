```rust
// sheets-view/src/tabs/tax_reserve_summary.rs
//
// @spec SHEET-TAB-005
//! Projects `tax::annual_report` figures into the `Tax · Reserve Summary`
//! band, one row per (Jurisdiction, Tax Year). No tax math performed here.

use crate::cents::Cents;
use tax::annual_report::{AnnualReport, Jurisdiction, TaxYear};

/// One rendered row of the band. Pure display data.
pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

/// Builds the band's rows directly from `annual_report` figures, one row
/// per (Jurisdiction, Tax Year) key present in the report. No computation,
/// derivation, or reconciliation is performed — every field is copied
/// verbatim from the kernel's output.
pub fn build_reserve_summary_band(report: &AnnualReport) -> Vec<ReserveSummaryRow> {
    report
        .entries() // assumed: &[(Jurisdiction, TaxYear, Figures)] or equivalent iterator
        .map(|entry| ReserveSummaryRow {
            jurisdiction: entry.jurisdiction.clone(),
            tax_year: entry.tax_year,
            accrued: entry.figures.accrued,
            moved: entry.figures.moved,
            paid: entry.figures.paid,
            outstanding: entry.figures.outstanding,
            shortfall: entry.figures.shortfall,
        })
        .collect()
}

/// Row ordering for the band: by Jurisdiction, then Tax Year ascending.
/// Sorting is a presentation concern (view ordering), not tax math.
pub fn sorted_rows(mut rows: Vec<ReserveSummaryRow>) -> Vec<ReserveSummaryRow> {
    rows.sort_by(|a, b| {
        a.jurisdiction
            .cmp(&b.jurisdiction)
            .then(a.tax_year.cmp(&b.tax_year))
    });
    rows
}
```

Assumptions (all invented, none confirmed against source):

1. `tax::annual_report::AnnualReport` exposes an iterable collection keyed by `(Jurisdiction, TaxYear)`, accessed via an `entries()` method; exact API name unknown.
2. `Figures` struct groups the five named quantities (`accrued`, `moved`, `paid`, `outstanding`, `shortfall`) as `Cents`; field names assumed to match EARS wording exactly.
3. `Jurisdiction` implements `Clone + Ord`; `TaxYear` is `Copy + Ord` (e.g., a newtype around `u16`).
4. No filtering: every `(Jurisdiction, TaxYear)` pair the report contains is rendered — no "current year only" or "nonzero only" default, since the EARS states no filter condition.
5. Missing/absent report entries produce zero rows (empty band), not an error — treated as "nothing to reserve," consistent with "consumed as pure values."
6. No validation that `outstanding == accrued − moved − paid` or `shortfall` consistency — that's tax math, explicitly out of scope per "holding no tax math of its own."
7. Sort order (Jurisdiction, then Tax Year) is a display-only assumption; EARS doesn't specify ordering.
8. Negative or zero `Cents` values pass through unmodified — no clamping, since sign meaning (e.g., a credit) is tax semantics this crate doesn't own.
9. Sheet-write mechanics (cell ranges, formatting) are out of this sketch's scope — only the row-projection step is shown, per "projects kernel output to tabs."