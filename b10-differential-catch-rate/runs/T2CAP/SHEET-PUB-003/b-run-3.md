SHEET-PUB-R01 (event-driven) — WHEN a view tab's `batch_update_view` returns an error during a republish cycle, the system SHALL leave that tab's published contents unchanged (nothing lands; the canonical event log is untouched), add the tab's name to the persistent stale set, and continue attempting the remaining tabs in the same cycle.

SHEET-PUB-R02 (event-driven) — WHEN a tab's publish fails, the system SHALL attempt one best-effort in-tab banner write to that tab with the exact text `STALE — last sync {ts}`, where `{ts}` is the caller-supplied `stale_banner_quote_ts` string, written verbatim to the tab's banner anchor cell `'{tab}'!AA1`.

SHEET-PUB-R03 (unwanted behavior) — IF the best-effort stale-banner write also fails, THEN the system SHALL ignore that error, keep the tab flagged stale across the cycle, and leave the TUI as the staleness surface (no banner cell is written).

SHEET-PUB-R04 (event-driven) — WHEN a previously-stale tab publishes successfully on a later cycle, the system SHALL remove it from the stale set; a failed tab is retried on every subsequent republish with no backoff or attempt cap.

SHEET-PUB-R05 (ubiquitous) — Each republish SHALL return `RepublishOutcome { published, stale_tabs }` where `published` is true only if every tab's `batch_update_view` AND the tab-order reassert succeeded, and `stale_tabs` is the current stale set in sorted, de-duplicated order.

SHEET-PUB-R06 (unwanted behavior) — IF the workbook tab-order reassert (`set_tab_order`) fails, THEN the system SHALL set `published: false` but SHALL NOT flag any tab stale and SHALL NOT write a banner; the ordering is retried next sync.

SHEET-PUB-R07 (state-driven) — WHILE the runtime advisory write-lock is held by another writer (or acquisition errors), a republish SHALL write nothing at all — no tab write, no banner, no order reassert — and SHALL return `published: false` with the stale set unchanged. The lock is acquired exactly once, before any workbook mutation, and released on cycle exit.

SHEET-PUB-R08 (event-driven) — WHEN a republish fails, `republish_then_settle` SHALL still run the settle pass after the writes and return the failed outcome alongside the marks; only a settle-read transport error SHALL abort the cycle with `Err`, producing no `MarksProduced`.

SHEET-PUB-R09 (ubiquitous) — Every underlying Sheets error at the seam (view write, price read, banner write) SHALL surface as `ViewError::PublishFailed`. A missing tab SHALL NOT count as a failure: the adapter creates the sheet, writes the frozen header once at `'{tab}'!A1`, then retries the data write (from `DATA_START_ROW` = 2); only if creation, header, or retry fails is `PublishFailed` returned. A missing Positions tab on a settle read SHALL yield an empty pass, not an error.