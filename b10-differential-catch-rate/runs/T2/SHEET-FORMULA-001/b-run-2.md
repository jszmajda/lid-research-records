**EARS requirements enforced (value/formula column split, `sheets-view`):**

**Ubiquitous**
- U1: The Positions view SHALL render `Symbol`, `Shares`, `Avg Cost/Share`, `Total Basis`, `Est. Tax Rate`, and `Realized P&L` as engine `Value`s; and `Price`, `Market Value`, `Unrealized P&L`, `Est. Unrealized Tax (est)`, `Net Unrealized (est)`, `Unrealized %`, and `Quote Date` as live `Formula`s (GOOGLEFINANCE-dependent).
- U2: The Open Lots, Realized, and Tax tabs (both the accrual band and the reserve-summary band) SHALL render every cell as an engine `Value`; no cell in these tabs SHALL be a `Formula`.
- U3: Every per-row live formula SHALL reference only that row's own cells by row number; it SHALL NOT contain any other data row's cell reference (prevents row-shift mis-pairing).
- U4: A `Cell::Value` SHALL be written to Sheets as `userEnteredValue` (never a forced string value); a `Cell::Formula` SHALL be written as `userEnteredValue` containing the `=`-prefixed formula text.

**Event-driven**
- E1: WHEN rendering row r's Price cell, the system SHALL emit exactly `=GOOGLEFINANCE("<ticker>","price")`, ticker double-quoted.
- E2: WHEN rendering row r, the system SHALL emit: Market Value `=E{r}*B{r}`; Unrealized P&L `=F{r}-D{r}`; Est. Unrealized Tax `=G{r}*H{r}`; Net Unrealized `=G{r}*(1-H{r})`; Unrealized % `=IF(D{r}=0,0,G{r}/D{r})` — the D=0 tie-break yields 0, never `#DIV/0!`.
- E3: WHEN rendering Quote Date, the system SHALL emit `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")` — trade time truncated to its date serial, rebased to days-since-1970-01-01, rendered as digits-only text; on load/error it SHALL evaluate to empty string, never an error string.
- E4: WHEN a symbol has a computed effective tax rate, the `Est. Tax Rate` Value SHALL be written as a percent-suffixed literal with 4 fractional digits (e.g. `"20.0000%"`) so Sheets coerces it to the numeric fraction `[0,1]` that the post-tax formulas (`=G*H`, `=G*(1-H)`) multiply.

**Unwanted-behavior**
- N1: IF a symbol is absent from `effective_rates` (degraded estimate), THEN `Est. Tax Rate` SHALL render as an empty-string `Value` (never a formula, never `0`).
- N2: IF `Snapshot.positions` yields two rows for one symbol, THEN rendering SHALL return `Err(DuplicateSymbolRow)` rather than emit ambiguously row-anchored formulas.

Files: `crates/sheets-view/src/lib.rs`, `crates/sheets-view/tests/formula.rs`.