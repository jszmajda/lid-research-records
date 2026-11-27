# View-Tab Cell Rewrite on Republish

**Atomic batchUpdate with tail-truncate** — When republishing a view tab, rewrite the data range (from fixed anchored row 2 beneath the frozen header) as a single atomic `batchUpdate`, then tail-truncate to the exact new row count. No leftover stale rows; no half-written window.

**Frozen header never rewritten** — Row 1 (the typed column header) is written once on tab bootstrap and is never rewritten on republish. A republish that presents a byte-identical header is allowed; a different header is a contract violation. The adapter enforces this with an unconditional panic (no release-stripping) on header mismatch.

**Row anchoring from DATA_START_ROW (2)** — All data rows are written from fixed row 2 downward. The adapter maps logical row indices to A1-reference ranges anchored at row 2: row 0 → A2:Z, row 1 → A3:Z, etc. This anchoring is invariant; the header position is never treated as movable.

**Chunked writes for large tabs** — A tab whose row count exceeds 500 rows (VIEW_WRITE_CHUNK_ROWS constant) is written as sequential chunks of at most 500 rows per `update_range` call, not as one oversized call. Each chunk is row-anchored starting from DATA_START_ROW + (chunk_index × 500). A tab with exactly 500 rows or fewer rides one update call; 501 rows requires two calls (rows 2–501, then rows 502–503); every row across the boundary is written exactly once.

**Cell typing is preserved** — A Cell::Value is written as a Sheets `userEnteredValue` so Sheets parses it the way a human typing the same text would (bare numbers parse as numbers, percent-suffixed text like "20.0000%" parses as numeric fractions). A Cell::Formula is written as a `userEnteredValue` preserving the formula text (including the leading `=`).

**Bootstrap on fresh workbook** — If the tab does not exist, the adapter creates the sheet, writes the header row (A1:Z1) as a one-time write, then writes the data rows. The header write is the one-and-only header write for the tab's lifetime.

**No carry-forward on republish** — Each republish completely replaces the prior data rows. The row count is exact: no append, no merge with prior rows. A symbol that vanishes (sold-out position) leaves no stale row behind.

`VIEW_WRITE_CHUNK_ROWS` = 500.
`DATA_START_ROW` = 2 (row 1-based).

{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key