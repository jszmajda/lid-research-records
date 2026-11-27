```rust
// sheets-view crate: projects tax::annual_report figures into the
// "Tax · Reserve Summary" band. No tax math — pure mapping/ordering.

use crate::money::Cents; // integer cents newtype, shared across workspace

pub struct ReserveSummaryRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

pub const BAND_NAME: &str = "Tax · Reserve Summary";

/// Projects `tax::annual_report` output into band rows, one per
/// (Jurisdiction, Tax Year), consuming all five figures as given.
pub fn build_reserve_summary_band(
    reports: &[tax::AnnualTaxReport],
) -> Vec<ReserveSummaryRow> {
    let mut rows: Vec<ReserveSummaryRow> = reports
        .iter()
        .map(|r| ReserveSummaryRow {
            jurisdiction: r.jurisdiction.clone(),
            tax_year: r.tax_year,
            accrued: r.accrued,
            moved: r.moved,
            paid: r.paid,
            outstanding: r.outstanding, // passthrough, not recomputed
            shortfall: r.shortfall,     // passthrough, not recomputed
        })
        .collect();

    rows.sort_by(|a, b| {
        a.jurisdiction
            .cmp(&b.jurisdiction)
            .then(a.tax_year.cmp(&b.tax_year))
    });
    rows
}
```

Assumptions:

1. `tax::AnnualTaxReport` is a struct with `jurisdiction: Jurisdiction`, `tax_year: TaxYear`, and the five figures as `Cents` — the actual type is unknown, so I invented a shape matching the EARS field list.
2. `Jurisdiction` is `Clone + Ord`; `TaxYear` is `Copy + Ord` (e.g. a `u16`/newtype) — needed only for deterministic sort, not stated in the EARS.
3. Row order isn't specified, so I chose Jurisdiction-then-Tax-Year ascending as a stable, arbitrary default.
4. `outstanding` and `shortfall` are taken verbatim from the report, never derived from `accrued`/`moved`/`paid` here, per "consumed as pure values ... holding no tax math of its own" — even though they look derivable, deriving them would violate the requirement.
5. One row per report entry; if `annual_report` omits a `(Jurisdiction, Tax Year)` combo, no row is synthesized (no zero-fill), since deciding what "should" exist is tax logic this crate doesn't own.
6. Duplicate `(Jurisdiction, Tax Year)` pairs in the input are assumed not to occur (upstream invariant); the sketch doesn't dedupe or merge, since inventing merge semantics would itself be tax math.
7. Negative or zero values pass through unchanged — no clamping, validation, or reinterpretation.
8. `Cents` is `Copy`, matching "Money is integer Cents" from context.
9. Formatting/display of the band (headers, currency symbols) is out of scope for this function; it returns typed rows only.