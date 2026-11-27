EARS-STYLE REQUIREMENTS — Value/Formula Column Split (Positions & Tax tabs)

**Ubiquitous:**
- The system shall render the Positions tab columns Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), and Unrealized % as `Cell::Formula` values.
- The system shall render the Positions tab columns Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L as `Cell::Value` values.
- The system shall render the Positions tab Quote Date column (index 12) as `Cell::Formula`.
- The system shall render every cell of the Tax tab's accrual band and reserve-summary band as `Cell::Value` — no live-price formulas, regardless of jurisdiction, tax year, or figure (Accrued/Moved/Paid/Outstanding/Shortfall), and none of the five reserve figures may be blank.
- The Price formula shall be exactly `=GOOGLEFINANCE("TICKER","price")` with the resolved ticker double-quoted.
- The Quote Date formula shall be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")`, using the resolved ticker.
- The Market Value formula on row r shall be `=E{r}*B{r}`; Unrealized P&L shall be `=F{r}-D{r}`; Est. Unrealized Tax shall be `=G{r}*H{r}`; Net Unrealized shall be `=G{r}*(1-H{r})`; Unrealized % shall be `=IF(D{r}=0,0,G{r}/D{r})`.
- The Est. Tax Rate `Cell::Value` shall be written as a percent-suffixed numeric string (e.g. "20.0000%") so Sheets coerces it to a numeric fraction (not text), enabling the post-tax formulas to multiply it correctly.

**Event-driven:**
- WHEN rendering a Positions row at index i, the system shall generate all row-anchored formulas referencing only that row's own number `r = i + DATA_START_ROW (2)` — never any other row's cell reference.

**State-driven:**
- WHILE a symbol's effective tax rate is absent (degraded estimate), the Est. Tax Rate cell shall render as an empty `Cell::Value` string.
- WHILE the GOOGLEFINANCE tradetime read is loading or erroring, the Quote Date formula shall evaluate to empty string (via IFERROR), never an error string.

**Unwanted behavior:**
- IF `Snapshot.positions` contains two rows for the same symbol, THEN the system shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than render duplicate rows (defensive, structurally unreachable via the real Map-backed API, kept for a future non-Map source).