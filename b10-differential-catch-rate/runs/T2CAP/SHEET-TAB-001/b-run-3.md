SHEET-VIEW-LAYOUT (EARS)

**Ubiquitous**
1. The system shall publish exactly four view tabs, named `Positions`, `Open Lots`, `Realized`, `Tax`, in that left-to-right order.
2. The system shall assert the full workbook order on every republish, idempotently: Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events — Positions leftmost (landing), the two event logs last.
3. The system shall render each view tab as a frozen typed header in row 1 and data rows beginning at row 2 (`DATA_START_ROW = 2`), data range `'<tab>'!A2:Z`.
4. Headers shall be exactly: Positions = Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Realized P&L, Quote Date; Open Lots = Lot ID, Symbol, Acquire Date, Source, Shares, Total Basis, Basis/Share, Platform, Tracking Code, Term; Realized = Sale ID, Lot ID, Symbol, Sale Date, Proceeds, Basis, Gain, Holding Days, Term, State, Tax Year; Tax = Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State; Tax reserve band (`Tax · Reserve Summary`, a distinct range, not a fifth view tab) = Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall.
5. Each band shall be one row per entity (symbol / open lot / realized gain / accrual / (Jurisdiction, Tax Year)), every row exactly as wide as its header, with no blank, label, separator, or embedded-header rows among the data, so native filtering works end to end.
6. Positions live columns shall be row-anchored to their own row r (r = row index + 2): E `=GOOGLEFINANCE("<ticker>","price")`, F `=Er*Br`, G `=Fr-Dr`, I `=Gr*Hr`, J `=Gr*(1-Hr)`, K `=IF(Dr=0,0,Gr/Dr)`, M `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`; all other cells are engine values written USER_ENTERED so `Est. Tax Rate` (`"20.0000%"`) coerces to numeric 0.20.
7. Read-back shall key the Positions grid by column index: symbol 0, Price 4, Quote Date 12; rows with an empty symbol cell are skipped.

**Event-driven**
8. When republishing a tab, the system shall rewrite the data range as one atomic batchUpdate and truncate the residual tail to the exact row count (human-inserted/sorted rows are overwritten), and shall never rewrite row 1.
9. When a tab does not exist, the system shall create it, write its header once at `A1`, then write data.
10. When a tab's write fails, the system shall return `PublishFailed`, leave the tab as-is, flag it stale, and best-effort write `STALE — last sync <ts>` to `'<tab>'!AA1`.

**Unwanted**
11. If two rows carry the same symbol, the system shall abort with `DuplicateSymbolRow(symbol)`.