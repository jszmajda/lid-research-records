```rust
// SHEET-TAB-004: Tax tab as two physically separate typed ranges.
mod tax_tab {
    use crate::sheets::{TypedRange, RangeKind, CellValue};

    /// One row per accrual event; fields are kernel-computed, view-only here.
    #[derive(Clone)]
    pub struct AccrualRow {
        pub jurisdiction: String,
        pub tax_year: u16,
        pub accrual_date: String, // ISO-8601
        pub description: String,
        pub amount_cents: i64,
    }

    /// One row per (Jurisdiction, Tax Year); pre-aggregated upstream by the kernel.
    #[derive(Clone)]
    pub struct ReserveSummaryRow {
        pub jurisdiction: String,
        pub tax_year: u16,
        pub reserved_cents: i64,
    }

    pub struct TaxTabInput {
        pub accruals: Vec<AccrualRow>,
        pub reserve_summary: Vec<ReserveSummaryRow>,
    }

    const GAP_ROWS: usize = 2;

    /// Emits two non-overlapping typed ranges with a blank-row gap between
    /// them, so the reserve summary can never render as an in-band row.
    pub fn publish_tax_tab(input: &TaxTabInput) -> Vec<TypedRange> {
        let accrual_rows: Vec<Vec<CellValue>> = input.accruals.iter().map(|a| vec![
            CellValue::Text(a.jurisdiction.clone()),
            CellValue::Number(a.tax_year as f64),
            CellValue::Text(a.accrual_date.clone()),
            CellValue::Text(a.description.clone()),
            CellValue::Integer(a.amount_cents),
        ]).collect();
        let accrual_start = 1;
        let accrual_len = accrual_rows.len();

        let summary_rows: Vec<Vec<CellValue>> = input.reserve_summary.iter().map(|r| vec![
            CellValue::Text(r.jurisdiction.clone()),
            CellValue::Number(r.tax_year as f64),
            CellValue::Integer(r.reserved_cents),
        ]).collect();
        let summary_start = accrual_start + 1 + accrual_len + GAP_ROWS;

        vec![
            TypedRange {
                kind: RangeKind::TaxAccrualData,
                title: None,
                header: vec!["Jurisdiction","Tax Year","Date","Description","Amount (¢)"]
                    .into_iter().map(String::from).collect(),
                start_row: accrual_start,
                rows: accrual_rows,
            },
            TypedRange {
                kind: RangeKind::TaxReserveSummary,
                title: Some("Tax · Reserve Summary".into()),
                header: vec!["Jurisdiction","Tax Year","Reserved (¢)"]
                    .into_iter().map(String::from).collect(),
                start_row: summary_start,
                rows: summary_rows,
            },
        ]
    }
}
```

Assumptions:

1. `TypedRange`/`RangeKind`/`CellValue` are pre-existing sheets-view abstractions (not defined here) that the publisher already uses for other tabs; `RangeKind::TaxAccrualData` / `TaxReserveSummary` are new variants distinguishing the two bands.
2. "Physically separated" is interpreted as: two disjoint row ranges on the same tab with an explicit blank-row gap (`GAP_ROWS = 2`) between them — not, e.g., separate sheets/tabs or separate columns. Chose this over "different tab" because the spec calls both bands parts of "the Tax tab" (singular).
3. `ReserveSummaryRow` values arrive already aggregated (one row per `(Jurisdiction, Tax Year)`) from the kernel — sheets-view does not group/sum, per the "owns no accounting or tax math" constraint; grouping by tax key counts as accounting logic.
4. Empty `accruals` or `reserve_summary` vectors are valid: the function still emits both `TypedRange`s (possibly zero-row bodies) rather than omitting a band, preserving a stable two-band tab shape for downstream readers.
5. `tax_year` is modeled as `u16`; no explicit bounds/validity check is added since range validation is assumed to be a kernel-side invariant already enforced before this data reaches sheets-view.
6. Row ordering within each band (e.g., sort by jurisdiction/year) is left to the kernel's input order; sheets-view performs no reordering, only placement/formatting.
7. `amount_cents`/`reserved_cents` map to `CellValue::Integer` (raw Cents), not a formatted currency string, consistent with "Money is integer Cents" and the view owning no math/formatting decisions beyond typed placement.
8. The literal title `"Tax · Reserve Summary"` is attached only to the summary band (via `title: Some(...)`), with `title: None` on the accrual band, since the spec names only the summary band explicitly.