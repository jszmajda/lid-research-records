SHEET-TAX-001 (ubiquitous) The Tax surface SHALL be published as two distinct typed bands: an accrual band named "Tax" under the frozen header [Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State], and a reserve-summary band named "Tax · Reserve Summary" under the frozen header [Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall]. The reserve band SHALL NOT be a fifth entry in VIEW_TABS (VIEW_TABS is exactly [Positions, Open Lots, Realized, Tax], length 4).

SHEET-TAX-002 (ubiquitous) Every Tax-surface cell in both bands SHALL be an engine Value — kernel-exact, as-of-last-sync; no cell SHALL be a live formula (no GOOGLEFINANCE / live-price dependence), distinct from the Positions live estimate.

SHEET-TAX-003 (ubiquitous) The accrual band SHALL contain exactly one row per input accrual, in input order, each row exactly as wide as its header. It SHALL contain no among-data summary rows: no blank/label row (column 0 never empty, never "RESERVE SUMMARY"), and no row equal to the reserve header, so the band is natively filterable/sortable.

SHEET-TAX-004 (ubiquitous) Each accrual row SHALL render: sale_id; lot_id; jurisdiction as "Federal" or "State(<code>)"; tax_year as its integer; Amount as the accrual's applied_cents; lifecycle state as exactly one of "Accrued" / "Allocated" / "Moved" / "Paid" (state payloads elided).

SHEET-TAX-005 (unwanted) WHEN an accrual has no applied amount (`applied_cents` is None), the Amount cell SHALL be the empty string rather than a zero or an error.

SHEET-TAX-006 (ubiquitous) The reserve-summary band SHALL contain exactly one row per AnnualRow (one per (Jurisdiction, Tax Year)), in input order, count equal to the AnnualRow count, each row exactly TAX_RESERVE_HEADER wide.

SHEET-TAX-007 (ubiquitous) Each reserve-summary row SHALL carry ALL FIVE money figures — Accrued, Moved, Paid, Outstanding, Shortfall — verbatim from its AnnualRow's accrued/moved/paid/outstanding/shortfall cents. No one of the five SHALL ever be blank; `sheets-view` SHALL perform no arithmetic on them (no derivation, netting, or re-summing).

SHEET-TAX-008 (ubiquitous) All Tax money cells SHALL render Cents as a signed fixed-2-decimal dollar string: leading "-" iff negative, then |cents|/100, ".", and |cents|%100 zero-padded to 2 digits (e.g. Cents(5000) → "50.00", Cents(2000) → "20.00"). No thousands separators, no currency symbol.

SHEET-TAX-009 (ubiquitous) `render_tax` SHALL be total — it returns a TaxView unconditionally, with no error path and no failure on empty accrual or annual-row inputs (either band may be empty).

SHEET-TAX-010 (ubiquitous) In the workbook ordering the Tax tab SHALL be the fourth (last) view tab, after Positions/Open Lots/Realized and strictly before History, the config tabs, and the event-log tabs; this ordering SHALL be reasserted idempotently on every republish. Tax-band data rows SHALL be written from DATA_START_ROW = 2 beneath the never-rewritten frozen header, with the residual tail truncated.