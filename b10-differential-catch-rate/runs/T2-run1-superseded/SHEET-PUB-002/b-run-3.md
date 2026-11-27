**Ubiquitous**
- On republish, a view tab's row 1 (frozen header) is never rewritten; only the data range from `DATA_START_ROW` (row 2) downward is rewritten, addressed as `'{tab}'!A{DATA_START_ROW}:Z`.
- Each republish writes the full data range for a tab as exactly one atomic update call (one `batchUpdate`/`update_range`), not per-row/per-cell writes.
- A `Cell::Value` is written as a Sheets `userEnteredValue` (never a forced string), so Sheets parses plain numeric text as a number and a percent-suffixed string (e.g. `"20.0000%"`) as the numeric fraction `0.20` with percent formatting.
- A `Cell::Formula` is written as a `userEnteredValue` formula string (leading `=`).
- Republish of an existing tab must present the byte-identical header it was first published with; a differing header is a contract violation (the in-memory model enforces this as a hard, unconditional assertion, not a release-only check).

**Event-driven**
- WHEN a republish writes fewer rows than the tab's previous publish (e.g. a sold-out symbol), the system SHALL truncate the residual tail to exactly the new row count by wholesale-replacing the row set — never appending, never leaving stale leftover rows, no half-written window.
- WHEN the target view tab does not yet exist (fresh workbook), the system SHALL create the tab, write its header to row 1 exactly once, then write the data range — a bootstrap, not a failure.
- WHEN a tab's write call fails, the system SHALL leave that tab's previously published content unchanged, flag the tab stale, and best-effort write a single-cell banner `"STALE — last sync {ts}"` to cell `AA1`.
- WHEN the best-effort banner write also fails, the system SHALL NOT escalate; the tab stays recorded stale (TUI is the fallback staleness surface) and the cycle continues.
- WHEN the advisory write-lock cannot be acquired, the system SHALL write nothing to any tab this cycle, return `published=false`, and leave the existing stale set unchanged (non-destructive refusal, no partial/concurrent write).
- WHEN a previously-stale tab's next republish succeeds, the system SHALL clear that tab's stale flag.
- WHEN `set_tab_order` fails after all per-tab writes, the outcome SHALL report `published=false` for the cycle without altering individual tabs' stale flags.

**State-driven**
- WHILE republishing multiple tabs in one cycle, the system SHALL attempt every tab independently — one tab's write failure does not abort or skip remaining tabs.

**Unwanted behavior**
- IF the underlying write call errors for a reason other than missing-tab, THEN the system SHALL surface `ViewError::PublishFailed` and leave the tab's stored content untouched.