SHEET-TAX-RESERVE requirements (reserve-summary figures)

**SHEET-TAX-RESERVE-001 (ubiquitous).** The Tax surface shall publish the reserve summary as its own typed band named `"Tax · Reserve Summary"`, distinct from the accrual band (named `"Tax"`), each with its own frozen header and one row per entity; the reserve band shall carry no among-data summary, blank, label, or embedded-header rows, and shall not appear as a fifth entry in `VIEW_TABS`.

**SHEET-TAX-RESERVE-002 (ubiquitous).** The reserve band header shall be exactly, in order: `Jurisdiction`, `Tax Year`, `Accrued`, `Moved`, `Paid`, `Outstanding`, `Shortfall`.

**SHEET-TAX-RESERVE-003 (event-driven).** When the Tax view is rendered from the accrual list and `tax::annual_report`'s `AnnualRow` list, the reserve band shall emit exactly one row per supplied `AnnualRow`, in the supplied order (row count == `annual_rows.len()`), each row keyed by that row's `(jurisdiction, tax_year)`.

**SHEET-TAX-RESERVE-004 (ubiquitous).** Each reserve row's five money figures shall be the kernel-exact values taken straight from its `AnnualRow` — `accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents` — with no recomputation, derivation, netting, or aggregation performed by the view (`sheets-view` owns no tax math).

**SHEET-TAX-RESERVE-005 (ubiquitous).** Every reserve-band cell shall be an engine `Value`; no cell shall be a live `GOOGLEFINANCE`-dependent formula. The band is kernel-exact and as-of-last-sync, unlike Positions' live estimate.

**SHEET-TAX-RESERVE-006 (ubiquitous).** Money shall render as a signed fixed-two-decimal dollar string derived from integer `Cents`: `-` prefix iff negative, then `|cents|/100`, `.`, and `|cents|%100` zero-padded to two digits (e.g. `Cents(50_00)` → `"50.00"`, `Cents(20_00)` → `"20.00"`); no thousands separators, no currency symbol.

**SHEET-TAX-RESERVE-007 (unwanted behavior).** None of the five money columns shall ever render as an empty string, including when the figure is zero; all five shall be populated on every row (zeros render `"0.00"`, not blank). (Contrast: the accrual band's `Amount` renders empty when `applied_cents` is `None`.)

**SHEET-TAX-RESERVE-008 (ubiquitous).** `Jurisdiction` shall render as `"Federal"` for Federal and `"State(<code>)"` for a state; `Tax Year` shall render as the year's decimal integer string (e.g. `"2022"`). These two columns are the row's identity for lookup.

**SHEET-TAX-RESERVE-009 (state-driven).** While a `(Jurisdiction, Tax Year)` has undergone allocate/move/pay lifecycle activity, its reserve row shall reflect the resulting distinct `Moved` and `Paid` figures independently (e.g. a `Move` of `Cents(50_00)` and a `Pay` of `Cents(20_00)` render `"50.00"` and `"20.00"`), not merely an outstanding balance.

**SHEET-TAX-RESERVE-010 (ubiquitous).** Reserve rows shall be written from `DATA_START_ROW` = 2 beneath the never-rewritten frozen header, published as one atomic per-tab `batchUpdate` with residual-tail truncation.