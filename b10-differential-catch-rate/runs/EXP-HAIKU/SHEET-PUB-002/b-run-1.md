Looking at these files to identify requirements for view tab cell rewriting on republish.

**EARS-Style Requirements: View Tab Cell Rewriting on Republish**

**U-PUB-001: Frozen Header Never Rewritten**
On republish, the frozen header row (row 1) is written exactly once during tab creation and never modified thereafter. Any republish cycle must present a byte-identical header; a mismatched header is a contract violation (enforced as panic-on-assertion). Only the data range from row 2 (DATA_START_ROW) down is subject to rewrite.

**U-PUB-002: Atomic Data Range Replacement with Tail Truncation**
On republish, the tab's data rows are replaced wholesale from row 2 onward to match the exact new row count. A republish with N rows truncates the old row set (if longer) to exactly N rows, eliminating residual stale rows in a single atomic operation. No half-written window or incremental append; the old rows are replaced en masse, never modified in place.

**U-PUB-003: Row Anchoring from Fixed Start Row**
Data rows are always written starting from row 2 (DATA_START_ROW constant). Each republish cycle writes the range `'{tabname}'!A2:Z`, regardless of prior state.

**U-PUB-004: Large-Tab Chunking (Row-Anchored Batch Writes)**
When a tab exceeds 500 rows (VIEW_WRITE_CHUNK_ROWS constant = 500), successive chunks of at most 500 rows are written as separate low-level `update_range` calls, each row-anchored from its calculated start row. A 500-row tab rides one update call; 501 rows splits into two: `A2:Z` (rows 2–501) and `A502:Z` (row 502+). Chunk boundaries are indexed by chunk count: `start_row = DATA_START_ROW + (chunk_index × 500)`.

**U-PUB-005: Cell Value Typing (No Forced String)**
`Cell::Value` cells are written as `userEnteredValue` to allow Sheets to parse and coerce their content (e.g., "20.0000%" strings coerce to numeric fraction 0.20 with percent format). `Cell::Formula` cells are written as `userEnteredValue` with their formula text including the `=` prefix.

**U-PUB-006: Separate Settle Pass (Read After Write)**
Formula cells (including `GOOGLEFINANCE` price columns) recalculate server-side after the write completes. The settle pass reads the Positions tab's Price and Quote Date columns back as a separate `read_price_pass` call only after all `batch_update_view` writes return. With transient prices (`#N/A`/`Loading...`), the settle loop polls up to `max_polls` times (default 8) until all requested symbols are numeric-or-terminally-errored or the window elapses.

**U-PUB-007: Bootstrap Missing Tab**
If the named view tab does not exist on the first republish attempt, the adapter creates the sheet once, writes the frozen header row, then writes the data rows, retrying the data write on success.