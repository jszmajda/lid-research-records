**Ubiquitous**
- SHEET-VIEW-U1: The system shall always confine a republish write to the data range starting at the fixed anchored row `DATA_START_ROW = 2` through column Z (`'{tab}'!A2:Z`); row 1 (the header) is outside this range and is never included in a republish write.
- SHEET-VIEW-U2: A `Cell::Value` shall be written as a Sheets `userEnteredValue` (never a forced string), and a `Cell::Formula` shall be written as a `userEnteredValue` formula string — both cross the seam as plain cell text (`Cell::text()`), typing decided by the caller, not the adapter.

**Event-driven**
- SHEET-VIEW-E1: WHEN a view tab is republished, THE system SHALL write all data rows as ONE atomic `update_range` call (full-tab batchUpdate) that replaces the prior data rows wholesale and tail-truncates to the exact new row count — a republish with fewer rows than before must leave no residual stale rows beyond the new count.
- SHEET-VIEW-E2: WHEN the target tab does not exist yet, THE system SHALL treat "missing tab" as write-implies-create: create the sheet (`ensure_sheet`), write the tab's typed header to row 1 exactly once, then write the data range — not surface a hard failure.
- SHEET-VIEW-E3: WHEN a tab's low-level write fails, THE system SHALL leave that tab unmodified, mark it stale, best-effort write a `"STALE — last sync {ts}"` banner to cell `AA1` (a banner-write failure is swallowed, not propagated), and continue republishing the remaining tabs in the batch (one tab's failure does not abort the cycle); the overall outcome reports `published: false` plus the accumulated stale-tab set.
- SHEET-VIEW-E4: WHEN a previously-stale tab's next republish succeeds, THE system SHALL clear its stale flag.
- SHEET-VIEW-E5: WHEN republish runs, THE system SHALL acquire the advisory write-lock before any tab mutation and release it after all tab writes and the tab-order reassert complete.
- SHEET-VIEW-E6: WHEN all tab writes complete, THE system SHALL reassert the full workbook tab order via one `set_tab_order` call; its failure also sets `published: false` but does not revert already-written tabs.
- SHEET-VIEW-E7: WHEN `republish_then_settle` runs, THE system SHALL perform every settle-pass read strictly after every republish write in that cycle (never interleaved/inline with the formula write).

**Unwanted behavior**
- SHEET-VIEW-UB1: IF the advisory lock is already held, THEN THE system SHALL write nothing to any tab this cycle and return `published: false` with the stale set unchanged (no partial/concurrent write).
- SHEET-VIEW-UB2: IF a republish presents a header differing from the tab's previously-written header, THEN THE system SHALL reject/refuse it as a contract violation — the header is immutable post-creation (enforced by hard assertion in test harness).
- SHEET-VIEW-UB3: IF the low-level write fails, THEN THE system SHALL NOT produce a half-written data range (no partial row mix between old and new content).