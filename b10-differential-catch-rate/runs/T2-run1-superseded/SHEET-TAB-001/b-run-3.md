**EARS requirements enforced — published view-tab layout contract**

1. **Ubiquitous:** The system shall publish exactly four view tabs — `Positions`, `Open Lots`, `Realized`, `Tax` (`VIEW_TABS`) — in that left-to-right order, with `Positions` as the leftmost/landing tab.

2. **Ubiquitous:** Each tab's row 1 shall carry a frozen typed header matching its schema constant exactly: `POSITIONS_HEADER` (13 columns: Symbol…Quote Date), `OPEN_LOTS_HEADER` (10), `REALIZED_HEADER` (11), `TAX_HEADER` (6), `TAX_RESERVE_HEADER` (7). Data rows begin at row 2 (`DATA_START_ROW = 2`).

3. **Ubiquitous:** Every emitted row shall have a cell count exactly equal to its tab's header width (no ragged rows).

4. **Ubiquitous:** The Tax view shall render as two distinct typed bands, each its own named range with its own frozen header — the accrual band (tab `Tax`, one row per accrual under `TAX_HEADER`, containing no blank row, no `"RESERVE SUMMARY"` label row, and no row equal to `TAX_RESERVE_HEADER`) and the reserve-summary band (`Tax · Reserve Summary`, one row per `(Jurisdiction, Tax Year)` under `TAX_RESERVE_HEADER`) — never stacked/embedded together.

5. **Unwanted behavior:** IF `Snapshot.positions` carries two entries for the same symbol, THEN `render_positions` shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit two rows for one symbol.

6. **Event-driven:** WHEN `batch_update_view` is invoked on an existing tab, the system shall rewrite only the data range from row 2 downward (`'{name}'!A2:Z`) as one atomic write and tail-truncate any residual rows to the new row count; row 1 shall never be rewritten by republish, even when row count shrinks.

7. **Event-driven:** WHEN `batch_update_view` (or the History/Positions read-back) targets a tab that does not yet exist, the system shall create the tab (`ensure_sheet`), write the header to row 1 exactly once, then write the data range — a missing tab is a fresh-workbook cold start, not an error; `read_price_pass` on a missing Positions tab returns an empty pass, not an error.

8. **Ubiquitous:** The full workbook tab order shall be: the four view tabs, then `History`, then `Tax Rules`, `Residency`, `Platforms & Aliases`, then `Ledger Events`, `Tax Events` last — reasserted on every republish cycle (idempotent; a metadata-only operation, not a values-grid write).

9. **Ubiquitous:** In the Positions row layout, 0-based column index 4 is `Price` and column index 12 is `Quote Date`, per `POSITIONS_HEADER` order — the fixed positions the marks settle-pass read-back parses.

Files: `crates/sheets-view/src/lib.rs`, `crates/sheets-view/tests/tabs.rs`, `crates/runtime/src/adapters.rs`, `crates/runtime/src/sheets.rs`, `crates/runtime/tests/cold_start.rs`.