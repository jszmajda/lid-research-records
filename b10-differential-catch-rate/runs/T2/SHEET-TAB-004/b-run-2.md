**EARS requirements enforced — Tax tab data-band layout (sheets-view)**

Ubiquitous:
- The Tax surface SHALL be published as two structurally distinct typed bands, each with its own frozen header row: the accrual band (tab name "Tax") and the reserve-summary band (tab name "Tax · Reserve Summary"). The reserve-summary band SHALL NOT be nested, appended, or embedded inside the accrual band's row range.
- The accrual band's header SHALL be exactly, in order: Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State.
- The reserve-summary band's header SHALL be exactly, in order: Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall.
- The accrual band SHALL contain exactly one row per input accrual, in input order, with no blank/label/embedded-header rows among the data.
- The reserve-summary band SHALL contain exactly one row per input `(Jurisdiction, Tax Year)` annual-row entry, in input order.
- Every row in either band SHALL have a cell count exactly equal to its own band's header length (no ragged rows).
- All cells in both bands SHALL be engine-written values; neither band SHALL contain a live `GOOGLEFINANCE`-dependent formula cell.
- Jurisdiction SHALL render as the literal string "Federal" for the Federal jurisdiction, or as "State(<CODE>)" (code interpolated, no space) for a state jurisdiction — identically in both bands.
- Lifecycle State SHALL render as exactly one of the literal strings "Accrued", "Allocated", "Moved", "Paid", collapsing any state-variant payload (none of the variant's associated data is rendered).
- A monetary cell SHALL render via the canonical form: an optional leading "-" for negative values only (never "+" for positive/zero), the whole-dollar digits, a literal ".", and exactly two zero-padded fractional digits (e.g. `Cents(15000)` → `"150.00"`; `Cents(-500)` → `"-5.00"`).
- The reserve-summary band's Accrued/Moved/Paid/Outstanding/Shortfall cells SHALL be the kernel's `AnnualRow` cents fields formatted directly, with no re-derivation or recomputation.

Event-driven:
- When an accrual's `applied_cents` is absent (not yet applied), the Amount cell SHALL render as an empty string — not "0.00" and not any other placeholder.

Unwanted behavior:
- If a would-be accrual-band row's first cell is empty, OR its first cell equals the literal "RESERVE SUMMARY", OR the row's full cell-text sequence equals the reserve-summary header sequence, then that row SHALL NOT be produced (the accrual band must never contain a blank/label/separator row or an embedded second header masquerading as data).