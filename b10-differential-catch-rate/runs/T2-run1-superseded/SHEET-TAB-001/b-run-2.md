**Layout-contract requirements enforced by this code (view-tab publishing):**

**Ubiquitous:**
- The system shall publish exactly four view tabs — Positions, Open Lots, Realized, Tax (`VIEW_TABS`, len 4) — in that fixed left-to-right order, with Positions as the leftmost/landing tab.
- Each tab shall carry a fixed named header: Positions = [Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Realized P&L, Quote Date] — Price at column index 4, Quote Date at column index 12 (pinned by the settle-pass reader); Open Lots = [Lot ID, Symbol, Acquire Date, Source, Shares, Total Basis, Basis/Share, Platform, Tracking Code, Term]; Realized = [Sale ID, Lot ID, Symbol, Sale Date, Proceeds, Basis, Gain, Holding Days, Term, State, Tax Year]; Tax accrual band = [Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State]; Tax reserve-summary = [Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall], published as its own distinctly-named tab ("Tax · Reserve Summary"), never as rows embedded in the accrual tab — no blank, label, or embedded-second-header rows inside the accrual range.
- Row 1 of every tab is the frozen header; data rows begin at row 2 (`DATA_START_ROW`); every row is exactly as wide as its tab's header (no ragged rows).
- Exactly one row per entity: one per position symbol, one per open lot, one per realized gain, one per accrual, one per (jurisdiction, tax-year) reserve pair.
- Full workbook tab order: Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events.

**Event-driven:**
- WHEN a republish runs, the system shall rewrite each tab's data range (`'{name}'!A2:Z`) as one atomic `update_range` that tail-truncates to the exact new row count, and shall never rewrite row 1.
- WHEN republish targets a tab absent from the workbook, the system shall create the tab, write its header once to row 1 (`'{name}'!A1`), then write the data range.
- WHEN a republish cycle completes, the system shall reassert `workbook_tab_order()` idempotently (identical order after repeated republishes).
- WHEN writing a Value cell, it is written as Sheets `userEnteredValue` (never forced string), so a bare number parses numeric and a percent-suffixed string (e.g. "20.0000%") parses as the numeric fraction with percent format; a Formula cell is written as a `userEnteredValue` formula.

**Unwanted behavior:**
- IF `Snapshot.positions` yields two rows for one symbol, THEN `render_positions` shall return `Err(DuplicateSymbolRow(symbol))` rather than emit duplicate rows (defensive, structurally unreachable via the real `Map` source but must error loudly if triggered).
- IF a tab's `batch_update_view` fails, THEN that tab is left unchanged, flagged stale, a best-effort STALE banner is written, republish continues to remaining tabs, and the outcome reports `published: false` with the current stale set.