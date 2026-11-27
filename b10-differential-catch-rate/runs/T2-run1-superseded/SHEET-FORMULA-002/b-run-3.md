**EARS requirements enforced (formula anchoring & cell references, Positions view):**

**Ubiquitous — row anchoring.** THE system SHALL begin Positions data rows at `DATA_START_ROW = 2` (row 1 reserved for the frozen, never-rewritten header); the Nth rendered position (0-indexed, snapshot iteration order) SHALL occupy row `r = N + DATA_START_ROW`.

**Ubiquitous — column layout & formula text.** For each position row at row `r`, with resolved ticker `T` (via `AliasMap::resolve`), THE system SHALL emit exactly:
- Col E (Price): `=GOOGLEFINANCE("T","price")`
- Col M / index 12 (Quote Date): `=IFERROR(TEXT(INT(GOOGLEFINANCE("T","tradetime"))-DATE(1970,1,1),"0"),"")`
- Col F (Market Value): `=E{r}*B{r}`
- Col G (Unrealized P&L): `=F{r}-D{r}`
- Col I (Est. Unrealized Tax): `=G{r}*H{r}`
- Col J (Net Unrealized): `=G{r}*(1-H{r})`
- Col K (Unrealized %): `=IF(D{r}=0,0,G{r}/D{r})`

**Ubiquitous — value/formula split.** Columns A (Symbol), B (Shares), C (Avg Cost/Share), D (Total Basis), H (Est. Tax Rate), L (Realized P&L) SHALL be engine-written `Cell::Value`s, never formulas. Columns E, F, G, I, J, K, and Quote Date (col 12) SHALL always be `Cell::Formula`.

**Unwanted behavior — cross-row leak.** A row's formulas SHALL reference ONLY that row's own cells (`r`); they SHALL NOT contain any other data row's cell reference (e.g. row 3's Market Value must never contain `E2`/`B2`), preventing row-shift mispairing.

**State-driven — numeric-coercible rate encoding.** WHILE Est. Tax Rate is populated for a symbol, IT SHALL be written as a percent-suffixed value string (e.g. `"20.0000%"`) via plain `userEnteredValue` (not forced-string), so Sheets coerces it to the numeric fraction (rate/100) that `=G*H` and `=G*(1-H)` multiply; when absent (degraded estimate), the cell SHALL be empty and post-tax columns degrade to the pre-tax figure.

**Unwanted behavior — duplicate symbol.** IF `Snapshot.positions` yields more than one row for the same symbol THEN `render_positions` SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit a duplicate or misaligned row (defensive; structurally unreachable via the real `Map<Symbol,_>` source, but pinned as a loud guard).

**Ubiquitous — non-formula tabs.** Open Lots, Realized, and Tax (both accrual and reserve-summary bands) SHALL contain zero live formulas — every cell a kernel-exact value.