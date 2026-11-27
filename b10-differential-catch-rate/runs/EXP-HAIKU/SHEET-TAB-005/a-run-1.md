# Implementation Sketch: SHEET-TAB-005

```rust
use std::collections::HashMap;

#[derive(Clone, Debug)]
pub struct TaxReserveSummaryRow {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrued: i64,      // Cents
    pub moved: i64,        // Cents
    pub paid: i64,         // Cents
    pub outstanding: i64,  // Cents
    pub shortfall: i64,    // Cents
}

/// Populate Tax · Reserve Summary band: group tax::annual_report figures by
/// (Jurisdiction, Tax Year), aggregate, and produce rows for sheets output.
pub fn populate_tax_reserve_summary(
    report: &tax::annual_report::AnnualReport,
) -> Vec<TaxReserveSummaryRow> {
    let mut by_key: HashMap<(String, u16), TaxReserveSummaryRow> = HashMap::new();
    
    for entry in &report.entries {
        let key = (entry.jurisdiction.clone(), entry.tax_year);
        let row = by_key.entry(key).or_insert_with(|| TaxReserveSummaryRow {
            jurisdiction: entry.jurisdiction.clone(),
            tax_year: entry.tax_year,
            accrued: 0,
            moved: 0,
            paid: 0,
            outstanding: 0,
            shortfall: 0,
        });
        
        // Consume figures as-is: pure value summation, no tax math
        row.accrued += entry.accrued.unwrap_or(0);
        row.moved += entry.moved.unwrap_or(0);
        row.paid += entry.paid.unwrap_or(0);
        row.outstanding += entry.outstanding.unwrap_or(0);
        row.shortfall += entry.shortfall.unwrap_or(0);
    }
    
    let mut rows: Vec<_> = by_key.into_values().collect();
    rows.sort_by(|a, b| {
        a.jurisdiction.cmp(&b.jurisdiction)
            .then_with(|| a.tax_year.cmp(&b.tax_year))
    });
    rows
}
```

## Assumptions (Inventions Required)

1. **AnnualReport shape**: `tax::annual_report::AnnualReport` has field `entries: Vec<TaxEntry>` (or iterable equivalent).
2. **TaxEntry fields**: Each entry holds `jurisdiction: String`, `tax_year: u16`, and five figure fields (accrued, moved, paid, outstanding, shortfall) as `Option<i64>`.
3. **Money type**: All figures are `i64` (Cents); negative values allowed and passed through.
4. **Aggregation strategy**: Multiple entries matching the same `(Jurisdiction, Tax Year)` pair are summed (not deduplicated or averaged).
5. **Missing data default**: `None` figures default to 0 in summation.
6. **Output shape**: "Populate the band" means produce `Vec<TaxReserveSummaryRow>` consumable by sheets-view layer for row insertion.
7. **Jurisdiction matching**: Case-sensitive string equality; no normalization.
8. **Sort order**: Deterministic output sorted by jurisdiction (ASC), then tax_year (ASC) for stable Google Sheets insertion.
9. **Scope**: All entries in report are included; no year-range or jurisdiction filtering at this layer.
10. **Tax math**: None. Function is a pure projection+aggregation; callers who need derived fields (e.g., net_available = paid - outstanding) compute downstream.
11. **No validation**: Negative shortfall or other inconsistencies pass through; semantic validation is caller's responsibility.

**Interpretation choice**: "Shortfall" is treated as a figure field (not computed), consistent with "consumed as pure values."

{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key