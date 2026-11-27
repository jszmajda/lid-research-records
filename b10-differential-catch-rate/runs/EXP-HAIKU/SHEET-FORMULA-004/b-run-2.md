Based on the three source files, here are the EARS-style requirements for how the Tax tab's tax-adjusted figures are computed and presented:

---

**TAX-RESERVE-001: Reserve-summary band carries kernel-exact five-column stacked figures** [ubiquitous]
The Tax tab's reserve-summary band renders one row per (Jurisdiction, Tax Year) pair. Each row presents exactly five kernel-exact value columns — Accrued, Moved, Paid, Outstanding, Shortfall — sourced directly from `tax::annual_report`'s `AnnualRow` (each field: `accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents`). All five are populated per row (never blank or missing).

**TAX-RESERVE-002: Reserve-summary dollar format is signed cents-exact string** [ubiquitous]
Dollar amounts in the reserve-summary band format via `fmt_cents(Cents)` producing signed literal strings: `[sign]{whole}.{frac:02}` where `whole = abs(cents) / 100` and `frac = abs(cents) % 100`. Negative amounts render with leading `"-"` (e.g., `Cents(-5000)` → `"-50.00"`); zero renders as `"0.00"`.

**TAX-RESERVE-003: Accrual band is one-row-per-accrual, no among-data summary rows** [ubiquitous]
The Tax tab's accrual band renders exactly one row per accrual under header [Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State]. No blank separator rows, label rows, or embedded second headers appear among the data rows — the band is natively Sheets-filterable end-to-end.

**TAX-RESERVE-004: Accrual Amount field renders only applied_cents or empty** [ubiquitous]
The accrual band's Amount column renders each accrual's `applied_cents` via `fmt_cents()` if `Some(cents)`, or as an empty string if `None`. The encoding is idempotent across republish.

**TAX-RESERVE-005: Accrual Jurisdiction and Lifecycle State render canonical labels** [ubiquitous]
The accrual band's Jurisdiction column renders via `jurisdiction_label()`: `Federal` → `"Federal"`, `State(code)` → `"State({code})"`. The Lifecycle State column renders via `lifecycle_label()`: `Accrued` → `"Accrued"`, `Allocated{..}` → `"Allocated"`, `Moved{..}` → `"Moved"`, `Paid{..}` → `"Paid"`.

**TAX-RESERVE-006: Tax tab contains only kernel-exact values, never live formulas** [unwanted-behavior]
Every cell in both the accrual and reserve-summary bands is an engine value (kernel-exact, stacked, as-of-last-sync). No `GOOGLEFINANCE` or other live-price formulas appear in the Tax tab, distinguishing it from the Positions tab's post-tax live estimates.

**TAX-RESERVE-007: Accrual and reserve-summary bands are distinct typed ranges with separate frozen headers** [ubiquitous]
The accrual band (`TAX_TAB`) and reserve-summary band (`TAX_RESERVE_TAB`) are rendered as separate `ViewTab` structs with distinct headers and names. They never interleave or embed; each is independently published and frozen at its header row, enabling Sheets' native filtering and sorting within each band.