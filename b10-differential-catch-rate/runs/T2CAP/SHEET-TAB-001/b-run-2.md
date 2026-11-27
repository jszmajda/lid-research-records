SHEET-VIEW-LAYOUT — Published view-tab layout contract

**Ubiquitous**
- SHEET-LAY-001: The system shall publish exactly four view tabs, named `Positions`, `Open Lots`, `Realized`, `Tax`, in that left-to-right order.
- SHEET-LAY-002: The Tax surface shall carry a second, distinct typed band named `Tax · Reserve Summary`, with its own frozen header — not a fifth view tab.
- SHEET-LAY-003: The workbook tab order shall be `Positions`, `Open Lots`, `Realized`, `Tax`, `History`, `Tax Rules`, `Residency`, `Platforms & Aliases`, `Ledger Events`, `Tax Events`; `Positions` shall be the leftmost (landing) tab and the two event-log tabs the final two.
- SHEET-LAY-004: Each tab's row 1 shall be its frozen typed header, and data rows shall begin at row 2 (`DATA_START_ROW`).
- SHEET-LAY-005: Headers shall be exactly — Positions: Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Realized P&L, Quote Date (columns A–M). Open Lots: Lot ID, Symbol, Acquire Date, Source, Shares, Total Basis, Basis/Share, Platform, Tracking Code, Term. Realized: Sale ID, Lot ID, Symbol, Sale Date, Proceeds, Basis, Gain, Holding Days, Term, State, Tax Year. Tax accruals: Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State. Reserve summary: Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall.
- SHEET-LAY-006: Every band shall be one row per entity — Positions one per position symbol, Open Lots one per open lot, Realized one per realized gain, accruals one per accrual, reserve summary one per (Jurisdiction, Tax Year) — with each row exactly as wide as its header (no ragged rows).
- SHEET-LAY-007: Positions column E shall be the `GOOGLEFINANCE` price formula and column M its quote-date companion; the settle read-back shall key rows by symbol in column A, price at column index 4 and quote date at column index 12.

**Event-driven**
- SHEET-LAY-008: When a view tab is republished, the system shall rewrite only the data range from row 2 down as one atomic update, truncate the residual tail to the exact row count (human-inserted/sorted rows are overwritten), and leave the frozen header byte-identical — never rewritten.
- SHEET-LAY-009: When a view tab does not yet exist, the system shall create it, write its typed header once to row 1, then write the data range.
- SHEET-LAY-010: When republish runs, the system shall idempotently reassert the full workbook tab order; repeated republishes shall leave the order identical.

**Unwanted behavior**
- SHEET-LAY-011: The system shall not emit blank, label (e.g. `RESERVE SUMMARY`), or embedded-header rows inside any band; every band row's first cell shall be non-empty so native filtering/sorting works end to end.
- SHEET-LAY-012: If two rows are rendered for one symbol on Positions, the system shall fail loudly with `DuplicateSymbolRow(symbol)` and publish nothing.
- SHEET-LAY-013: If a tab's write fails, the system shall flag that tab stale, best-effort write an in-tab banner `STALE — last sync {timestamp}`, report `published: false`, leave the tab as-is, and retry next sync; a failed tab-order reassert shall likewise report `published: false`.