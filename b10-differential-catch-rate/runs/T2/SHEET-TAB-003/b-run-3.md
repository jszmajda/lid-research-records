**Concern: what survives vs. is overwritten when a view tab is republished (`ViewSheetsAdapter::batch_update_view`, `sheets_view::Publisher::republish`, `testkit::InMemorySheetsView`).**

1. **Ubiquitous.** The frozen header row (row 1) of a view tab shall be written exactly once, at tab-creation time, and shall never be rewritten by any later republish — the republish path touches only the data range.

2. **Event-driven.** When a view tab does not yet exist at publish time, the system shall: create the sheet; write the header row to `A1` as its one and only header write; then write the data rows. (Same create-on-missing pattern as History and Config tabs.)

3. **Event-driven.** When an existing view tab is republished, the system shall overwrite the entire data range — from row `DATA_START_ROW` (row 2, 1-based, directly beneath the header) through column `Z` — as one atomic write (`update_range`/`batchUpdate`), replacing all data rows wholesale with the newly rendered rows and truncating any residual rows beyond the new row count. Consequently no prior row content in the data range — including a human-inserted, edited, or reordered row — survives a republish; only the header survives.

4. **Unwanted behavior.** The system shall never rewrite an already-published header to match a differing header supplied on a later republish; a republish presenting a header not byte-identical to the tab's recorded header is a contract violation, not a supported update path (enforced unconditionally in the fake via a hard assertion, not a debug-only check).

5. **Event-driven.** When a republish cycle runs, the system shall reassert the full canonical workbook tab order (`workbook_tab_order()`) via `set_tab_order` regardless of whether any individual tab write succeeded; reasserting the same order on successive republishes shall be idempotent (no observable change).

6. **Event-driven.** When a given tab's data write fails, the system shall leave that tab's previously published header and data completely untouched (no partial/half-written state), mark the tab stale, attempt a best-effort single-cell STALE banner write at `AA1` (failure of the banner write is itself ignored), and continue attempting the remaining tabs in the same republish call rather than aborting the whole batch.

7. **State-driven.** While the advisory write-lock cannot be acquired (held elsewhere, or acquisition errors), the system shall write nothing to any tab for that cycle, return a not-published outcome, and leave the existing stale-tab set unchanged — a non-destructive refusal, never a partial or concurrent write.