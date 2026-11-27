**EARS requirements — view-tab layout contract (sheets-view)**

1. *Ubiquitous:* The system shall publish exactly four view tabs, named "Positions", "Open Lots", "Realized", "Tax", in that left-to-right order (`VIEW_TABS`), with "Positions" as the leftmost/landing tab.

2. *Ubiquitous:* The full workbook tab order shall be: Positions, Open Lots, Realized, Tax, then "History", then "Tax Rules", "Residency", "Platforms & Aliases" (in that order), then "Ledger Events", "Tax Events" last (`workbook_tab_order`).

3. *Ubiquitous:* On every view tab, row 1 shall be the frozen typed header; data rows shall begin at row 2 (`DATA_START_ROW = 2`).

4. *Event-driven:* WHEN a view tab is republished, the system shall overwrite only the data range from row 2 downward as one atomic write and truncate any residual trailing rows to the new row count, and shall never rewrite row 1 — even when the new data is narrower/shorter than before (a manually inserted/sorted row is silently overwritten by design).

5. *State-driven:* IF a named view tab does not yet exist (fresh workbook), THEN the first republish shall create the tab (grid sized 40 columns), write the header row once at A1, then write the data range beneath it. IF the Positions tab does not exist when a settle-pass price read is attempted, THEN the read shall return an empty price-pass rather than an error.

6. *Ubiquitous:* Every published row shall contain exactly as many cells as its tab's header (no ragged rows): one row per Position / Open Lot / Realized Gain / Tax Accrual / Reserve-Summary entity — never an among-data blank, label, or embedded-header row.

7. *Ubiquitous:* The Tax surface shall separate two independently-headed ranges: the "Tax" accrual band — header `[Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State]`, one row per accrual — and the distinct "Tax · Reserve Summary" range — header `[Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall]`, one row per (Jurisdiction, Tax Year) — never merged into one range.

8. *Unwanted behavior:* IF `Snapshot.positions` ever carries two entries for the same symbol, THEN `render_positions` shall abort and return `Err(DuplicateSymbolRow(symbol))` rather than emit two rows for one symbol.

9. Fixed header contracts: Positions (13 cols) = `Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Realized P&L, Quote Date`; Open Lots (10 cols) = `Lot ID, Symbol, Acquire Date, Source, Shares, Total Basis, Basis/Share, Platform, Tracking Code, Term`; Realized (11 cols) = `Sale ID, Lot ID, Symbol, Sale Date, Proceeds, Basis, Gain, Holding Days, Term, State, Tax Year`.

10. *Event-driven:* WHEN republish runs, the system shall reassert the full workbook tab order every cycle, idempotently (repeated republish yields the same order); a tab-order write failure marks the cycle not-fully-published without corrupting data already written.