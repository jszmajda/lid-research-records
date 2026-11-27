SHEET-PUB-001 (Ubiquitous) — The system shall model a published view tab as a name, a typed header row, and an ordered list of rows of cells, where each cell is either an engine Value or a live Formula, and shall write each cell's raw text (a Formula's text including its leading `=`) to the workbook.

SHEET-PUB-002 (Ubiquitous) — Data rows shall be written from the fixed anchored start row `DATA_START_ROW = 2` (1-based); row 1 is the frozen typed header.

SHEET-PUB-003 (Event-driven) — When a view tab is republished, the system shall rewrite the tab's data range wholesale as a single atomic batchUpdate and truncate the residual tail to exactly the new row count, so no leftover rows from a prior publish survive and no half-written window is observable (republishing 3 rows then 1 row leaves exactly 1 row).

SHEET-PUB-004 (Unwanted) — The frozen header (row 1) shall never be rewritten on republish; only the range from row 2 down is rewritten. A republish shall present a byte-identical header, and a mismatch shall fail loudly (assertion, unconditional in all builds).

SHEET-PUB-005 (Event-driven) — When the target tab does not exist (fresh workbook), the system shall create the sheet, write the tab's header once at `'<tab>'!A1`, then retry the data write; any step failing shall yield `ViewError::PublishFailed`.

SHEET-PUB-006 (Event-driven) — When writing data rows, the system shall split them into successive row-anchored chunks of at most `VIEW_WRITE_CHUNK_ROWS = 500` rows, chunk *i* anchored at range `'<tab>'!A{2 + i*500}:Z`, so no single write carries an oversized payload. A tab of exactly 500 rows shall ride exactly one update call; 501 rows shall ride two, with row 501 landing intact at the chunk boundary. An empty row set shall still issue one update over `'<tab>'!A2:Z` (clearing the tab).

SHEET-PUB-007 (Ubiquitous) — A `Cell::Value` shall be written as a Sheets `userEnteredValue` (not a forced string), so a bare number parses as a number and a percent-suffixed value such as `"20.0000%"` coerces to the numeric fraction `0.20` that the post-tax formulas (`=G*H`, `=G*(1-H)`) multiply; a `Cell::Formula` shall be written as a `userEnteredValue` formula.

SHEET-PUB-008 (Unwanted) — If the underlying write fails (workbook unreachable), the system shall return `ViewError::PublishFailed`, leave the tab exactly as-is (nothing lands, canonical log untouched), flag the tab stale, and write a best-effort in-tab banner `"STALE — last sync <ts>"`; a failed banner write shall be ignored, the stale flag persisting for the TUI. The tab shall be retried on the next sync, clearing the flag on success.

SHEET-PUB-009 (Unwanted) — Republish shall acquire the advisory write-lock before any workbook mutation; if the lock is held, it shall write nothing, return `published: false`, and leave the stale set unchanged. All view-tab writes shall complete before any settle-pass read.