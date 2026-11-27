**Ubiquitous:**
1. The Positions tab SHALL render "Unrealized P&L" (col G) as a live formula `=F{r}-D{r}` (Market Value − Total Basis) — the pre-tax figure — on each data row `r`.
2. The Positions tab SHALL render "Est. Unrealized Tax (est)" (col I) as a live formula `=G{r}*H{r}` (Unrealized P&L × Est. Tax Rate).
3. The Positions tab SHALL render "Net Unrealized (est)" (col J) as a live formula `=G{r}*(1-H{r})` (Unrealized P&L × (1 − Est. Tax Rate)).
4. The Positions tab SHALL render "Unrealized %" (col K) as `=IF(D{r}=0,0,G{r}/D{r})` — division-by-zero boundary: 0 when Total Basis is 0.
5. Every row-anchored formula (Market Value, Unrealized P&L, the two post-tax columns, Unrealized %) SHALL reference only its own row `r`'s cells; it SHALL NOT reference any other data row's cell address (verified: no other row's `E{other}`/`B{other}` etc. appear in a row's formula text).
6. The two post-tax columns' headers SHALL carry an "(est)" suffix ("Est. Unrealized Tax (est)", "Net Unrealized (est)"), distinguishing them from the un-suffixed pre-tax "Unrealized P&L" column.
7. "Est. Tax Rate" (col H) SHALL be an engine-written `Cell::Value` (never a formula), sourced from `tax`'s per-symbol effective unrealized rate, formatted via `fmt_ppm`: sign (`-` if negative) + `whole` (`ppm/10_000`) + `.` + exactly 4 fractional digits (`ppm%10_000`, zero-padded) + `%` — e.g. `Ppm(150_000)` → `"15.0000%"`.
8. The `Cell::Value` for Est. Tax Rate SHALL be written as a Sheets `userEnteredValue` (not a forced string), so `"NN.NNNN%"` is parsed as the numeric fraction NN.NNNN/100 with percent format — required for formulas 2 and 3 to multiply numerically rather than against text.

**State-driven:**
9. WHILE a symbol is absent from the effective-rates map (a degraded tax estimate), the Est. Tax Rate cell SHALL render as an empty string — never a placeholder/error — causing (by Sheets' empty→0 coercion) "Est. Unrealized Tax (est)" to evaluate to 0 and "Net Unrealized (est)" to evaluate equal to "Unrealized P&L": the post-tax figures degrade to the pre-tax figure.

**Unwanted-behavior:**
10. IF `Snapshot.positions` ever carries two rows for one symbol (duplicate-symbol violation of the one-row-per-symbol invariant the read-back keys on), THEN `render_positions` SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit ambiguous/duplicate rows (defensive; structurally unreachable via the real `Map`-typed API but enforced).

Files read: `.../sheets-view/src/lib.rs` (`render_positions`, `POSITIONS_HEADER`, `fmt_ppm`), `.../sheets-view/tests/formula.rs` (formula-column tests, row-anchoring test, percent-numeric-coercion test).