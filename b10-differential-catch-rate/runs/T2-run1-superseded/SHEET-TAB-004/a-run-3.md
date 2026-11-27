```rust
/// Cents: integer money, per kernel convention.
pub type Cents = i64;

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub struct Jurisdiction(pub String);
pub type TaxYear = u16;

/// Per-accrual data band row (kernel-projected; no tax math here).
#[derive(Clone, Debug)]
pub struct AccrualRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrual_id: String,
    pub amount: Cents,
}

/// Reserve Summary band row: one per (Jurisdiction, TaxYear).
#[derive(Clone, Debug)]
pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub reserved: Cents,
}

/// A typed, contiguous row range in the Tax tab (SHEET-TAB-001).
#[derive(Debug)]
pub struct TypedRange { pub label: &'static str, pub start_row: u32, pub end_row: u32 }

const HEADER_ROWS: u32 = 1;
const BAND_GAP_ROWS: u32 = 1; // enforces physical separation, never adjacent

pub struct TaxTab {
    pub accrual_band: TypedRange,
    pub summary_band: TypedRange,
    pub accruals: Vec<AccrualRow>,
    pub summary: Vec<ReserveSummaryRow>,
}

pub fn build_tax_tab(mut accruals: Vec<AccrualRow>) -> TaxTab {
    accruals.sort_by(|a, b| (&a.jurisdiction.0, a.tax_year).cmp(&(&b.jurisdiction.0, b.tax_year)));

    let mut summary: Vec<ReserveSummaryRow> = Vec::new();
    for r in &accruals {
        if let Some(s) = summary.iter_mut()
            .find(|s| s.jurisdiction == r.jurisdiction && s.tax_year == r.tax_year) {
            s.reserved += r.amount;
        } else {
            summary.push(ReserveSummaryRow {
                jurisdiction: r.jurisdiction.clone(), tax_year: r.tax_year, reserved: r.amount,
            });
        }
    }
    summary.sort_by(|a, b| (&a.jurisdiction.0, a.tax_year).cmp(&(&b.jurisdiction.0, b.tax_year)));

    let accrual_end = HEADER_ROWS + accruals.len() as u32;
    let summary_start = accrual_end + BAND_GAP_ROWS;
    let summary_end = summary_start + HEADER_ROWS + summary.len() as u32;

    TaxTab {
        accrual_band: TypedRange { label: "Tax · Accruals", start_row: 0, end_row: accrual_end },
        summary_band: TypedRange { label: "Tax · Reserve Summary", start_row: summary_start, end_row: summary_end },
        accruals,
        summary,
    }
}
```

Assumptions:
- `Cents = i64`; `Jurisdiction` is a newtype `String`; `TaxYear = u16`. Not specified by the EARS.
- "Physically separated" interpreted as ≥1 fully blank row gap (`BAND_GAP_ROWS`) between the two bands, each carrying its own header row, so the summary band's start row is never adjacent to the accrual band's end row — resolves the ambiguity of how much separation counts as "not an among-data row."
- Reserve summary is a plain additive sum of accrual `amount` per `(Jurisdiction, TaxYear)`; this is projection/aggregation of already-computed kernel Cents, not new tax computation, consistent with "sheets-view crate ... owns no accounting or tax math."
- Sort/group key is `(Jurisdiction, TaxYear)` in lexicographic/numeric order, imposed for deterministic, diff-stable sheet output since input ordering isn't guaranteed by the EARS.
- Empty input (`accruals` is empty) yields both bands present but header-only (0 data rows), still separated by the gap — no special-cased tab suppression, since the EARS doesn't authorize omitting either band.
- Negative/zero amounts (credits, reversals) pass through unfiltered/unvalidated — the EARS specifies band structure, not amount validity.
- Duplicate `(Jurisdiction, TaxYear)` accrual rows aggregate additively into a single summary row rather than erroring, since the EARS mandates "one row per (Jurisdiction, TaxYear)" as a hard cardinality constraint on the summary band, implying pre-aggregation.
- "Typed range" is modeled minimally as a labeled row span (`label`, `start_row`, `end_row`); actual Sheets API range typing/formatting is assumed to live in a separate rendering layer not shown here.