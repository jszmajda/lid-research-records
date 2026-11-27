**Concern: view-tab cell rewrite on republish (batch_update_view + republish loop)**

**Ubiquitous:**
- The system shall write a view tab's data rows, from the fixed anchored `DATA_START_ROW` (constant = 2, i.e. row 2, 1-based) through column Z, as exactly one atomic `update_range` call per tab (range `'{tab}'!A{DATA_START_ROW}:Z`).
- The system shall never rewrite row 1 (the typed header) after its first write; only the data range is rewritten on republish.
- The system shall write a `Cell::Value` as a Sheets `userEnteredValue` (never a forced `stringValue`), so a bare number parses as numeric and a percent-suffixed string (e.g. `"20.0000%"`) parses as the numeric fraction with percent format; a `Cell::Formula` is likewise written as `userEnteredValue`.
- The republish shall acquire the advisory write-lock before any tab mutation and release it only after all writes in the cycle complete.
- The settle-pass price read (`read_price_pass`) shall never occur inline with or before a cycle's writes — it begins strictly after the last write.

**Event-driven:**
- WHEN republish writes a tab whose new row count is smaller than the previously published count, the system shall tail-truncate: replace `rows` wholesale so no residual/stale rows remain beyond the new count.
- WHEN the target tab does not yet exist, the system shall create it, write the typed header to row 1 exactly once, then write the data range (single retry after `ensure_sheet`).
- WHEN one tab's write fails inside a multi-tab republish, the system shall continue writing the remaining tabs (independent per-tab outcome), not abort the cycle.
- WHEN all per-tab writes have been attempted, the system shall reassert the fixed workbook tab order; if that call fails, `RepublishOutcome.published` is `false` even if every individual tab write succeeded.
- WHEN a previously-stale tab's republish succeeds, the system shall clear that tab's stale flag.

**State-driven:**
- WHILE the advisory lock is held by another party, republish shall write nothing to any tab and return `published: false`, leaving the current stale-tab set unchanged (non-destructive refusal).

**Unwanted behavior:**
- IF a tab's `batchUpdate` fails, THEN the system shall leave that tab's previously published content unchanged, return `ViewError::PublishFailed`, flag the tab stale, and best-effort write an in-tab banner `"STALE — last sync {ts}"`; a banner-write failure shall not additionally fail the outcome.
- IF a republish presents a header different from the tab's previously published header, THEN this is a contract violation (the reference test double asserts equality and panics rather than silently accepting it).