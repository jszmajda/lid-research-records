# Rust Implementation Sketch: SHEET-TAB-005

```rust
use std::collections::HashMap;

/// Represents a jurisdiction's annual tax figures (in Cents).
/// Source from tax::annual_report module.
pub struct AnnualTaxReport {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrued: i64,      // Cents
    pub moved: i64,        // Cents
    pub paid: i64,         // Cents
    pub outstanding: i64,  // Cents
    pub shortfall: i64,    // Cents
}

/// A single row in the Tax · Reserve Summary band (sheets tab).
pub struct TaxReserveSummaryRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrued: String,
    pub moved: String,
    pub paid: String,
    pub outstanding: String,
    pub shortfall: String,
}

/// Populate Tax · Reserve Summary band from tax::annual_report figures.
/// Groups by (Jurisdiction, Tax Year); consumes pure values with no tax math.
pub fn populate_tax_reserve_summary(
    reports: Vec<AnnualTaxReport>,
) -> HashMap<(String, u16), TaxReserveSummaryRow> {
    reports
        .into_iter()
        .map(|report| {
            let key = (report.jurisdiction.clone(), report.tax_year);
            let row = TaxReserveSummaryRow {
                jurisdiction: report.jurisdiction,
                tax_year: report.tax_year,
                accrued: format_cents(report.accrued),
                moved: format_cents(report.moved),
                paid: format_cents(report.paid),
                outstanding: format_cents(report.outstanding),
                shortfall: format_cents(report.shortfall),
            };
            (key, row)
        })
        .collect()
}

/// Format Cents as currency string for sheets display.
fn format_cents(cents: i64) -> String {
    let dollars = cents / 100;
    let cents_part = (cents % 100).abs();
    format!("${}.{:02}", dollars, cents_part)
}
```

## Assumptions

1. **AnnualTaxReport shape**: `tax::annual_report` yields (or filters to) records with jurisdiction, year, and five i64 fields in Cents.
2. **Key type**: Composite key `(String, u16)` for jurisdiction + year; assumed unique.
3. **No missing fields**: All five figures are non-optional; invalid/null inputs are filtered upstream.
4. **No recalculation**: "holding no tax math of its own" interpreted as pure projection—only formats display, never computes relationships among fields.
5. **Output format**: HashMap for O(1) lookup by jurisdiction/year; values format Cents as `$X.XX` strings for sheets.
6. **Currency display**: Negative cents display with sign; e.g., -150 → `$-1.50`.
7. **No rollup or aggregation**: Each row stands alone per jurisdiction/year pair.
8. **No deduplication logic**: If two reports exist for the same jurisdiction/year, the second overwrites (HashMap behavior).

## Interpretation

The EARS specified "populate the band *per* (Jurisdiction, Tax Year)"—interpreted as output indexed by that pair, enabling fast retrieval for sheets-view to emit rows. "Consumed as pure values" ruled out computed fields (e.g., accrued − paid = remaining); this is a view, not a calculator.