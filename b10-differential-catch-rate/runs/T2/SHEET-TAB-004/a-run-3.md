```rust
// sheets-view: tax tab projection (SHEET-TAB-004)
// Publishes two typed, physically separated ranges onto the "Tax" tab.

use std::collections::BTreeMap;

pub struct TaxAccrualRow {
    pub jurisdiction: String,
    pub tax_year: u32,
    pub accrual_id: String,
    pub accrued_cents: i64,
    pub accrual_date: String, // ISO date, already formatted by kernel
}

pub struct ReserveSummaryRow {
    pub jurisdiction: String,
    pub tax_year: u32,
    pub reserved_cents: i64,
}

pub struct TypedRange {
    pub label: &'static str,
    pub start_row: u32, // 1-indexed absolute sheet row
    pub headers: Vec<&'static str>,
    pub rows: Vec<Vec<CellValue>>,
}

pub enum CellValue {
    Text(String),
    Number(f64),
    Cents(i64),
}

const BAND_GAP_ROWS: u32 = 2;

pub fn publish_tax_tab(accruals: &[TaxAccrualRow]) -> [TypedRange; 2] {
    let accrual_rows: Vec<Vec<CellValue>> = accruals
        .iter()
        .map(|a| vec![
            CellValue::Text(a.jurisdiction.clone()),
            CellValue::Number(a.tax_year as f64),
            CellValue::Text(a.accrual_id.clone()),
            CellValue::Cents(a.accrued_cents),
            CellValue::Text(a.accrual_date.clone()),
        ])
        .collect();
    let accrual_band = TypedRange {
        label: "Tax · Accruals",
        start_row: 1,
        headers: vec!["Jurisdiction", "Tax Year", "Accrual ID", "Accrued", "Date"],
        rows: accrual_rows,
    };

    let mut totals: BTreeMap<(String, u32), i64> = BTreeMap::new();
    for a in accruals {
        *totals.entry((a.jurisdiction.clone(), a.tax_year)).or_insert(0) += a.accrued_cents;
    }
    let summary_rows: Vec<Vec<CellValue>> = totals
        .into_iter()
        .map(|((j, y), c)| vec![CellValue::Text(j), CellValue::Number(y as f64), CellValue::Cents(c)])
        .collect();

    let summary_start = accrual_band.start_row + 1 /*header*/ + accrual_band.rows.len() as u32 + BAND_GAP_ROWS;
    let summary_band = TypedRange {
        label: "Tax · Reserve Summary",
        start_row: summary_start,
        headers: vec!["Jurisdiction", "Tax Year", "Reserved"],
        rows: summary_rows,
    };

    [accrual_band, summary_band]
}
```

Assumptions:
1. "Physically separated" = same tab, vertically stacked bands with a fixed blank-row gap (chosen: 2 rows), not two different spreadsheet tabs/sheet objects.
2. Bands are stacked vertically (accrual band above, summary below) rather than side-by-side columns, since both are row-per-record tables.
3. The per-`(Jurisdiction, Tax Year)` sum is a mechanical rollup of kernel-supplied `accrued_cents` — treated as projection, not "tax math," so it stays in sheets-view.
4. Grouping/row order is deterministic ascending `(Jurisdiction, Tax Year)` via `BTreeMap`; EARS doesn't specify sort order.
5. Empty `accruals` input yields both bands header-only with zero data rows — no fabricated jurisdiction/year rows.
6. Duplicate `accrual_id`s are not deduplicated or validated; sheets-view trusts kernel-provided rows as-is.
7. `CellValue`/typed-cell enum assumed pre-existing in the crate per "typed ranges" language; sketched minimally here.
8. `tax_year` modeled as `u32` calendar year, not a fiscal-year string.
9. Negative `accrued_cents` (e.g., refund/reversal) flows through unmodified — no sign validation, consistent with sheets-view owning no accounting logic.
10. `start_row` is computed relative to a tab that begins at row 1 with no preceding content; absolute placement within a larger tab layout is left to the caller.