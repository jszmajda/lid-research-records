**EARS requirements — Positions pre-tax/post-tax unrealized figures**

**Ubiquitous:**
1. The Positions tab shall present a pre-tax "Unrealized P&L" column and two post-tax *estimate* columns, "Est. Unrealized Tax (est)" and "Net Unrealized (est)" — both estimate headers carrying an explicit "(est)" suffix — alongside "Est. Tax Rate".
2. All of Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), and Unrealized % shall be rendered as live `Cell::Formula` values (GOOGLEFINANCE-dependent); Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L shall be rendered as engine `Cell::Value`s, never formulas.
3. Given row r (r = row-index + `DATA_START_ROW`, where `DATA_START_ROW` = 2), the system shall emit exactly: Market Value = `=E{r}*B{r}`; Unrealized P&L (pre-tax) = `=F{r}-D{r}`; Est. Unrealized Tax (est) = `=G{r}*H{r}`; Net Unrealized (est) = `=G{r}*(1-H{r})`; Unrealized % = `=IF(D{r}=0,0,G{r}/D{r})`.
4. Every per-row formula shall reference only its own row's cell numbers; it shall not reference any other data row's cell number (guards against row-shift mis-pairing).
5. Est. Tax Rate shall be written as a percent-suffixed string with exactly 4 fractional digits (e.g. "15.0000%", sign preserved if negative), as a plain `userEnteredValue` (never forced-string), so Sheets coerces it to the numeric fraction (e.g. 0.20) the `=G*H` / `=G*(1-H)` formulas require — never inert text.

**Event-driven:**
6. WHEN Total Basis (D) for a row is 0, the Unrealized % formula shall evaluate to 0 instead of dividing by zero; otherwise it shall evaluate G/D.

**State-driven:**
7. WHILE a symbol is absent from the effective-rates map (degraded tax estimate), the Est. Tax Rate cell shall render as an empty string (not "0.0000%", not omitted), and the post-tax columns shall degrade accordingly under the same fixed formulas (`=G*H`, `=G*(1-H)`) rather than being replaced or erroring.

**Unwanted behavior:**
8. IF `Snapshot.positions` yields two rows for the same symbol, THEN rendering shall fail with `Err(ViewError::DuplicateSymbolRow(symbol))` rather than silently emitting duplicate rows (defensive; structurally unreachable via the real `Map<Symbol,_>` source, kept for future non-Map sources).

Files read: `crates/sheets-view/src/lib.rs`, `crates/sheets-view/tests/formula.rs` (paths under `{scratch}/audit-baseline/`).