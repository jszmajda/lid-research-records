**Ubiquitous:**
1. The system shall publish exactly four view tabs, named `"Positions"`, `"Open Lots"`, `"Realized"`, `"Tax"` (constants `POSITIONS_TAB`/`OPEN_LOTS_TAB`/`REALIZED_TAB`/`TAX_TAB`), in that left-to-right order (`VIEW_TABS`), with Positions as the leftmost/landing tab.
2. The system shall reassert the full workbook tab order on every republish: Positions, Open Lots, Realized, Tax, History, "Tax Rules", "Residency", "Platforms & Aliases", "Ledger Events", "Tax Events" — views first, then History, then config tabs, then event logs last, Positions strictly first.
3. The Tax view shall be published as two distinct typed ranges, each with its own frozen header: the accrual band (tab `TAX_TAB`, header `TAX_HEADER`, one row per accrual) and a separate reserve-summary range (name `"Tax · Reserve Summary"`, header `TAX_RESERVE_HEADER`, one row per (jurisdiction, tax-year)). The accrual band shall contain no blank, label, or embedded-header rows.
4. Every published tab shall reserve row 1 for its typed header and begin data at row 2 (`DATA_START_ROW`).
5. Every rendered row shall have exactly as many cells as its tab's header (no ragged rows).
6. Row cardinality is fixed per tab: Positions = one row per symbol in `Snapshot.positions`; Open Lots = one row per open lot; Realized = one row per realized gain; Tax accrual band = one row per accrual.

**Event-driven:**
7. WHEN `batch_update_view` targets a tab that does not yet exist, the system shall create the sheet, write the tab's typed header to row 1 exactly once, then write the data grid beneath it — bootstrap only; no later republish rewrites row 1.
8. WHEN `batch_update_view` targets an existing tab, the system shall overwrite only the data range from row 2 downward as one atomic write and truncate any residual trailing rows to the new row count, leaving row 1 byte-identical to the prior publish.

**Unwanted behavior:**
9. IF `Snapshot.positions` ever contains two entries for the same symbol, THEN `render_positions` shall return `Err(ViewError::DuplicateSymbolRow(symbol))` instead of emitting a second row for that symbol (defensive; structurally unreachable via the current `Map`-keyed snapshot but pinned as a hard error, not a silent skip/merge).
10. IF a human-inserted, sorted, or otherwise externally modified row exists in a tab's data range at republish time, THEN it shall be silently discarded/overwritten by the full data-range rewrite — no merge, no preservation, by design.

Sources: `sheets-view/src/lib.rs` (`VIEW_TABS`, `workbook_tab_order`, `TaxView`, `DATA_START_ROW`, `render_*`, `SheetsViewClient::batch_update_view` doc contract, `ViewError::DuplicateSymbolRow`); `sheets-view/tests/tabs.rs` (all above assertions); `runtime/src/adapters.rs` `ViewSheetsAdapter::batch_update_view` (bootstrap-on-missing-tab, header-once, data-range write).