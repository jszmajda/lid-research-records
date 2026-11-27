**EARS reconstruction — per-row live-formula anchoring & cell references (sheets-view Positions tab)**

1. **Ubiquitous:** Data rows on a view tab SHALL begin at the fixed anchored row `DATA_START_ROW = 2` (1-based), immediately beneath the never-rewritten frozen header at row 1.

2. **Ubiquitous:** For the i-th (0-indexed) row rendered by `render_positions`, its spreadsheet row number SHALL be `r = i + DATA_START_ROW`.

3. **Ubiquitous:** Positions columns SHALL be fixed as: A=Symbol, B=Shares, C=Avg Cost/Share, D=Total Basis, E=Price, F=Market Value, G=Unrealized P&L, H=Est. Tax Rate, I=Est. Unrealized Tax (est), J=Net Unrealized (est), K=Unrealized %, L=Realized P&L, M=Quote Date (fixed at index 12).

4. **Ubiquitous:** Each row's live formulas SHALL reference only that row's own number `r`: Market Value = `=E{r}*B{r}`; Unrealized P&L = `=F{r}-D{r}`; Est. Unrealized Tax = `=G{r}*H{r}`; Net Unrealized = `=G{r}*(1-H{r})`; Unrealized % = `=IF(D{r}=0,0,G{r}/D{r})` (guards zero total basis).

5. **Unwanted behavior:** A row's formula string SHALL NOT contain any other data row's cell reference (no foreign row number substring), preventing cross-row mis-pairing under row-count shifts.

6. **Ubiquitous:** Price SHALL render as `=GOOGLEFINANCE("{resolved_ticker}","price")`. Quote Date SHALL render as `=IFERROR(TEXT(INT(GOOGLEFINANCE("{resolved_ticker}","tradetime"))-DATE(1970,1,1),"0"),"")` — truncated to a date serial, re-based to days-since-1970-01-01 (the kernel `Date` epoch), rendered as a digits-only string via `TEXT(…,"0")`.

7. **Unwanted behavior:** WHILE the Quote Date GOOGLEFINANCE call is loading or erroring, the formula SHALL evaluate to empty string `""`, never an error literal.

8. **Event-driven:** WHEN a symbol resolves through the alias map to a ticker, THEN both Price and Quote Date formulas SHALL use that resolved ticker (quoted), not the raw symbol.

9. **Ubiquitous:** Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, Realized P&L SHALL be `Cell::Value`; Price, Market Value, Unrealized P&L, Est. Unrealized Tax, Net Unrealized, Unrealized %, Quote Date SHALL be `Cell::Formula`. No other Positions column may be a formula.

10. **Ubiquitous:** The Est. Tax Rate value SHALL be encoded as a percent-suffixed numeric string (`"NN.NNNN%"`), coercible by Sheets to a numeric fraction, since H is multiplied by row formulas I and J.

11. **State-driven:** WHILE a symbol has no computed effective tax rate, its Est. Tax Rate cell SHALL be empty string.

12. **Ubiquitous:** Every cell on both Tax-tab bands (accrual, reserve-summary) SHALL be `Cell::Value` — no Formula cell permitted there.

13. **Unwanted behavior:** IF `snapshot.positions` yields two rows for one symbol THEN `render_positions` SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than render both.