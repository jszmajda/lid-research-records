## Tax Tab Tax-Adjusted Figures Requirements

**SHEET-TAX-001: Accrual Band — One Row Per Accrual, No Among-Data Summary**
The Tax tab's accrual band renders one row per tax accrual under the fixed header [Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State]. Every row is a genuine accrual (no blank/label separator rows, no embedded reserve-summary header). The band is natively filterable and sortable end-to-end.

**SHEET-TAX-002: Reserve Summary — Distinct Typed Band, One Row Per (Jurisdiction, Tax Year)**
The reserve summary is a **distinct typed range** (name: "Tax · Reserve Summary") with its own frozen header [Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall]. One row per (Jurisdiction, Tax Year) pair from tax::annual_report. The reserve summary never sits embedded inside the accrual band; both are kept as separate one-row-per-entity ranges.

**SHEET-TAX-003: Accrual Amount — Formatted Dollar String, Nullable**
The accrual-band "Amount" column formats the accrual's `applied_cents` via `fmt_cents` (dollar string, sign-aware, two decimal places: e.g., "150.00", "-50.00"). An accrual with no applied amount (None) renders empty.

**SHEET-TAX-004: Lifecycle State Label — Four-State Enumeration**
The accrual-band "Lifecycle State" column renders the accrual's state label: "Accrued", "Allocated", "Moved", or "Paid" (mapping from tax::AccrualState enum).

**SHEET-TAX-005: Jurisdiction Label — Federal or State Code**
Both bands format jurisdiction: "Federal" for Federal, "State(XX)" for State(code).

**SHEET-TAX-006: Reserve Summary — All Five Columns Kernel-Exact, Never Blank**
The reserve summary's five figures (Accrued, Moved, Paid, Outstanding, Shortfall) are kernel-exact values from the AnnualRow: `accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents`. Each is formatted via `fmt_cents` (dollar string, sign-aware, two decimal places). **None of the five columns is blank** — every row carries all five values, even if zero.

**SHEET-TAX-007: Tax Tab — Kernel-Exact Values Only, No Live Formulas**
Both the accrual and reserve-summary bands contain only engine-written values (no `GOOGLEFINANCE` formulas or cell references). All figures are kernel-exact, stacked, as-of-last-sync — distinct from the Positions tab's live-price estimate columns.

**SHEET-TAX-008: Accrual Row Width — Typed Header, No Ragged Rows**
Every accrual-band row is exactly as wide as `TAX_HEADER` (6 columns). No ragged rows.

---

{scratch}/audit-baseline/crates/sheets-view/src/lib.rs
{scratch}/audit-baseline/crates/sheets-view/tests/formula.rs
{scratch}/audit-baseline/crates/sheets-view/tests/tabs.rs