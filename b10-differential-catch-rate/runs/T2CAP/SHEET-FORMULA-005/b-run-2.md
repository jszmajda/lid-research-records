P-FORMULA-005 reconstructed EARS (Est. Tax Rate cell — write and consumption):

**SHEET-POS-ESTRATE-001 (ubiquitous).** The Positions tab header SHALL contain the column `Est. Tax Rate` at zero-based index 7 (spreadsheet column H), positioned between `Unrealized P&L` (G) and `Est. Unrealized Tax (est)` (I), fixing the letters the post-tax formulas reference.

**SHEET-POS-ESTRATE-002 (ubiquitous).** The `Est. Tax Rate` cell SHALL be an engine **value** (`Cell::Value`), never a live formula, sourced from `tax`'s per-position effective unrealized rate (`Ppm`) keyed by symbol; `sheets-view` SHALL perform no rate math of its own.

**SHEET-POS-ESTRATE-003 (event-driven).** WHEN rendering a position row whose symbol has an effective rate `Ppm(p)`, the system SHALL write the cell as the percent literal `{sign}{|p|/10000}.{|p|%10000 padded to 4 digits}%` — e.g. `Ppm(150_000)` → `"15.0000%"`, `Ppm(200_000)` → `"20.0000%"` — always exactly four fractional digits, with a leading `-` only when `p < 0`, and no thousands separators.

**SHEET-POS-ESTRATE-004 (event-driven / boundary).** WHEN the symbol is absent from the effective-rate map (degraded estimate), the system SHALL write the empty string `""` as the cell value, SHALL NOT error, and SHALL still render the row and the post-tax formulas — which then degrade to the pre-tax figure (empty H coerces to 0, so `=G*H` → 0 and `=G*(1-H)` → G).

**SHEET-POS-ESTRATE-005 (ubiquitous).** For data row `r` (`r = row_index + DATA_START_ROW`, `DATA_START_ROW = 2`, beneath the frozen header at row 1), the consuming columns SHALL be row-anchored formulas referencing that row only: `Est. Unrealized Tax (est)` = `=G{r}*H{r}` and `Net Unrealized (est)` = `=G{r}*(1-H{r})`; neither SHALL reference any other data row's number.

**SHEET-POS-ESTRATE-006 (ubiquitous — client contract).** The `SheetsViewClient` SHALL write a `Cell::Value` as a Sheets `userEnteredValue` (NOT a forced `stringValue`), so `"20.0000%"` is parsed as the numeric fraction `0.20` with a percent number format.

**SHEET-POS-ESTRATE-007 (unwanted behavior).** IF the `Est. Tax Rate` cell were written as inert text, THEN `=G*H` / `=G*(1-H)` would yield 0 or an error; the system SHALL therefore guarantee the cell coerces to a number. The written rate SHALL parse (after stripping `%`, ÷100) to a finite fraction in `[0.0, 1.0]`, and SHALL satisfy `G*H + G*(1-H) == G`, with a strictly positive rate yielding a strictly positive estimated tax.

**SHEET-POS-ESTRATE-008 (ubiquitous).** The Tax tab (both accrual and reserve-summary bands) SHALL carry no formulas; the live rate-driven estimate exists only on Positions.