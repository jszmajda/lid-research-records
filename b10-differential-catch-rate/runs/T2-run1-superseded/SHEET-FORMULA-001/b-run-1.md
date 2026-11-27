**Reconstructed EARS requirements — Value/Formula boundary in `sheets-view` rendering**

**Ubiquitous:**

1. The system shall render each Positions-tab row's `Price`, `Market Value`, `Unrealized P&L`, `Est. Unrealized Tax (est)`, `Net Unrealized (est)`, `Unrealized %`, and `Quote Date` cells as `Cell::Formula`.
2. The system shall render each Positions-tab row's `Symbol`, `Shares`, `Avg Cost/Share`, `Total Basis`, `Est. Tax Rate`, and `Realized P&L` cells as `Cell::Value` (never a formula).
3. The system shall render every cell of both Tax-tab bands (accrual band and reserve-summary band) as `Cell::Value`; no Tax-tab cell shall be a formula.
4. The `Price` formula shall be exactly `=GOOGLEFINANCE("<ticker>","price")`, ticker double-quoted, ticker resolved via the alias map.
5. The `Quote Date` formula shall be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")` — truncate trade time to its date serial, subtract `DATE(1970,1,1)` to re-base to days-since-epoch, render digit-only via `TEXT(…,"0")`.
6. For row `r = row_index + DATA_START_ROW` (`DATA_START_ROW = 2`): `Market Value = "=E{r}*B{r}"`; `Unrealized P&L = "=F{r}-D{r}"`; `Est. Unrealized Tax = "=G{r}*H{r}"`; `Net Unrealized = "=G{r}*(1-H{r})"`; `Unrealized % = "=IF(D{r}=0,0,G{r}/D{r})"`.
7. Each row-anchored formula shall reference only its own row's cell coordinates; it shall not contain any other data row's coordinate.
8. `Est. Tax Rate` shall be written as a `Cell::Value` string with a trailing `%` (via `fmt_ppm`, e.g. `"20.0000%"`), never a formula, and shall be a Sheets `userEnteredValue` (not a forced string) so it coerces to a numeric fraction the `=G*H`/`=G*(1-H)` formulas can multiply.
9. Data rows begin at row `DATA_START_ROW = 2`; row 1 is the frozen header.

**State-driven:**

10. WHILE a symbol is absent from `effective_rates` (degraded estimate), the system shall render `Est. Tax Rate` as an empty `Cell::Value` string, while `Est. Unrealized Tax`/`Net Unrealized` remain formula cells.

**Unwanted behavior:**

11. IF `Total Basis` (column D) is 0 THEN `Unrealized %` shall evaluate to `0` rather than dividing by zero.
12. IF two rows in `Snapshot.positions` carry the same symbol THEN `render_positions` shall return `Err(ViewError::DuplicateSymbolRow)` rather than emitting a second row (row-identity invariant the formula anchoring depends on).

Untested/unpinned by these two files: Open Lots and Realized tabs' formula-vs-value split (code shows all-`Value`, no test asserts it).