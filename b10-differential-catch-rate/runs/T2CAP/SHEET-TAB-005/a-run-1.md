```rust
// crates/sheets-view/src/tabs/tax_reserve.rs
// @spec SHEET-TAB-005
use std::collections::BTreeMap;
use crate::grid::{Band, Row, Cell};
use crate::fmt::cents;                       // Cents -> display string
use kernel::tax::{AnnualReport, Jurisdiction, TaxYear, Cents};

pub const BAND_TITLE: &str = "Tax · Reserve Summary";
const HEADERS: [&str; 7] = [
    "Jurisdiction", "Tax Year", "Accrued", "Moved", "Paid", "Outstanding", "Shortfall",
];

/// Projects `tax::annual_report` output into the band. Pure values only:
/// no derivation, netting, rounding, or re-checking of the figures.
pub fn reserve_summary_band(reports: &[AnnualReport]) -> Band {
    let mut sorted: BTreeMap<(&Jurisdiction, TaxYear), &AnnualReport> = BTreeMap::new();
    for r in reports {
        sorted.insert((&r.jurisdiction, r.tax_year), r); // last wins on dup key
    }

    let mut rows = vec![Row::header(HEADERS)];
    for ((juris, year), r) in sorted {
        rows.push(Row::new(vec![
            Cell::text(juris.as_str()),
            Cell::text(year.to_string()),
            Cell::money(cents(r.accrued)),
            Cell::money(cents(r.moved)),
            Cell::money(cents(r.paid)),
            Cell::money(cents(r.outstanding)),
            Cell::money(cents(r.shortfall)),
        ]));
    }
    if rows.len() == 1 {
        rows.push(Row::note("No tax reserve activity"));
    }
    Band::new(BAND_TITLE, rows)
}
```

ASSUMPTIONS (all invented):

1. `tax::annual_report` returns/collects into `Vec<AnnualReport>`, one struct per `(Jurisdiction, TaxYear)`, with fields named exactly `accrued`, `moved`, `paid`, `outstanding`, `shortfall`, all `Cents`.
2. `Cents` is an integer newtype (i64); negative values are legal and are rendered as-is — no clamping, no abs(), since clamping would be tax math.
3. `Jurisdiction` is an opaque type exposing `as_str()`; `TaxYear` is `Copy + Ord + Display`.
4. **Chosen interpretation of "per (Jurisdiction, Tax Year)"**: one row per pair, all five figures as columns — rather than one row per figure or a jurisdiction-nested block. Chosen because it is the flattest projection that keeps every figure a leaf cell, matching "consumed as pure values."
5. Ordering unspecified by the EARS; I impose deterministic sort by `(Jurisdiction, TaxYear)` via `BTreeMap` so republished tabs diff cleanly.
6. Duplicate keys in input: last-writer-wins, no merge/sum (summing would be accounting math this crate must not own).
7. Empty input: band still emitted with headers plus a "No tax reserve activity" note row, so the tab shape is stable.
8. No totals row, no derived shortfall check (`outstanding` vs `shortfall` consistency is the kernel's business).
9. Rendering: `Cell::money` carries the integer Cents plus a numeric format hint; `cents()` does presentational scaling only. No GOOGLEFINANCE formula cells here — reserve figures are settled kernel values, not live-price oracle reads.
10. The band is read-only output; the function is total and infallible (no `Result`) since all inputs are already-validated kernel values.