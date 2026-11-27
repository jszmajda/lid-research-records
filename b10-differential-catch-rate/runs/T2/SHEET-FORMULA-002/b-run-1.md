**Ubiquitous (SHEET-POS formula/value split):** The system shall render Positions columns Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, and Quote Date as `Cell::Formula`; it shall render Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L as `Cell::Value`.

**Event-driven (row anchoring):** When rendering the Positions tab, for the i-th position row the system shall compute its 1-based sheet row as `r = i + DATA_START_ROW` (DATA_START_ROW = 2; header occupies row 1), and shall build that row's live formulas referencing ONLY column letters at row `r` — column map A Symbol, B Shares, C AvgCost, D TotalBasis, E Price, F MarketValue, G Unrealized P&L, H Est.TaxRate, I Est.UnrealTax, J NetUnreal, K Unreal%, L RealizedP&L, M QuoteDate:
- Price(E{r}) = `=GOOGLEFINANCE("TICKER","price")`, ticker = alias-resolved, double-quoted.
- Market Value(F{r}) = `=E{r}*B{r}`.
- Unrealized P&L(G{r}) = `=F{r}-D{r}`.
- Est. Unrealized Tax(I{r}) = `=G{r}*H{r}`.
- Net Unrealized(J{r}) = `=G{r}*(1-H{r})`.
- Unrealized %(K{r}) = `=IF(D{r}=0,0,G{r}/D{r})` (zero-basis guard, no div/0).
- Quote Date(M{r}) = `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")` — truncates trade time to date serial, re-bases to days-since-1970-01-01 (kernel Date epoch), renders digit-only via TEXT so it's locale-invariant; errors/loading render empty string, never an error literal.

**Unwanted behavior:** A row's formula shall NOT reference any other row's cell number (no cross-row leakage), so a row-count change cannot mis-pair cells across rows.

**Unwanted behavior (duplicate guard):** If `Snapshot.positions` yields two entries for the same symbol, the system shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit two rows.

**State-driven (encoding for downstream multiply):** While a symbol's effective tax rate is known, the system shall write Est. Tax Rate as a percent-suffixed numeric-literal string (e.g. `"20.0000%"`, via `fmt_ppm`) as a `Cell::Value` — never a formula — so Sheets coerces it to the numeric fraction (0.20) rather than text, since `=G*H` / `=G*(1-H)` require it to be a number.

**Ubiquitous (Tax tab):** The system shall render every cell of both the Tax accrual band and the reserve-summary band as `Cell::Value`; no cell on the Tax tab shall be a `Cell::Formula`.

**Ubiquitous (column index pin):** Quote Date shall be at header/column index 12.