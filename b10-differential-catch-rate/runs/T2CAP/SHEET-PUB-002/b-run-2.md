U-PUB-002 — View-tab republish: cell rewrite semantics

**R1 (ubiquitous).** The system shall publish each view tab as a full-tab rewrite of the data range only: data rows shall be written from the fixed anchored start row `DATA_START_ROW = 2` (1-based), leaving row 1 (the typed header) untouched.

**R2 (ubiquitous).** The frozen header shall be written exactly once — when the tab is created — and shall never be rewritten on republish. Every republish of an existing tab shall present a header byte-identical to the stored one; a differing header is a contract violation and shall abort loudly (unconditional assertion, not release-stripped).

**R3 (event-driven).** When a tab is republished, the system shall replace the tab's data rows wholesale and truncate the residual tail to exactly the new row count — never append, never leave leftover rows from a longer prior publish (e.g. 3 rows then 1 row ⇒ exactly 1 row remains), and never expose a half-written window.

**R4 (ubiquitous).** Each cell shall be written as its raw text: `Cell::Value` text, or `Cell::Formula` text including its leading `=`. Both shall be written as Sheets `userEnteredValue` (never forced `stringValue`), so a bare number parses as a number and a percent-suffixed value such as `"20.0000%"` coerces to the numeric fraction `0.20` that the live post-tax formulas multiply.

**R5 (state-driven).** While a tab's row count exceeds `VIEW_WRITE_CHUNK_ROWS = 500`, the data write shall be issued as successive row-anchored chunks of at most 500 rows, chunk *i* anchored at range `'{tab}'!A{2 + i*500}:Z`, written in order so each chunk continues exactly where the previous ended. A tab of exactly 500 rows shall ride one write; 501 rows shall ride two, with the 501st row landing at the chunk boundary. An empty row set shall still issue one write of `'{tab}'!A2:Z` (clearing the range).

**R6 (event-driven).** When the data write reports a missing tab, the system shall create the sheet, write the tab's frozen header to `'{tab}'!A1` (the only header write), then retry the data write.

**R7 (unwanted behavior).** If any underlying write fails (including sheet creation, header bootstrap, or retry), the system shall return `ViewError::PublishFailed`, leave the tab as-is (nothing lands, canonical log unaffected), flag the tab stale, and write a best-effort banner `"STALE — last sync {ts}"`; a banner-write failure shall be ignored while the stale flag persists.

**R8 (unwanted behavior).** If the advisory write-lock cannot be acquired, republish shall write nothing, return `published: false`, and leave the stale set unchanged.