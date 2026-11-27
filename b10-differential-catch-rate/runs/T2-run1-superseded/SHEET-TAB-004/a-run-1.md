```rust
//! sheets-view :: tax tab layout
//! @spec SHEET-TAB-004

use crate::kernel_types::Cents; // kernel-owned; sheets-view does no accounting math

/// One row of the per-accrual data band.
#[derive(Clone, Debug)]
pub struct TaxAccrualRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrual_date: String, // ISO 8601, formatting only
    pub accrual_amount: Cents,
    pub lot_ref: String,
}

/// One row of the `Tax · Reserve Summary` band.
/// Values arrive pre-aggregated from the kernel — this crate never sums.
#[derive(Clone, Debug)]
pub struct TaxReserveSummaryRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub reserve_amount: Cents,
}

/// A typed, contiguous row range within a sheet tab.
pub struct TypedRange<T> {
    pub sheet: &'static str,
    pub header: &'static [&'static str],
    pub start_row: u32, // 1-indexed, inclusive
    pub rows: Vec<T>,
}

impl<T> TypedRange<T> {
    fn end_row(&self) -> u32 {
        self.start_row + self.rows.len() as u32 // header occupies start_row - 1
    }
}

/// Gap enforcing physical separation: no shared or adjacent header/data rows.
const BAND_GAP_ROWS: u32 = 2;

pub struct TaxTab {
    pub accrual_band: TypedRange<TaxAccrualRow>,
    pub reserve_summary_band: TypedRange<TaxReserveSummaryRow>,
}

/// Builds the two typed ranges per SHEET-TAB-004. Inputs are already
/// kernel-computed; this function only lays them out and enforces separation.
pub fn build_tax_tab(
    accruals: Vec<TaxAccrualRow>,
    reserve_summaries: Vec<TaxReserveSummaryRow>,
) -> TaxTab {
    let accrual_band = TypedRange {
        sheet: "Tax",
        header: &["Jurisdiction", "Tax Year", "Date", "Amount", "Lot"],
        start_row: 2, // row 1 reserved for accrual band's own header
        rows: accruals,
    };

    let summary_start = accrual_band.end_row() + BAND_GAP_ROWS + 1; // +1 for its header row
    let reserve_summary_band = TypedRange {
        sheet: "Tax",
        header: &["Jurisdiction", "Tax Year", "Reserve Amount"],
        start_row: summary_start,
        rows: reserve_summaries,
    };

    TaxTab { accrual_band, reserve_summary_band }
}
```

Assumptions (invented, not in the EARS text):

1. `Cents` and any tax/reserve math are kernel-owned; `reserve_summaries` arrive pre-aggregated — this function never sums accruals itself (required by the crate's "no accounting math" constraint).
2. Column schemas for both bands are invented placeholders; EARS specifies row granularity only, not columns.
3. Physical separation is implemented as a fixed blank-row gap (`BAND_GAP_ROWS = 2`) plus each band owning its own header row — chosen because "physically separated ... never an among-data summary row" reads as a hard non-adjacency requirement, not merely "different range object."
4. Layout order (accrual band first, reserve summary band below) is my choice; the EARS doesn't state ordering.
5. Empty input (zero accruals or zero reserve rows) still publishes a header-only band of length 0 rather than omitting the band — treated as the safe default so downstream range references stay stable.
6. Uniqueness/ordering of `(Jurisdiction, Tax Year)` pairs in `reserve_summaries` is assumed already enforced upstream (kernel); this function does not dedupe or sort.
7. "Typed range" is modeled as a generic struct carrying sheet name, header, start row, and row data — no existing type shown in the prompt, so this shape is invented to satisfy SHEET-TAB-001's typed-range referencing.
8. Single physical sheet tab named `"Tax"` hosts both bands stacked vertically, rather than two separate sheet tabs — chosen as the more natural reading of "published as two ... ranges" (ranges, not tabs) within one Tax tab.