```rust
/// Cents newtype and CellValue are assumed defined in a shared crate.
pub struct Accrual {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrual_date: chrono::NaiveDate,
    pub description: String,
    pub amount: Cents,
}

/// Precomputed by the kernel — sheets-view performs no tax/accounting math.
pub struct ReserveSummaryRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub reserved_amount: Cents,
}

pub struct TypedRange {
    pub name: &'static str,
    pub start_row: usize, // 1-based absolute sheet row of the header
    pub headers: Vec<&'static str>,
    pub rows: Vec<Vec<CellValue>>,
}

/// Blank rows enforcing physical separation between bands.
const BAND_GAP_ROWS: usize = 2;

pub fn build_tax_tab_ranges(
    accruals: &[Accrual],
    reserve_summary: &[ReserveSummaryRow],
    first_row: usize,
) -> [TypedRange; 2] {
    let mut ar: Vec<&Accrual> = accruals.iter().collect();
    ar.sort_by_key(|a| (a.jurisdiction.clone(), a.tax_year, a.accrual_date));

    let accrual_band = TypedRange {
        name: "Tax · Accruals",
        start_row: first_row,
        headers: vec!["Jurisdiction", "Tax Year", "Date", "Description", "Amount"],
        rows: ar.iter().map(|a| vec![
            CellValue::Text(a.jurisdiction.clone()),
            CellValue::Number(a.tax_year as f64),
            CellValue::Date(a.accrual_date),
            CellValue::Text(a.description.clone()),
            CellValue::Cents(a.amount),
        ]).collect(),
    };

    let summary_start = accrual_band.start_row + 1 + accrual_band.rows.len() + BAND_GAP_ROWS;

    let mut sr: Vec<&ReserveSummaryRow> = reserve_summary.iter().collect();
    sr.sort_by_key(|r| (r.jurisdiction.clone(), r.tax_year));

    let summary_band = TypedRange {
        name: "Tax · Reserve Summary",
        start_row: summary_start,
        headers: vec!["Jurisdiction", "Tax Year", "Reserved Amount"],
        rows: sr.iter().map(|r| vec![
            CellValue::Text(r.jurisdiction.clone()),
            CellValue::Number(r.tax_year as f64),
            CellValue::Cents(r.reserved_amount),
        ]).collect(),
    };

    [accrual_band, summary_band]
}
```

ASSUMPTIONS:
1. `ReserveSummaryRow` (jurisdiction, tax_year, reserved_amount) is precomputed upstream by the kernel and passed in already-aggregated — sheets-view does no summing, per the stated crate boundary.
2. Physical separation is implemented as a fixed row-count gap (`BAND_GAP_ROWS = 2`) between the end of the accrual band and the start of the summary band, rather than e.g. separate named-range objects with no positional relationship — chosen because "physically separated" implies sheet layout, not just typing.
3. Both bands include their own header row; an empty `accruals` or `reserve_summary` slice yields a band with header only and zero data rows (never omitted, never collapsed into the other band).
4. Accrual band row order: stable sort by `(jurisdiction, tax_year, accrual_date)` for readability; requirement doesn't specify order.
5. Reserve summary rows sorted by `(jurisdiction, tax_year)`; duplicate keys in the input are assumed pre-deduplicated by the kernel (not sheets-view's job to enforce one-row-per-key).
6. `TypedRange.name` values (`"Tax · Accruals"`, `"Tax · Reserve Summary"`) are literal identifiers used for named-range registration; exact accrual-band name isn't specified by SHEET-TAB-004, only the summary band's name is given verbatim.
7. `first_row` is caller-supplied (tab layout owns absolute placement); this function is layout-composable, not tab-position-aware.
8. Jurisdiction is modeled as `String` (no enum given in the requirement); Tax Year as `u16`.