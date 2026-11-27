SHEET-PUB-F01 (Unwanted behavior) — IF the workbook `batchUpdate` for a view tab fails, THEN the republish driver SHALL leave that tab's existing contents untouched (nothing lands, no partial/half-written rows), add the tab's name to the persistent stale set, and continue republishing the remaining tabs in the supplied order rather than aborting the cycle.

SHEET-PUB-F02 (Event-driven) — WHEN a tab's `batchUpdate` fails, the driver SHALL attempt exactly one best-effort in-tab banner write to that tab with the literal text `STALE — last sync {stale_banner_quote_ts}` (caller-supplied timestamp string, inserted verbatim), targeting the tab's banner anchor cell `'{tab}'!AA1`.

SHEET-PUB-F03 (Unwanted behavior) — IF the best-effort banner write itself fails, THEN the driver SHALL discard that error (never propagate or retry it), leaving the tab flagged stale with no banner, so the TUI remains the staleness surface.

SHEET-PUB-F04 (Ubiquitous) — The republish SHALL return `RepublishOutcome { published, stale_tabs }`, where `published` is true only if every tab's `batchUpdate` AND the workbook tab-order reassert succeeded, and `stale_tabs` is the driver's full current stale set, deduplicated and lexicographically ordered (all tabs stale from earlier cycles included, not just this cycle's).

SHEET-PUB-F05 (Unwanted behavior) — IF the tab-order reassert fails, THEN `published` SHALL be false, but no tab SHALL be flagged stale and no banner written for it; the ordering is retried next sync.

SHEET-PUB-F06 (State-driven) — WHILE a tab is flagged stale, each subsequent republish SHALL retry it; on a successful `batchUpdate` the tab's stale flag SHALL be cleared and it SHALL be absent from subsequent `stale_tabs`.

SHEET-PUB-F07 (Unwanted behavior) — IF the runtime advisory write-lock cannot be acquired (held by another Sheets-mutating primitive, or an acquisition I/O error), THEN republish SHALL write nothing at all this cycle — no tab write, no banner, no order reassert, no change to the stale set — and return `published: false` with the current stale set. The lock SHALL be acquired exactly once per republish, before any workbook mutation, and released on exit.

SHEET-PUB-F08 (Ubiquitous) — A failed republish SHALL never affect the canonical event log; the failure surfaces solely as `ViewError::PublishFailed`, meaning the view is left internally consistent with the prior snapshot, just behind.

SHEET-PUB-F09 (Event-driven) — WHEN the low-level Sheets primitive reports any error on a view-tab write, order set, price read-back, or banner write, the adapter SHALL map it to `ViewError::PublishFailed`. WHEN the error is specifically "tab missing", the adapter SHALL instead create the sheet, write the segment-supplied frozen header at `'{tab}'!A1`, and retry the data write once; any failure in that sequence SHALL yield `PublishFailed`. A missing Positions tab on read-back SHALL yield an empty `PricePass`, not an error.

SHEET-PUB-F10 (Event-driven) — WHEN a cycle republishes then settles, the settle pass SHALL run after the republish returns regardless of the republish outcome; a settle-pass transport error SHALL propagate as `Err(PublishFailed)` for the whole cycle, discarding the `RepublishOutcome` and producing no marks.