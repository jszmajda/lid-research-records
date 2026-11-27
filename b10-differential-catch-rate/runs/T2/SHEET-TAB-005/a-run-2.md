```rust
// @spec SHEET-TAB-005
// Populates the `Tax · Reserve Summary` band, one row per (Jurisdiction, Tax Year),
// from tax::annual_report figures. sheets-view performs no tax computation —
// every field below is copied through unchanged.

use std::collections::BTreeMap;

pub type Cents = i64;
pub type Jurisdiction = String;
pub type TaxYear = u16;

/// Mirrors the per-key output shape of `tax::annual_report`.
pub struct AnnualReportFigures {
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

/// Projects annual_report figures into the Tax · Reserve Summary band.
/// One row per (Jurisdiction, Tax Year) key present in `report`; BTreeMap
/// ordering gives deterministic, stable row placement in the sheet.
pub fn build_reserve_summary_band(
    report: &BTreeMap<(Jurisdiction, TaxYear), AnnualReportFigures>,
) -> Vec<ReserveSummaryRow> {
    report
        .iter()
        .map(|((jurisdiction, tax_year), f)| ReserveSummaryRow {
            jurisdiction: jurisdiction.clone(),
            tax_year: *tax_year,
            accrued: f.accrued,
            moved: f.moved,
            paid: f.paid,
            outstanding: f.outstanding,
            shortfall: f.shortfall,
        })
        .collect()
}
```

Assumptions invented:

1. `tax::annual_report`'s figures are already keyed by `(Jurisdiction, TaxYear)`; modeled as `BTreeMap` so iteration order is deterministic (needed for stable sheet rows), though the real API may instead expose a query function or iterator — adapt the input type accordingly.
2. `Cents = i64` (allows negative shortfall/refund states); `Jurisdiction = String` (could be a closed enum in the real kernel); `TaxYear = u16`.
3. Interpreted "consumed as pure values, holding no tax math" strictly: no derived arithmetic (e.g., no recomputing `outstanding` from `accrued − moved − paid`) even where it'd be redundant — every field is a straight copy, so the tab can never silently disagree with the kernel.
4. A `(Jurisdiction, Tax Year)` combination absent from `annual_report`'s output produces no row at all (band reflects only what the kernel reports); it is not zero-filled or defaulted, since fabricating a zero row would itself be tax judgment.
5. No validation of figures (e.g., rejecting negative `paid` or `accrued < moved`) — sheets-view has no basis to judge correctness of upstream values; malformed input is a kernel-side bug, not this layer's concern.
6. Row ordering is sorted by `(Jurisdiction, Tax Year)` since the EARS is silent on band ordering and sheet rendering needs a defined order.
7. Exactly one row per key (no cross-year or cross-jurisdiction aggregation), reading "per (Jurisdiction, Tax Year)" as the row-grain, not a rollup dimension.