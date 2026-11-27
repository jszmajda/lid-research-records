**Layout contract of published view tabs — reconstructed EARS requirements**

**Ubiquitous**
- The system shall publish exactly four view tabs, named "Positions", "Open Lots", "Realized", and "Tax", in that fixed left-to-right order, with "Positions" as the leftmost (landing) tab.
- The full workbook tab order shall be: the four view tabs (in the above order), then "History", then the config tabs "Tax Rules", "Residency", "Platforms & Aliases" (in that order), then the event-log tabs "Ledger Events" then "Tax Events" last.
- The Tax view's per-(Jurisdiction, Tax Year) reserve summary shall be published as its own distinct tab, "Tax · Reserve Summary", with its own frozen header — never as rows embedded inside the Tax accrual band.
- Each view tab's typed header shall occupy row 1; data rows shall begin at row 2 (the anchored `DATA_START_ROW`).
- Every data row in a published tab (or band) shall contain exactly as many cells as that tab's header — no ragged rows.
- Each view tab/band shall contain exactly one row per entity (one row per position, open lot, realized sale, or accrual/reserve-summary key), with no blank, separator, label, or embedded-second-header row among the data rows.

**Event-driven**
- WHEN a view tab is republished, the system shall rewrite the data range from row 2 downward as one atomic update and truncate any residual trailing rows to the new exact row count, so no stale or human-inserted extra rows survive.
- WHEN a view tab does not yet exist (fresh workbook), the system shall create the tab, write the frozen header once, then write the data rows, rather than treat the absence as an error.
- WHEN a republish write for a tab fails (for a reason other than the tab being newly missing), the system shall leave that tab's existing content unchanged, mark it stale for retry on the next sync, and best-effort write a `"STALE — last sync {ts}"` banner to that tab's `AA1` cell.
- WHEN tab order is reasserted on republish, the result shall be idempotent — repeated republishes produce the same tab order.

**State-driven**
- WHILE a tab's header has already been written, republish shall never rewrite row 1; only the data range from row 2 down is ever rewritten.

**Unwanted behavior**
- IF the source snapshot carries two rows for the same symbol, THEN Positions rendering shall be refused with an explicit error (`DuplicateSymbolRow`) rather than silently emitting duplicate rows.