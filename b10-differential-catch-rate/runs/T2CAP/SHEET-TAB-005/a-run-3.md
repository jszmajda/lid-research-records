```rust
//! sheets-view: Tax · Reserve Summary band (SHEET-TAB-005)
//! Pure projection. No tax math lives here.

use std::collections::BTreeMap;

/// Re-exported kernel types (owned by `tax`), not redefined here.
use tax::{AnnualReport, Cents, Jurisdiction, TaxYear};

/// One rendered row of the band, in stable (Jurisdiction, TaxYear) order.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

/// Fixed header, in the requirement's stated figure order.
pub const RESERVE_SUMMARY_HEADERS: [&str; 7] = [
    "Jurisdiction", "Tax Year", "Accrued", "Moved", "Paid", "Outstanding", "Shortfall",
];

/// Projects `tax::annual_report` output into the band's rows.
/// Figures are consumed as pure values: copied, never recomputed,
/// never cross-checked (e.g. no `accrued - moved` derivation of outstanding).
pub fn reserve_summary_rows(
    reports: &BTreeMap<(Jurisdiction, TaxYear), AnnualReport>,
) -> Vec<ReserveSummaryRow> {
    reports
        .iter()
        .map(|((jurisdiction, tax_year), r)| ReserveSummaryRow {
            jurisdiction: jurisdiction.clone(),
            tax_year: *tax_year,
            accrued: r.accrued,
            moved: r.moved,
            paid: r.paid,
            outstanding: r.outstanding,
            shortfall: r.shortfall,
        })
        .collect()
}

/// Band render: header + one row per key. Empty input yields header only.
pub fn render_reserve_summary_band(
    reports: &BTreeMap<(Jurisdiction, TaxYear), AnnualReport>,
) -> Vec<Vec<CellValue>> {
    let mut grid = vec![RESERVE_SUMMARY_HEADERS.iter().map(|h| CellValue::Text(h.to_string())).collect()];
    for row in reserve_summary_rows(reports) {
        grid.push(vec![
            CellValue::Text(row.jurisdiction.to_string()),
            CellValue::Text(row.tax_year.to_string()),
            CellValue::Money(row.accrued),
            CellValue::Money(row.moved),
            CellValue::Money(row.paid),
            CellValue::Money(row.outstanding),
            CellValue::Money(row.shortfall),
        ]);
    }
    grid
}
```

ASSUMPTIONS (all invented):
1. `tax::annual_report` is queried per `(Jurisdiction, TaxYear)`; I model its aggregate output as a `BTreeMap` keyed by that pair — one report per key, so one band row per key.
2. `AnnualReport` exposes the five figures as public `Cents` fields with exactly those names.
3. `Cents` is an integer newtype (`i64`-backed); signed, so negative outstanding/shortfall pass through unaltered rather than being clamped to zero — clamping would be tax math.
4. `Jurisdiction: Ord + Clone + Display`; `TaxYear: Ord + Copy + Display`. `BTreeMap` gives deterministic ordering (jurisdiction, then year ascending) — the EARS states no order, and stable output matters for idempotent sheet writes.
5. A `CellValue` enum exists in sheets-view with `Text`/`Money` variants; Cents→display formatting is the serializer's job, not this module's.
6. Missing/absent key = row omitted entirely (no zero-filled placeholder row), since the band is "per (Jurisdiction, Tax Year)" of what the report yields.
7. No summing across jurisdictions or years, no totals row — a totals row would require arithmetic this crate is forbidden to own.
8. Read-only projection: no fallbacks, no defaults for missing figures; if the kernel type has the field, it has a value. Any absence would be a kernel-side type error, not handled here.

AMBIGUITY / INTERPRETATION: "populate the band" could mean writing cells directly to the Sheets API or producing values for a writer. I chose the latter — a pure `Vec<Vec<CellValue>>` grid handed to the existing tab writer — because a pure-value projection is testable and matches "consumes pure values, holds no math." I also read "shortfall" as a distinct reported figure, not `outstanding` minus reserve balance; deriving it would be the tax math the requirement forbids.