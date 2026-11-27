**Ubiquitous:**
- The system SHALL render the Tax tab's data as two distinct typed bands — an accrual band (tab name "Tax") and a reserve-summary band (tab name "Tax · Reserve Summary") — each carrying its own frozen header row, never combined into one range.
- The accrual band SHALL contain exactly one row per `Accrual`, with columns in this exact order: Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State.
- The reserve-summary band SHALL contain exactly one row per `(Jurisdiction, Tax Year)` entry, with columns in this exact order: Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall.
- Each row in either band SHALL have a cell count exactly equal to its own band's header length (no ragged rows).
- Row order within each band SHALL follow the order of the input slice (accruals / annual rows) as given — no sorting or grouping is applied.
- The Jurisdiction cell SHALL render as "Federal" when the jurisdiction is Federal, or as "State(<code>)" when it is a state jurisdiction.
- The Lifecycle State cell SHALL render as one of exactly: "Accrued", "Allocated", "Moved", "Paid".
- Tax Year and monetary figures (Accrued/Moved/Paid/Outstanding/Shortfall) in the reserve-summary band SHALL be the kernel-exact values from the annual-rows input, formatted via the standard cents formatter (signed, two decimal places, no currency symbol).

**Event-driven:**
- WHEN an accrual's `applied_cents` is absent (not yet applied), the Amount cell SHALL render as an empty string rather than "0.00" or any placeholder.

**Unwanted-behavior:**
- IF rendering the accrual band, THEN the system SHALL NOT insert any blank row, any label row (e.g., a "RESERVE SUMMARY" marker), or any embedded second header row (a row matching the reserve-summary header) among the accrual data rows — every row's first cell (Sale ID) SHALL be non-empty and no row SHALL equal the reserve-summary header sequence.
- IF rendering the reserve-summary band, THEN the system SHALL NOT stuff it inside the accrual band's range or give it the same tab/range name as the accrual band — the two bands' names SHALL differ.

Not covered by these two files (out of scope for this concern): row height/pixel formatting, freezing mechanics beyond "own frozen header," and any visual styling — only structural/data-shape constraints are pinned here.