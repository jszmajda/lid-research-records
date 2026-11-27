SHEET-TAX-001 (ubiquitous) — The system shall publish the Tax surface as two structurally distinct typed bands: an accrual band named "Tax" under the frozen header ["Sale ID","Lot ID","Jurisdiction","Tax Year","Amount","Lifecycle State"], and a reserve-summary band named "Tax · Reserve Summary" under the frozen header ["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]. The reserve band is part of the Tax surface, not a fifth entry in VIEW_TABS (which is exactly ["Positions","Open Lots","Realized","Tax"], length 4).

SHEET-TAX-002 (ubiquitous) — Every cell of both Tax bands shall be an engine value, never a live formula; the Tax figures are kernel-exact and as-of-last-sync, carrying no GOOGLEFINANCE dependence.

SHEET-TAX-003 (ubiquitous) — The accrual band shall contain exactly one row per accrual, in the order the accruals are supplied, each row exactly as wide as its header. It shall contain no among-data summary rows: no blank/empty first cell, no "RESERVE SUMMARY" label row, and no row equal to the reserve header embedded as data.

SHEET-TAX-004 (ubiquitous) — Each accrual row shall render: sale id; lot id; jurisdiction label ("Federal", or "State(<code>)"); tax year as its integer digits; Amount; and lifecycle-state label, one of "Accrued" / "Allocated" / "Moved" / "Paid" (state payloads discarded).

SHEET-TAX-005 (unwanted-behavior) — If an accrual's applied amount is absent, then the Amount cell shall be the empty string (no placeholder, no zero).

SHEET-TAX-006 (ubiquitous) — The reserve band shall contain exactly one row per (Jurisdiction, Tax Year) AnnualRow, in the order supplied and one-to-one with the supplied rows, each carrying all five money figures — Accrued, Moved, Paid, Outstanding, Shortfall — copied kernel-exact from that AnnualRow with no re-derivation, netting, or aggregation in the view. None of the five may be blank, including when zero.

SHEET-TAX-007 (ubiquitous) — Money in both Tax bands shall be rendered from integer Cents as a fixed two-decimal string with a leading "-" for negatives and no thousands separators or currency symbol (Cents(5000) → "50.00", Cents(2000) → "20.00", Cents(0) → "0.00"); the sign is carried by the prefix and the magnitude by the absolute value.

SHEET-TAX-008 (ubiquitous) — The Tax tab shall sit fourth in the reasserted workbook order, after Positions, Open Lots, Realized and before History, the config tabs, and the far-right event logs.

SHEET-TAX-009 (ubiquitous) — Tax rendering shall be total: it returns a TaxView unconditionally, with no error path, and shall perform no accounting or tax math (Amount, the five reserve figures, jurisdiction and lifecycle identity all originate in the tax kernel).

SHEET-TAX-010 (ubiquitous) — Both Tax bands shall be published like any view tab: data written from DATA_START_ROW = 2 beneath a frozen row-1 header that is written once and never rewritten on republish, with the residual tail truncated to the exact row count.