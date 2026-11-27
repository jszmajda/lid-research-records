**EARS requirements — value/formula column boundary (Positions & other view tabs)**

**Ubiquitous — Positions column typing.** The Positions tab SHALL render columns `Price`, `Market Value`, `Unrealized P&L`, `Est. Unrealized Tax (est)`, `Net Unrealized (est)`, `Unrealized %`, and `Quote Date` (column index 12, the 13th column) as `Cell::Formula`. Columns `Symbol`, `Shares`, `Avg Cost/Share`, `Total Basis`, `Est. Tax Rate`, and `Realized P&L` SHALL render as `Cell::Value`.

**Ubiquitous — other tabs are all-value.** Every cell of the Open Lots tab, the Realized tab, and both Tax-tab bands (accrual band and reserve-summary band) SHALL be `Cell::Value`; no cell in these tabs SHALL ever be `Cell::Formula`.

**Ubiquitous — exact formula text.** For a Positions row at 1-based row `r` with resolved ticker `T`:
- `Price` = `=GOOGLEFINANCE("T","price")`.
- `Quote Date` = `=IFERROR(TEXT(INT(GOOGLEFINANCE("T","tradetime"))-DATE(1970,1,1),"0"),"")`.
- `Market Value` = `=E{r}*B{r}`.
- `Unrealized P&L` = `=F{r}-D{r}`.
- `Est. Unrealized Tax (est)` = `=G{r}*H{r}`.
- `Net Unrealized (est)` = `=G{r}*(1-H{r})`.
- `Unrealized %` = `=IF(D{r}=0,0,G{r}/D{r})`.

**Event-driven — row anchoring.** When rendering row `r`'s formulas, each SHALL reference only column letters paired with row `r` itself and SHALL NOT contain any other data row's number, so a row shift cannot mis-pair cells.

**State-driven — zero-basis guard.** WHILE Total Basis (`D`) is 0 for a row, `Unrealized %` SHALL evaluate to 0 rather than divide by zero.

**Ubiquitous — Est. Tax Rate value encoding.** `Est. Tax Rate` SHALL be a `Cell::Value` percent-suffixed decimal string (4 fraction digits, e.g. `"20.0000%"`), never a formula. The write path SHALL set it as a Sheets `userEnteredValue` (never `stringValue`) so Sheets coerces it to the numeric fraction `value/100` in `[0,1]`, letting `=G*H`/`=G*(1-H)` multiply it as a number. A symbol absent from `effective_rates` SHALL render an empty (`""`) value, while the dependent formula columns remain formulas.

**Ubiquitous — formula value-typing.** A `Cell::Formula` SHALL also be written as a `userEnteredValue` (text beginning with `=`), never a forced string.

**Unwanted behavior — duplicate symbol.** IF `Snapshot.positions` yields two entries for one symbol, THEN `render_positions` SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` instead of emitting any formula/value row for the duplicate.