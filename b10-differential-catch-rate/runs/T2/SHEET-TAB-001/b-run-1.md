**EARS requirements enforced — published view-tab layout contract**

**Ubiquitous**
- The system shall publish exactly four view tabs, named `POSITIONS_TAB="Positions"`, `OPEN_LOTS_TAB="Open Lots"`, `REALIZED_TAB="Realized"`, `TAX_TAB="Tax"` (`VIEW_TABS`), in that left-to-right order, with Positions the leftmost/landing tab.
- The full workbook tab order (`workbook_tab_order()`, reasserted every republish) shall be: the four view tabs, then `"History"`, then config tabs `"Tax Rules"`, `"Residency"`, `"Platforms & Aliases"` (in that order), then event-log tabs `"Ledger Events"`, `"Tax Events"` last.
- Every view tab shall have exactly one frozen typed header row at row 1; data rows begin at row 2 (`DATA_START_ROW`).
- Every data row shall have exactly as many cells as its tab's header (no ragged rows).
- Positions shall render exactly one row per symbol in `Snapshot.positions`; Open Lots one row per open lot; Realized one row per realized gain; the Tax accrual band one row per accrual — with no blank, label, or embedded-header rows interleaved among data.
- The Tax view's accrual band and its `(Jurisdiction, Tax Year)` reserve summary shall be published as two distinct typed ranges — tabs `"Tax"` and `"Tax · Reserve Summary"` — each under its own header (`TAX_HEADER`, `TAX_RESERVE_HEADER`), never merged; the reserve summary is not a fifth `VIEW_TABS` entry.
- Positions header, exact order (13 cols): Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Realized P&L, Quote Date — where Price, Market Value, Unrealized P&L, Est. Unrealized Tax, Net Unrealized, Unrealized %, and Quote Date are live `GOOGLEFINANCE`-derived formulas and all others are engine-written values.
- The settle-pass read-back shall interpret a Positions data row's column 0 as Symbol and column 4 as Price, with column 12 as the companion Quote Date.

**Event-driven**
- WHEN a view tab is republished, the system shall rewrite only the data range from row 2 downward as one atomic `batchUpdate`, tail-truncating to the new exact row count, and shall never rewrite row 1.
- WHEN a view tab does not yet exist, the system shall create the tab, write its header once, then write the data range (retry-after-create), on both first publish and any later republish that hits a missing tab.

**Unwanted behavior**
- IF `Snapshot.positions` contains two entries for the same symbol, THEN the system shall abort rendering and return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit two rows for one symbol.

Files: `crates/sheets-view/src/lib.rs`, `crates/sheets-view/tests/tabs.rs`, `crates/runtime/src/adapters.rs`, `crates/runtime/tests/cold_start.rs`.