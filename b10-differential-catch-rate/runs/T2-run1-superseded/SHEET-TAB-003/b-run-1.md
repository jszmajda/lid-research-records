```
SHEET-VIEW-PUB-01 (Ubiquitous): The frozen header row (row 1) of a published view tab shall remain byte-identical across every subsequent republish; only the data range from DATA_START_ROW (row 2, i.e. "'{tab}'!A2:Z") downward is ever rewritten by a republish.

SHEET-VIEW-PUB-02 (Ubiquitous): A view tab's header shall be written exactly once — only when the tab is created for the first time — and never rewritten thereafter.

SHEET-VIEW-PUB-03 (Event-driven): WHEN a view tab is republished, the system shall replace the tab's entire data range as one atomic write (wholesale replacement), so any row a human inserted, edited, sorted, or reordered inside that range is discarded/overwritten — republish never merges with or preserves prior data-range content.

SHEET-VIEW-PUB-04 (Event-driven): WHEN a republish writes N data rows and N is fewer than the tab's previously published row count, the system shall tail-truncate the residual rows so nothing beyond the new Nth row survives from the prior publish (no leftover stale rows).

SHEET-VIEW-PUB-05 (Event-driven): WHEN batch_update_view targets a tab name that does not yet exist (a missing-tab error), the system shall create the sheet, write the header to row 1 exactly once, then write the data range — this is the only path by which the header is ever written.

SHEET-VIEW-PUB-06 (Event-driven): WHEN a tab's batch_update_view call fails for a reason other than missing-tab, the system shall leave that tab's previously published header and data unmodified, record the tab as stale, and attempt a best-effort write of a "STALE — last sync {ts}" banner to that tab's AA1 cell; failure of the banner write itself is swallowed and does not fail the cycle.

SHEET-VIEW-PUB-07 (Event-driven): WHEN republish cannot acquire the workbook write lock, the system shall perform zero writes that cycle, return published=false, and leave the existing stale-tab set and all tab content unchanged.

SHEET-VIEW-PUB-08 (Event-driven): WHEN every per-tab write in a republish cycle has completed (regardless of individual success/failure), the system shall reassert the full workbook tab order via set_tab_order.

SHEET-VIEW-PUB-09 (State-driven): WHILE a republish cycle's settle-pass price read executes, it shall run strictly after, and never concurrently with or inline with, that cycle's data-range write, so it cannot observe a mid-rewrite/recalculating cell.

SHEET-VIEW-PUB-10 (Unwanted behavior): IF a republish presents a header differing from the header already stored for that tab, THEN this is a contract violation and must not be silently accepted as a header change (enforced unconditionally, all builds, via hard assertion in the reference in-memory implementation).

SHEET-VIEW-PUB-11 (Unwanted behavior): IF the Positions tab does not exist when the settle pass reads it, THEN read_price_pass shall return an empty pass, not an error.
```

Source files (read only, per instructions):
`{scratch}/audit-baseline/crates/runtime/src/adapters.rs`
`{scratch}/audit-baseline/crates/sheets-view/src/lib.rs`
`{scratch}/audit-baseline/crates/sheets-view/src/testkit.rs`
`{scratch}/audit-baseline/crates/sheets-view/tests/tabs.rs`