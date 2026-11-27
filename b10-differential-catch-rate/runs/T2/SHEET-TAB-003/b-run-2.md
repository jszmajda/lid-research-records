**Reconstructed EARS requirements — "what survives / is overwritten on view-tab republish" (sheets-view crate)**

**Ubiquitous**
- The system shall write a view tab's frozen header (row 1) exactly once, at tab bootstrap; every subsequent republish shall write only the data range from `DATA_START_ROW` (row 2) downward, leaving the header row byte-identical and untouched.
- Each republish shall wholesale-replace the tab's data rows with the newly rendered set in one atomic write, tail-truncating any previously-published rows beyond the new row count — rows a human inserted, edited, sorted, or filtered within the data range are discarded, never merged or preserved.
- On every republish cycle the system shall reassert the full ten-tab workbook order — Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events (Positions always leftmost/landing) — superseding any manual tab reordering the owner applied.
- The header supplied to a republish of an existing tab shall be byte-identical to the header that tab was created with; a differing header is a contract violation (the reference fake enforces this unconditionally, in all builds, via a hard assertion, not a soft/recoverable error).

**Event-driven**
- WHEN a view tab does not yet exist, THE republish path shall create the sheet, write the header once, then write the data range as a separate subsequent call.
- WHEN a tab's write fails, THE system shall leave that tab's previously-published header and data unchanged, add the tab to the stale set, and attempt a best-effort `STALE — last sync {timestamp}` banner write at cell `AA1` (a banner-write failure is swallowed).
- WHEN a previously-stale tab's write later succeeds, THE system shall remove it from the stale set.
- WHEN a republish-then-settle cycle runs, THE settle-pass price read shall occur only after all tab writes return — never concurrently with or inline inside a write.

**State-driven**
- WHILE one tab's write fails within a multi-tab republish, other tabs' writes shall proceed independently (per-tab failure isolation; no rollback of tabs already written).

**Unwanted-behavior**
- IF the advisory write-lock cannot be acquired, THEN republish shall write nothing that cycle and return `published=false` with the stale set unchanged from before the attempt (no partial/concurrent write).
- IF the tab-order reassert (`set_tab_order`) fails, THEN the cycle's outcome is `published=false` even though tabs already successfully rewritten remain published (no rollback of prior writes).

Source files: `runtime/src/adapters.rs`, `sheets-view/src/lib.rs`, `sheets-view/src/testkit.rs`, `sheets-view/tests/tabs.rs`.