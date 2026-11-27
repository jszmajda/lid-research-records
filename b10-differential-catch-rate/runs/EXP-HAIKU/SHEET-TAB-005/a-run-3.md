```rust
use std::collections::BTreeMap;

/// Tax · Reserve Summary row per (Jurisdiction, Tax Year)
#[derive(Debug, Clone)]
pub struct TaxReserveSummary {
    pub jurisdiction: String,
    pub tax_year: u16,
    pub accrued_cents: i64,      // Accrued reserve
    pub moved_cents: i64,         // Amount moved (likely to actual reserve fund)
    pub paid_cents: i64,          // Amount paid out
    pub outstanding_cents: i64,   // Still outstanding/pending
    pub shortfall_cents: i64,     // Reserve shortfall (if any)
}

/// Populates Tax · Reserve Summary band from annual report figures
pub fn populate_tax_reserve_band(
    reports: &[tax::AnnualReport],
) -> Vec<TaxReserveSummary> {
    let mut summaries: BTreeMap<(String, u16), TaxReserveSummary> = BTreeMap::new();

    for report in reports {
        let key = (report.jurisdiction.clone(), report.tax_year);
        
        // Pure passthrough of figures; no tax math performed
        summaries.insert(
            key,
            TaxReserveSummary {
                jurisdiction: report.jurisdiction.clone(),
                tax_year: report.tax_year,
                accrued_cents: report.accrued_cents,
                moved_cents: report.moved_cents,
                paid_cents: report.paid_cents,
                outstanding_cents: report.outstanding_cents,
                shortfall_cents: report.shortfall_cents,
            },
        );
    }

    // Return sorted by (Jurisdiction, Tax Year) for deterministic sheet order
    summaries.into_values().collect()
}
```

**Assumptions & Interpretation Choices:**

1. **`tax::AnnualReport` structure**: Assumed it exposes `jurisdiction: String`, `tax_year: u16`, and five `*_cents: i64` fields matching the requirement's named figures.

2. **Grouping collision**: If multiple reports exist for the same `(Jurisdiction, Tax Year)` pair, later reports overwrite earlier ones (BTreeMap behavior). Alternative: merge/accumulate figures — unclear from "consumed as pure values," so chose last-write-wins as simpler.

3. **"Band"**: Interpreted as a flat, sorted Vec of rows for sheet tab population; row order is `(Jurisdiction, Tax_Year)` lexicographic for reproducibility.

4. **Return type**: Vec rather than an iterator or lazy structure, since sheets views need materialized data to write atomically.

5. **Invalid/missing figures**: Assumed `AnnualReport` data is pre-validated (negative cents, missing fields) by the tax crate; this module passes through unchanged.

6. **No deduplication logic**: If the same `(Jurisdiction, Year)` appears twice with differing figures, behavior is: last one wins. Caller responsible for ensuring single-source-of-truth input.

7. **Shortfall can be negative**: Treated as a signed value (represents overage if negative); no range clamping.

**Word count: 180** | **Code: 34 lines**