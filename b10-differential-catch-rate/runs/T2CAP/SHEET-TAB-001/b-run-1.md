SHEET-VIEW-LAYOUT-001 (Ubiquitous) The system shall publish exactly four view tabs, named `"Positions"`, `"Open Lots"`, `"Realized"`, `"Tax"`, in that left-to-right order.

SHEET-VIEW-LAYOUT-002 (Ubiquitous) The system shall maintain a full workbook tab order of: Positions, Open Lots, Realized, Tax, `"History"`, `"Tax Rules"`, `"Residency"`, `"Platforms & Aliases"`, `"Ledger Events"`, `"Tax Events"` — Positions leftmost (landing tab), History among the views after Tax, config tabs next, the two event-log tabs last (Tax Events final).

SHEET-VIEW-LAYOUT-003 (Event-driven) When a republish completes, the system shall reassert that full tab order; repeated republishes shall leave the order identical (idempotent).

SHEET-VIEW-LAYOUT-004 (Ubiquitous) Each tab shall carry a typed header row at row 1 with exactly these columns, in order:
- Positions: Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Realized P&L, Quote Date (columns A–M).
- Open Lots: Lot ID, Symbol, Acquire Date, Source, Shares, Total Basis, Basis/Share, Platform, Tracking Code, Term.
- Realized: Sale ID, Lot ID, Symbol, Sale Date, Proceeds, Basis, Gain, Holding Days, Term, State, Tax Year.
- Tax (accrual band): Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State.
- Tax reserve summary, a distinct band named `"Tax · Reserve Summary"` (not a fifth view tab): Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall.

SHEET-VIEW-LAYOUT-005 (Ubiquitous) The header shall be frozen: written once when the tab is bootstrapped and never rewritten on republish; data rows shall begin at the fixed anchored row `DATA_START_ROW = 2` (range `'Tab'!A2:Z`).

SHEET-VIEW-LAYOUT-006 (Ubiquitous) Each band shall hold exactly one row per entity — per position symbol, per open lot, per realized gain, per accrual, per (Jurisdiction, Tax Year) — with row width exactly equal to its header width (no ragged rows), and no among-data summary rows: no blank/separator row, no label row (e.g. `"RESERVE SUMMARY"`), no embedded second header inside another band, so every band is natively filterable/sortable end to end.

SHEET-VIEW-LAYOUT-007 (Event-driven) When republishing a tab, the system shall rewrite the whole data range as one atomic batch update and truncate the residual tail to the exact row count, so leftover stale rows and human-inserted/sorted rows are removed.

SHEET-VIEW-LAYOUT-008 (Unwanted) If the published tab does not yet exist (Sheets 400 `Unable to parse range`), the system shall create the sheet, write its typed header once, then retry the data write; if any of these fail, it shall return `PublishFailed`, flag the tab stale, write a best-effort banner `"STALE — last sync {ts}"` at `AA1`, and retry next sync.

SHEET-VIEW-LAYOUT-009 (Unwanted) If two Positions rows carry the same symbol, the system shall reject rendering with `DuplicateSymbolRow(symbol)` — the read-back keys row identity on column 0 (Symbol), Price at column index 4, Quote Date at column index 12.

SHEET-VIEW-LAYOUT-010 (Ubiquitous) Each cell shall be typed either engine Value or live Formula; view tabs shall be written `USER_ENTERED` so values coerce numerically (e.g. `"20.0000%"` → 0.20) and formulas evaluate.