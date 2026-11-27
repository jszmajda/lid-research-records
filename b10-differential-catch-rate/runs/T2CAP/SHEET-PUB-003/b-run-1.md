SHEET-PUB-010 (event-driven) WHEN a view tab's `batch_update_view` returns Err during republish, the system SHALL leave that tab's workbook content unchanged (nothing partially lands), record the tab name in the publisher's stale set, and continue republishing the remaining tabs in the supplied order.

SHEET-PUB-011 (event-driven) WHEN a tab is flagged stale by a failed publish, the system SHALL attempt one best-effort in-tab banner write to that tab with the exact text `STALE — last sync {stale_banner_quote_ts}`, where the timestamp is the caller-supplied string, written to cell `AA1` of the tab.

SHEET-PUB-012 (unwanted-behavior) IF the best-effort banner write itself fails, THEN the system SHALL ignore that error — the tab remains flagged stale, the republish outcome is unaffected, no banner exists, and the TUI remains the staleness surface.

SHEET-PUB-013 (event-driven) WHEN `batch_update_view` succeeds for a tab, the system SHALL remove that tab from the stale set (a stale flag clears only on a subsequent successful publish of that same tab).

SHEET-PUB-014 (state-driven) WHILE any tab is flagged stale, the flag SHALL persist across republish cycles and the tab SHALL be retried on the next sync.

SHEET-PUB-015 (ubiquitous) The republish outcome SHALL report `published = true` only if every supplied tab published AND the tab-order reassert succeeded; `stale_tabs` SHALL be the full current stale set, deduplicated and in ascending name order (not only this cycle's failures).

SHEET-PUB-016 (unwanted-behavior) IF the tab-order reassert (`set_tab_order`) fails, THEN `published` SHALL be false, but no tab SHALL be flagged stale and no banner SHALL be written; the reassert is retried next sync.

SHEET-PUB-017 (unwanted-behavior) IF the advisory write-lock cannot be acquired (held by another Sheets-mutating primitive, or an acquisition I/O error), THEN republish SHALL write nothing this cycle — no tab write, no banner, no stale-set change — and return `published = false` with the current stale set. The lock is acquired before any workbook mutation and released on scope exit.

SHEET-PUB-018 (ubiquitous) A failed republish SHALL never modify canonical truth (the append-only event log) and SHALL never rewrite a tab's frozen header row; only the data range from `DATA_START_ROW` (= 2) down is rewritten and tail-truncated.

SHEET-PUB-019 (ubiquitous) Every underlying Sheets transport error crossing this seam SHALL surface as `ViewError::PublishFailed`. A missing tab is not a failure: the client SHALL create the sheet, write the header once at `A1`, and retry the data write; failure of any of those steps SHALL surface as `PublishFailed`.

SHEET-PUB-020 (event-driven) WHEN republish fails within `republish_then_settle`, the settle pass SHALL still run after the write half returns, and the failed outcome SHALL be returned alongside the produced marks; only a settle-read error aborts the cycle with `Err`.