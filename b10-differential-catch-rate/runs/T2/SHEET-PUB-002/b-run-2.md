**EARS requirements enforced (view-tab republish cell rewrite):**

1. **[Ubiquitous]** A view tab's data range SHALL be exactly `'{tab}'!A{DATA_START_ROW}:Z` with `DATA_START_ROW = 2` — data begins the row directly beneath a single frozen header row (row 1).

2. **[Event-driven]** WHEN a view tab is republished, the system SHALL write `tab.rows` to the data range as ONE atomic `update_range` call; the header row SHALL NOT be included in this write.

3. **[Unwanted behavior]** IF a republish for an already-published tab presents a header differing from the previously-frozen header, THEN this SHALL be treated as a contract violation — the frozen header, once written, is never rewritten.

4. **[Event-driven]** WHEN a republish supplies fewer data rows than the tab currently holds, the system SHALL replace the data wholesale so the tab ends with exactly the new row count — no residual rows from the prior publish survive (tail-truncate).

5. **[Event-driven]** WHEN the target tab does not yet exist, the system SHALL create the sheet, write the typed header to `'{tab}'!A1` as a single row exactly once, then write the data range; any other write failure SHALL NOT trigger tab creation.

6. **[Ubiquitous]** Each cell SHALL be written as its literal text — an engine `Value`'s text as-is, a `Formula`'s `=`-prefixed text as-is — preserving the Value/Formula distinction so live formulas keep recomputing.

7. **[Unwanted behavior]** IF the write call fails for any reason other than a missing tab, THEN `batch_update_view` SHALL return `Err(PublishFailed)` and leave prior published content untouched (no partial write).

8. **[Event-driven]** WHEN a tab's republish fails, the system SHALL mark that tab stale and attempt (best-effort) to write `"STALE — last sync {ts}"` to the fixed banner cell `'{tab}'!AA1`; failure of this banner write SHALL NOT be surfaced as an additional error, and the tab SHALL remain in the stale set for retry on the next sync.

9. **[Event-driven]** WHEN a previously-stale tab's republish subsequently succeeds, its stale flag SHALL be cleared.

10. **[State-driven]** WHILE the advisory write lock is held by another writer, republish SHALL perform no writes to any tab, report `published: false`, and leave the stale set unchanged.

11. **[Ubiquitous]** Republish SHALL acquire the advisory lock exactly once before any tab mutation and release it after, guarding only the write phase (not the subsequent settle read).