**EARS reconstruction — per-row live-formula anchoring & cell references (Positions tab)**

*Ubiquitous:*
- The system shall render the Positions view tab with a frozen header occupying row 1; data rows shall begin at row `DATA_START_ROW = 2`, with the Nth data row (0-indexed) at absolute row `N + 2`.
- The Positions header shall be exactly 13 ordered columns: A=Symbol, B=Shares, C=Avg Cost/Share, D=Total Basis, E=Price, F=Market Value, G=Unrealized P&L, H=Est. Tax Rate, I=Est. Unrealized Tax (est), J=Net Unrealized (est), K=Unrealized %, L=Realized P&L, M=Quote Date (column index 12).
- For each rendered row, every live-formula cell shall reference only that same row's own cell addresses; it shall not contain any other data row's cell reference (no cross-row leakage).
- The frozen header (row 1) shall never be rewritten by a republish; only the data range from row 2 downward is rewritten.

*Event-driven:*
- When rendering a position's row at row `r`, the system shall emit: Price(E) = `=GOOGLEFINANCE("{ticker}","price")`; Market Value(F) = `=E{r}*B{r}`; Unrealized P&L(G) = `=F{r}-D{r}`; Est. Unrealized Tax(I) = `=G{r}*H{r}`; Net Unrealized(J) = `=G{r}*(1-H{r})`; Unrealized %(K) = `=IF(D{r}=0,0,G{r}/D{r})`; Quote Date(M) = `=IFERROR(TEXT(INT(GOOGLEFINANCE("{ticker}","tradetime"))-DATE(1970,1,1),"0"),"")`, where `{ticker}` is the symbol resolved through the alias map.
- When a settle-pass reads a Positions row back, the system shall interpret column index 4 as `Price` and column index 12 as `Quote Date`.
- When a Positions row's Est. Tax Rate is populated, the system shall write it as an engine `Value` (not formula) formatted as a percent-suffixed string (e.g. `"20.0000%"`) written as a `userEnteredValue`, so Sheets coerces it to the numeric fraction the same-row formulas `=G*H`/`=G*(1-H)` multiply against.

*State-driven:*
- While a symbol has no computed effective tax rate, the Est. Tax Rate cell shall render as an empty value string (post-tax formulas degrade toward the pre-tax figure).

*Unwanted behavior:*
- If `Snapshot.positions` yields two rows for the same symbol, the system shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than render both (row identity/read-back keys on symbol uniqueness).
- If the Quote Date formula's underlying quote is loading or errored, it shall render as an empty string via `IFERROR`, never a raw error string.