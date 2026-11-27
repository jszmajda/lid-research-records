**Ubiquitous:**
- The system SHALL render the Tax view as two distinct typed bands, each its own named range with its own frozen header: an accrual band (tab name `"Tax"`) and a reserve-summary band (tab name `"Tax · Reserve Summary"`). The reserve summary SHALL NOT be stacked, appended, or embedded inside the accrual band.
- The accrual band SHALL contain exactly one row per input `Accrual`, under header `["Sale ID","Lot ID","Jurisdiction","Tax Year","Amount","Lifecycle State"]`, with no blank/label/separator rows and no embedded second header among the data rows.
- The reserve-summary band SHALL contain exactly one row per input `AnnualRow`, under header `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]`.
- Every row in either band SHALL have width exactly equal to its band's header width (no ragged rows).
- Every cell in both bands SHALL be an engine `Value` (never a live `Formula`) — the Tax view carries no live-price columns.
- Jurisdiction cells SHALL render `Federal` as the literal string `"Federal"` and `State(code)` as `"State({code})"` (code interpolated, no other transform).
- Lifecycle-state cells SHALL render as the bare variant label only — `"Accrued"`, `"Allocated"`, `"Moved"`, or `"Paid"` — discarding any payload the state carries (e.g. `Allocated{..}` still renders `"Allocated"`).
- The Amount cell SHALL be the accrual's `applied_cents` formatted via the canonical cents formatter (sign, then `whole.fractional` with fractional zero-padded to 2 digits) when present; WHEN `applied_cents` is absent (`None`), the Amount cell SHALL render as the empty string — not `"0.00"` and not omitted.
- All five reserve-summary monetary columns (Accrued, Moved, Paid, Outstanding, Shortfall) SHALL be rendered via the same canonical cents formatter, unconditionally (no optional/empty case).
- Tax Year cells in both bands SHALL render as the plain integer year string (no formatting/padding).

**Event-driven:**
- WHEN the Tax view is rendered from an accrual list and an annual-rows list, the system SHALL produce a result with the accrual band's row count equal to the accrual list's length and the reserve-summary band's row count equal to the annual-rows list's length, preserving input order (no sort/reorder).

**Unwanted behavior:**
- IF a row is written into the accrual band THEN its first cell SHALL NOT be empty, SHALL NOT equal `"RESERVE SUMMARY"`, and the full row SHALL NOT equal the reserve-summary header — i.e., no blank/label/embedded-header row may masquerade as accrual data.
- IF the two bands were given the same tab name THEN this is invalid: the accrual band's name and the reserve-summary band's name SHALL always differ.