**Concern: what survives / is overwritten on view-tab republish**

Ubiquitous: The typed header row (row 1) of a view tab SHALL be written exactly once, at tab creation, and SHALL NOT be rewritten by any subsequent republish. A republish call MUST present a header byte-identical to the one at creation (enforced unconditionally, not release-stripped: the test fake panics on mismatch in any build).

Event-driven: WHEN a view tab is republished, the system SHALL rewrite the entire data range from the fixed anchored row `DATA_START_ROW = 2` (beneath the frozen header) as ONE atomic `update_range`/`batchUpdate`, replacing the previously published rows wholesale.

Event-driven: WHEN the newly rendered row count is smaller than the previously published count, the system SHALL tail-truncate the residual rows to the exact new count — no leftover stale rows beyond the new data.

Unwanted-behavior: The system SHALL NOT preserve any human-made edit, insertion, or re-sort of rows inside the data range across a republish — the data range is fully regenerated from the kernel snapshot each cycle, not merged with prior sheet state; a human-inserted row is overwritten by design.

State-driven: IF the target view tab does not yet exist, THEN republish SHALL create the tab, write the typed header once (the tab's only header write), then write the data range — never treated as an error.

Event-driven: WHEN `batch_update_view` fails for a reason other than a missing tab, THEN the tab SHALL be left exactly as it was after its last successful publish (no partial/half-written state), the tab SHALL be flagged stale, and a best-effort single-cell STALE banner SHALL be written to a fixed anchor outside the data range (column `AA`, row 1) carrying the last-sync timestamp; failure of the banner write itself is not escalated.

Event-driven: WHEN a republish cycle runs, the system SHALL reassert the full workbook tab order (`workbook_tab_order()`) idempotently, regardless of per-tab publish outcome — repeated calls yield the identical order.

State-driven: WHILE the advisory write-lock is held by another writer (or acquisition errors), republish SHALL write nothing to any tab and SHALL return `published: false` with the stale set unchanged — a non-destructive refusal, never a partial write.

Event-driven: WHEN `republish_then_settle` runs, the settle-pass price read SHALL occur only after the republish write returns, on the same thread of control — never inline or concurrent with the formula write.

Ubiquitous: Cell values and live `GOOGLEFINANCE` formulas alike are reconstructed fresh each republish from the current render, not carried over from the prior published state.