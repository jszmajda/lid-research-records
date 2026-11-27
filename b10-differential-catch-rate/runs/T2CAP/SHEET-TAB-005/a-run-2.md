```rust
// crates/sheets-view/src/tabs/tax_reserve.rs
// @spec SHEET-TAB-005
use std::collections::BTreeMap;

use crate::grid::{Band, Cell, Row};
use tax::{AnnualReport, Cents, Jurisdiction, TaxYear};

/// One rendered line of the `Tax · Reserve Summary` band.
pub struct ReserveRow {
    pub jurisdiction: Jurisdiction,
    pub tax_year: TaxYear,
    pub accrued: Cents,
    pub moved: Cents,
    pub paid: Cents,
    pub outstanding: Cents,
    pub shortfall: Cents,
}

pub const BAND_TITLE: &str = "Tax · Reserve Summary";
const HEADERS: [&str; 7] = [
    "Jurisdiction", "Tax Year", "Accrued", "Moved", "Paid", "Outstanding", "Shortfall",
];

/// Projects `tax::annual_report` output onto the band. Pure values in, cells out:
/// no arithmetic, no netting, no derivation of any figure from another.
pub fn reserve_summary_band(reports: &[AnnualReport]) -> Band {
    let mut sorted: BTreeMap<(&Jurisdiction, TaxYear), &AnnualReport> = BTreeMap::new();
    for r in reports {
        // Last writer wins on duplicate keys; kernel is expected to emit one per key.
        sorted.insert((&r.jurisdiction, r.tax_year), r);
    }

    let mut band = Band::new(BAND_TITLE, Row::header(HEADERS));
    for ((juris, year), r) in sorted {
        band.push(Row::new(vec![
            Cell::text(juris.as_str()),
            Cell::year(year),          // rendered as a plain integer, not a date
            Cell::money(r.accrued),    // Cents → sheet money cell, formatting only
            Cell::money(r.moved),
            Cell::money(r.paid),
            Cell::money(r.outstanding),
            Cell::money(r.shortfall),
        ]));
    }
    if band.is_empty() {
        band.push(Row::note("No tax reserve activity"));
    }
    band
}
```

ASSUMPTIONS (all invented):

1. `tax::annual_report` returns/produces `AnnualReport` values already keyed by `(Jurisdiction, TaxYear)`, each carrying exactly the five named `Cents` fields. Field names taken verbatim from the EARS.
2. All five figures are non-optional `Cents`; a zero figure renders as `0`, not blank.
3. `Cents` is `i64`-backed and may be negative (e.g. overpayment → negative outstanding); the view renders the sign as given rather than clamping — clamping would be tax math.
4. `outstanding` and `shortfall` arrive precomputed. Interpretation chosen: "consumed as pure values… holding no tax math of its own" forbids the view from computing `accrued - paid` even though it looks trivial.
5. Row ordering is unspecified in the EARS; chose deterministic `(Jurisdiction, TaxYear)` sort so republished tabs diff cleanly. `Jurisdiction` assumed `Ord + as_str()`.
6. Duplicate `(Jurisdiction, TaxYear)` keys: assumed a kernel invariant violation; last-wins silently rather than panicking, since the view is read-only projection.
7. Empty input renders the band with headers plus a single "No tax reserve activity" note row, so the tab shape stays stable.
8. Currency/jurisdiction-specific formatting is delegated to `Cell::money`; the band assumes a single presentation currency and does not convert.
9. Tax year rendered as a bare integer; fiscal-year jurisdictions whose year is a range are assumed already normalized by `tax`.
10. This band contains no GOOGLEFINANCE formula cells — reserve figures are settled values, not live-priced.
11. The band is emitted as a value block for the caller to place; sheet ranges, freezing, and write batching are the publisher's concern.