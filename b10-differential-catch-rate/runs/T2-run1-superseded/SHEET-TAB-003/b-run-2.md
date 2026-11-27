**EARS reconstruction — view-tab republish: what survives vs. what is overwritten**

**Ubiquitous**
- The system SHALL treat each view tab as split into a frozen header (row 1) and a data range beginning at the fixed anchored row `DATA_START_ROW = 2` (`A2:Z`); the header SHALL be written exactly once, at tab creation, and SHALL NEVER be rewritten by any subsequent republish.
- On every republish of an existing tab, the system SHALL replace the entire data range wholesale with the newly rendered rows and truncate any residual tail beyond the new row count — so a human edit made directly in the sheet (a manually inserted row, a re-sort, an edited cell) within the data range does NOT survive a republish; it is unconditionally overwritten. Only the header content is preserved.

**Event-driven**
- WHEN a republish targets a tab that already exists, the system SHALL write only `'{tab}'!A{DATA_START_ROW}:Z` and SHALL NOT touch row 1.
- WHEN a republish targets a tab that does not yet exist (a missing-tab error), the system SHALL create the sheet, write `tab.header` to `'{tab}'!A1` (the one and only header write for that tab's lifetime), then write the data range.
- WHEN a per-tab `batchUpdate` fails for any other reason, the system SHALL leave that tab's existing published content untouched, add the tab name to the stale set (retried next sync), and best-effort write a `"STALE — last sync {ts}"` banner to `'{tab}'!AA1`; a banner-write failure SHALL NOT be propagated or block other tabs.
- WHEN the advisory write-lock cannot be acquired, the system SHALL write nothing for any tab that cycle, return `published: false`, and leave the stale set unchanged.

**State-driven**
- WHILE republishing a batch of tabs, a failure on one tab SHALL NOT roll back or block the successful (already-committed) publish of other tabs in the same call; a tab whose republish succeeds SHALL be removed from the stale set even if sibling tabs failed.

**Unwanted behavior**
- IF a republish call for an already-existing tab presents a header differing from what is currently stored, THEN this is a contract violation — the reference test double enforces it unconditionally (`assert_eq!`, panics in any build, not release-stripped) rather than silently accepting the change. The header presented on every republish of a given tab MUST be byte-identical to the one first written.

Files: `crates/runtime/src/adapters.rs`, `crates/sheets-view/src/lib.rs`, `crates/sheets-view/src/testkit.rs`, `crates/sheets-view/tests/tabs.rs`.