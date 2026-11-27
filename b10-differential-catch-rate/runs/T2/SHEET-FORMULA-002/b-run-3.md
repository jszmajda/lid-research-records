**Reconstructed EARS requirements — Positions view-tab per-row formula anchoring & cell references (SHEET-* / sheets-view)**

1. **Ubiquitous:** The system shall begin Positions data rows at a fixed anchor `DATA_START_ROW = 2` (row 1 is the frozen header).

2. **Ubiquitous:** The system shall render one Positions row per symbol, in the iteration order of `Snapshot.positions` (a Symbol-keyed map ⇒ ascending symbol order), with row number `r = row_index + DATA_START_ROW`.

3. **Ubiquitous:** The system shall assign fixed columns A–M: A Symbol, B Shares, C Avg Cost/Share, D Total Basis, E Price, F Market Value, G Unrealized P&L, H Est. Tax Rate, I Est. Unrealized Tax (est), J Net Unrealized (est), K Unrealized %, L Realized P&L, M Quote Date (column index 12).

4. **Ubiquitous:** The system shall render E, F, G, I, J, K, M as live `Cell::Formula`, and A, B, C, D, H, L as engine `Cell::Value`.

5. **State-driven:** WHILE rendering row `r`, the system shall emit each formula referencing ONLY row-`r` cells: Market Value = `=E{r}*B{r}`; Unrealized P&L = `=F{r}-D{r}`; Est. Unrealized Tax = `=G{r}*H{r}`; Net Unrealized = `=G{r}*(1-H{r})`; Unrealized % = `=IF(D{r}=0,0,G{r}/D{r})`.

6. **Unwanted-behavior:** IF a generated per-row formula would reference any row number other than its own THEN the system shall not emit it — no formula may contain another row's `E{r'}`/`B{r'}`/etc. (row-shift safety).

7. **Event-driven:** WHEN Total Basis (D) is zero, THE Unrealized % formula shall evaluate to `0` rather than dividing by zero.

8. **Ubiquitous:** The Price formula shall be exactly `=GOOGLEFINANCE("<resolved-ticker>","price")`, ticker double-quoted, resolved via the alias map.

9. **Ubiquitous:** The Quote Date formula shall be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")` — truncate tradetime to a date serial, re-base to days-since-1970-01-01, render as a digit-only string via `TEXT(...,"0")`; on load/error the cell shall render `""`, never an error string.

10. **Ubiquitous:** The Est. Tax Rate value cell shall be written as a percent-suffixed string (e.g. `"20.0000%"`) via `userEnteredValue` (never forced-string), so Sheets coerces it to the numeric fraction (e.g. `0.20`) that `=G*H`/`=G*(1-H)` require to evaluate correctly.

11. **Unwanted-behavior:** IF the position source ever yields two rows for one symbol THEN the system shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than rendering duplicate/mismatched rows.