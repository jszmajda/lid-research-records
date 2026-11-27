**EARS-style requirements — value/formula column boundary (sheets-view)**

**Ubiquitous**
- The system shall represent every published view-tab cell as exactly one of two structural kinds: `Cell::Value` (engine-computed) or `Cell::Formula` (live-price-dependent); the distinction is a typed enum, not a formatting convention.
- On the Positions tab, the system shall render the columns Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, and Quote Date as `Formula` cells. It shall render Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L as `Value` cells.
- The system shall render every cell of the Open Lots tab, the Realized tab, and both Tax-tab bands (accrual band and reserve-summary band) as `Value` cells; no cell on these tabs shall be a `Formula`.
- The Price formula shall be exactly `=GOOGLEFINANCE("<ticker>","price")` using the alias-resolved ticker.
- The Quote Date formula shall be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")` — truncating trade time to its date serial, re-basing to days-since-1970-01-01 (the kernel `Date` epoch), rendering via `TEXT(...,"0")` as a locale-invariant digit string, and evaluating to empty string (never an error literal) while the quote is loading or errored.
- Market Value, Unrealized P&L, Est. Unrealized Tax, Net Unrealized, and Unrealized % shall be formulas `=E{r}*B{r}`, `=F{r}-D{r}`, `=G{r}*H{r}`, `=G{r}*(1-H{r})`, and `=IF(D{r}=0,0,G{r}/D{r})` respectively, where `r` is that row's own 1-based row number; data rows begin at row 2 (`DATA_START_ROW`).
- A row's formulas shall reference only that row's own cell coordinates and shall never contain any other data row's row number.
- The Est. Tax Rate `Value` cell shall be encoded as a percent-suffixed numeric string (e.g. `"20.0000%"`) so that, written as a Sheets `userEnteredValue`, it parses as the numeric fraction (e.g. `0.20`) with percent formatting rather than inert text — required because the Est. Unrealized Tax and Net Unrealized formulas multiply it directly.
- `Cell::Value` shall be written to Sheets as `userEnteredValue` (never forced `stringValue`), so Sheets parses it exactly as a human-typed entry would.

**State-driven**
- While a symbol's effective tax rate is absent from `effective_rates` (degraded estimate), the system shall render its Est. Tax Rate as an empty `Value` cell.

**Unwanted behavior**
- If `Snapshot.positions` ever yields two entries for the same symbol, `render_positions` shall not emit duplicate rows; it shall return `Err(ViewError::DuplicateSymbolRow(symbol))`.