**VIEW-TAB-REWRITE** — Republish cell rewrite for view tabs

A view tab's cells are rewritten on republish (full-tab atomic `batchUpdate` + tail-truncate) as follows:

**Frozen header (never rewritten).** Row 1 (the typed column header) is written **once** on initial tab creation and is **never rewritten** on any subsequent republish. A republish attempt that presents a different header row raises a logic error (defensive assertion); the data range is rewritten + tail-truncated beneath the frozen row.

**Data range anchoring.** All data rows are written from the fixed anchored start row `DATA_START_ROW = 2`, beneath the frozen header. The A1 write range for a tab named `{name}` is `'{name}'!A2:Z`. Subsequent republishes use the identical anchored range.

**Cell text projection.** Each cell is written as its `text()` output: a `Cell::Value` projects to a Sheets `userEnteredValue` (parsed as a number if text is numeric, percent-suffixed string as a numeric fraction for rate columns); a `Cell::Formula` projects to `userEnteredValue` with formula syntax (`=…`). Both are written as user-entered, never forced-string.

**Chunked writes (large tabs).** Data rows exceeding 500 rows are written in successive chunks of maximum 500 rows each, not one oversized `update_range` call. Each chunk is anchored at its starting row (chunk 0 at row 2, chunk 1 at row 502, …) with range `'{name}'!A{start_row}:Z`. Chunks are issued sequentially in order; row identity is preserved across chunk boundaries.

**Tail truncation (atomicity).** A republish writes the new data rows in full (via chunked `update_range` calls), replacing the prior rows wholesale. The tab's row count afterward is **exactly** the count of republished rows; any residual stale rows from the prior republic are truncated away. This is atomic per tab: no half-written or intermediate-count window.

**Constant: `VIEW_WRITE_CHUNK_ROWS = 500`.** A single `update_range` call carries at most 500 data rows; above that, multiple calls are issued.

**Error: missing tab on initial publish.** If the tab does not exist on first write attempt, the adapter catches the missing-tab error, creates the sheet via `ensure_sheet`, writes the frozen header via a single `update_range` to row 1, then retries the data write. Subsequent republishes assume the tab exists.