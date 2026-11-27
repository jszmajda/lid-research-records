```rust
/// Kernel-provided, already-aggregated rows — sheets-view does not compute sums.
pub struct AccrualRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrual_id: String,
    pub amount: Cents,
    // ...other kernel-owned accrual fields
}

pub struct ReserveSummaryRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub reserve_total: Cents, // computed upstream by kernel
}

pub struct TypedRange {
    pub schema_tag: &'static str, // "tax.accrual" | "tax.reserve_summary"
    pub title: Option<String>,
    pub headers: Vec<String>,
    pub rows: Vec<Vec<CellValue>>,
    pub start_row: u32,
    pub end_row: u32,
}

pub struct TaxTabLayout {
    pub accrual_band: TypedRange,
    pub reserve_summary_band: TypedRange,
}

const GAP_ROWS: u32 = 2;

pub fn build_tax_tab(
    accruals: &[AccrualRow],
    reserve_summary: &[ReserveSummaryRow],
) -> TaxTabLayout {
    let accrual_headers = vec!["Accrual ID", "Jurisdiction", "Tax Year", "Amount"]
        .into_iter().map(String::from).collect::<Vec<_>>();
    let accrual_rows: Vec<Vec<CellValue>> = accruals.iter()
        .map(|a| vec![
            CellValue::Text(a.accrual_id.clone()),
            CellValue::Text(a.jurisdiction.clone()),
            CellValue::Number(a.tax_year as f64),
            CellValue::Cents(a.amount),
        ]).collect();
    let accrual_start = 1;
    let accrual_end = accrual_start + accrual_rows.len() as u32; // header + N rows

    let summary_headers = vec!["Jurisdiction", "Tax Year", "Reserve Total"]
        .into_iter().map(String::from).collect::<Vec<_>>();
    let summary_rows: Vec<Vec<CellValue>> = reserve_summary.iter()
        .map(|s| vec![
            CellValue::Text(s.jurisdiction.clone()),
            CellValue::Number(s.tax_year as f64),
            CellValue::Cents(s.reserve_total),
        ]).collect();
    let summary_start = accrual_end + GAP_ROWS;
    let summary_end = summary_start + summary_rows.len() as u32;

    TaxTabLayout {
        accrual_band: TypedRange {
            schema_tag: "tax.accrual", title: None,
            headers: accrual_headers, rows: accrual_rows,
            start_row: accrual_start, end_row: accrual_end,
        },
        reserve_summary_band: TypedRange {
            schema_tag: "tax.reserve_summary",
            title: Some("Tax · Reserve Summary".into()),
            headers: summary_headers, rows: summary_rows,
            start_row: summary_start, end_row: summary_end,
        },
    }
}
```

Assumptions:
1. `reserve_summary` arrives pre-aggregated from the kernel (per SHEET-TAB-004's own boundary: sheets-view owns no accounting/tax math) — no grouping/summing/dedup happens here; duplicate `(Jurisdiction, TaxYear)` rows pass through unchanged if the kernel emits them.
2. "Typed range" = a schema-tagged region (`schema_tag`) plus a Google Sheets named range, not merely a visual gap — so downstream consumers address bands by name/type, not by scanning content.
3. Physical separation implemented as a fixed `GAP_ROWS = 2` blank-row buffer; bands never share a row range, structurally preventing a summary row from landing inside the accrual band.
4. Layout order (accrual band above summary band) is arbitrary but fixed/consistent across publishes.
5. Empty input slices still publish a header-only band (zero data rows), not an omitted range.
6. Title/banner `"Tax · Reserve Summary"` is a literal string in the band's title cell.
7. `Cents`, `CellValue` assumed pre-existing shared kernel/sheets-view types.