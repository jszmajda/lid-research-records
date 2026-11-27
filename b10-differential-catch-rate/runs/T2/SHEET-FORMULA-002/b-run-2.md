```
EARS requirements enforced (SHEET-VIEW: per-row live-formula anchoring & cell references)

R1 (Ubiquitous). The Positions view SHALL assign each rendered position row a 1-based sheet row number r = (zero-based row index) + DATA_START_ROW, where DATA_START_ROW = 2 (row 1 is the frozen header; data begins row 2).

R2 (Ubiquitous). For each position row r, the system SHALL render exactly these live formulas, self-referencing only row r's own cells:
 - Price (col E): `=GOOGLEFINANCE("<resolved-ticker>","price")`
 - Market Value (col F): `=E{r}*B{r}`
 - Unrealized P&L (col G): `=F{r}-D{r}`
 - Est. Unrealized Tax (est) (col I): `=G{r}*H{r}`
 - Net Unrealized (est) (col J): `=G{r}*(1-H{r})`
 - Unrealized % (col K): `=IF(D{r}=0,0,G{r}/D{r})`
 - Quote Date (col M, index 12): `=IFERROR(TEXT(INT(GOOGLEFINANCE("<resolved-ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`

R3 (Unwanted behavior). IF a row's formula is generated for row r, THEN it SHALL NOT contain any other row's number (no `<col><r'>` token for r'≠r) — a row shift/insertion cannot mis-pair a cell against a neighboring row's value.

R4 (Ubiquitous — zero-guard). WHEN Total Basis (col D) is 0, THE Unrealized % formula SHALL evaluate to 0 rather than dividing by zero.

R5 (Ubiquitous — ticker resolution). The Price and Quote Date formulas for a row SHALL both use the same alias-resolved ticker (via config's AliasMap), quoted.

R6 (Ubiquitous — cell typing). Columns Price, Market Value, Unrealized P&L, Est. Unrealized Tax, Net Unrealized, Unrealized %, and Quote Date SHALL be Cell::Formula; Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L SHALL be Cell::Value. The Tax tab (accrual band and reserve-summary band) SHALL contain zero formula cells — all Cell::Value.

R7 (Ubiquitous — numeric-coercion contract). The Est. Tax Rate value cell SHALL be written as a percent-suffixed literal string (e.g. "20.0000%"), never as a formula, so Sheets coerces it to a numeric fraction in [0,1] that `=G{r}*H{r}` / `=G{r}*(1-H{r})` can multiply directly (not inert text).

R8 (Unwanted behavior). IF Snapshot.positions yields two entries for the same symbol, THEN render_positions SHALL return Err(ViewError::DuplicateSymbolRow(symbol)) instead of emitting a duplicate/mispaired row (defensive; normally unreachable since positions is keyed by symbol).

R9 (Ubiquitous — quote-date encoding). The Quote Date formula SHALL truncate GOOGLEFINANCE's tradetime to a date serial, re-base it to days-since-1970-01-01, and render via TEXT(...,"0"); on load/error it SHALL render empty (not an error string), via IFERROR.
```