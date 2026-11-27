SHEET-VIEW-FORMULA — Per-row live formula anchoring (Positions tab)

**Ubiquitous**
1. The Positions tab SHALL have exactly 13 columns in the fixed order A Symbol, B Shares, C Avg Cost/Share, D Total Basis, E Price, F Market Value, G Unrealized P&L, H Est. Tax Rate, I Est. Unrealized Tax (est), J Net Unrealized (est), K Unrealized %, L Realized P&L, M Quote Date (0-based index 12).
2. The typed header SHALL occupy row 1 (frozen, written once, never rewritten on republish; a republish presenting a different header is a contract violation) and data rows SHALL be written from the anchored start row DATA_START_ROW = 2 (A1 data range `'{tab}'!A2:Z`), tail-truncated to the exact row count.
3. Exactly the columns E, F, G, I, J, K, M SHALL be live formulas; A, B, C, D, H, L SHALL be engine values. The Tax tab (both accrual and reserve-summary bands) SHALL contain no formula cells.

**Event-driven** — When rendering the Positions row at 0-based index i, with r = i + 2 and ticker = AliasMap.resolve(symbol), the system SHALL emit:
- E: `=GOOGLEFINANCE("{ticker}","price")`
- F: `=E{r}*B{r}`
- G: `=F{r}-D{r}`
- I: `=G{r}*H{r}`
- J: `=G{r}*(1-H{r})`
- K: `=IF(D{r}=0,0,G{r}/D{r})`
- M: `=IFERROR(TEXT(INT(GOOGLEFINANCE("{ticker}","tradetime"))-DATE(1970,1,1),"0"),"")`

**Unwanted behavior**
4. No row's formula SHALL reference any other data row's number; every A1 reference in row r SHALL carry the row suffix r, so a row shift cannot mis-pair cells.
5. If `Snapshot.positions` yields two rows for one symbol, render SHALL fail with `ViewError::DuplicateSymbolRow(symbol)` (one row per symbol is the identity the read-back keys on).

**State-driven**
6. H SHALL be the tax-written effective rate as a percent literal `{whole}.{frac:04}%` (ppm/10⁴, e.g. `20.0000%`), written as a Sheets `userEnteredValue` so it coerces to the numeric fraction (0.20) that `=G*H` and `=G*(1-H)` multiply — never inert text; the identity G*H + G*(1−H) = G SHALL hold.
7. While a symbol has no effective rate (degraded estimate), H SHALL be the empty string and the post-tax columns SHALL degrade to the pre-tax figure.
8. While the quote is loading or errored, M SHALL render the empty string, never an error string; K SHALL yield 0 when D = 0.
9. Read-back SHALL key rows by column 0 (Symbol), parse Price from column 4 and quote date from column 12 as integer days since 1970-01-01 (defaulting 0 when unparseable).