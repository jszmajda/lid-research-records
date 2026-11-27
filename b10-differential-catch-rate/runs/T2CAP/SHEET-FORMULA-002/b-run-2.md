SHEET-POS-ANCHOR-001 (Ubiquitous) The Positions tab SHALL have exactly the 13 columns, in order: A Symbol, B Shares, C Avg Cost/Share, D Total Basis, E Price, F Market Value, G Unrealized P&L, H Est. Tax Rate, I Est. Unrealized Tax (est), J Net Unrealized (est), K Unrealized %, L Realized P&L, M Quote Date (0-based index 12).

SHEET-POS-ANCHOR-002 (Ubiquitous) Data rows SHALL be written from the fixed anchored start row DATA_START_ROW = 2, beneath the frozen header at row 1; the row number of the i-th rendered row (0-based) SHALL be r = i + 2. Adapters SHALL address the data range as `'<tab>'!A2:Z`.

SHEET-POS-ANCHOR-003 (Ubiquitous) On the Positions tab, exactly these cells SHALL be live formulas: E, F, G, I, J, K, M. All others (A, B, C, D, H, L) SHALL be engine values. Open Lots, Realized, and both Tax bands SHALL contain no formula cells.

SHEET-POS-ANCHOR-004 (Ubiquitous) Each per-row formula on row r SHALL reference only cells on row r, using exactly:
- E: `=GOOGLEFINANCE("<ticker>","price")`
- F: `=E{r}*B{r}`
- G: `=F{r}-D{r}`
- I: `=G{r}*H{r}`
- J: `=G{r}*(1-H{r})`
- K: `=IF(D{r}=0,0,G{r}/D{r})`
- M: `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`

SHEET-POS-ANCHOR-005 (Unwanted) A row-r formula SHALL NOT contain any A1 reference to another data row's number (e.g. E/B of row r' ≠ r), so a row shift cannot mis-pair cells.

SHEET-POS-ANCHOR-006 (Ubiquitous) `<ticker>` in both E and M SHALL be the same alias-resolved ticker (`AliasMap::resolve(symbol)`, identity when unaliased), quoted with `"`.

SHEET-POS-ANCHOR-007 (State-driven) While a symbol has no effective unrealized rate, H SHALL be the empty value string (I and J then degrade to 0 / pre-tax); otherwise H SHALL be the percent literal `{ppm/10000}.{ppm%10000:04}%` (e.g. `20.0000%`), signed, written as a `userEnteredValue` so Sheets coerces it to the numeric fraction that `=G*H` and `=G*(1-H)` multiply — never inert text. The fraction SHALL be finite and within [0,1].

SHEET-POS-ANCHOR-008 (Ubiquitous) K SHALL divide by Total Basis D and SHALL yield 0 when D = 0 (no #DIV/0!). M SHALL render the empty string, never an error string, while the quote is loading or errored; when settled it SHALL be digits-only days since 1970-01-01 (locale-proof).

SHEET-POS-ANCHOR-009 (Unwanted) If two rows would be rendered for one Symbol, render_positions SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` and produce no tab, since read-back keys on row identity.

SHEET-POS-ANCHOR-010 (Event-driven) When the settle pass reads a Positions data row back, it SHALL take Price from column index 4 and Quote Date from column index 12, defaulting an unparseable quote date to Date(0).

SHEET-POS-ANCHOR-011 (Ubiquitous) Republish SHALL rewrite only rows from row 2 down (wholesale replace + tail-truncate); the frozen header SHALL never be rewritten and a republish presenting a differing header SHALL fail loudly.