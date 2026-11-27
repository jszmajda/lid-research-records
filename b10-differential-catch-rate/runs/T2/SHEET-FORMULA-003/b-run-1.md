**Ubiquitous:**
- The system shall render the Positions "Unrealized P&L" column as a live formula `=F{r}-D{r}` (Market Value − Total Basis) on the position's own row — the pre-tax figure.
- The system shall render "Est. Tax Rate" as an engine-computed value (never a formula): the `tax`-supplied per-symbol effective unrealized rate (`Ppm`), formatted `"{whole}.{frac:04}%"` (4 fractional digits, e.g. `Ppm(150_000)` → `"15.0000%"`), written so Sheets parses it as the numeric fraction (e.g. 0.20) with a percent format — never as inert text — because the post-tax formulas multiply it directly.
- The system shall render "Est. Unrealized Tax (est)" as the live formula `=G{r}*H{r}` (Unrealized P&L × Est. Tax Rate).
- The system shall render "Net Unrealized (est)" as the live formula `=G{r}*(1-H{r})` (Unrealized P&L × (1 − Est. Tax Rate)); algebraically Est. Unrealized Tax + Net Unrealized equals pre-tax Unrealized P&L.
- The system shall render "Unrealized %" as `=IF(D{r}=0,0,G{r}/D{r})`, returning 0 rather than a division error when Total Basis is 0.
- The header shall label both post-tax columns with an "(est)" suffix, distinguishing them from the un-suffixed pre-tax "Unrealized P&L".
- Every formula on a data row shall reference only that same row's own cells (`r`), never another data row's cell address, so a row insertion/reorder cannot mis-pair figures.
- Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), and Unrealized % shall be `Cell::Formula`; Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L shall be `Cell::Value`.

**State-driven:**
- WHILE a symbol is absent from `effective_rates` (degraded tax estimate), the system shall render Est. Tax Rate as an empty string; the unmodified `=G*H` / `=G*(1-H)` formulas then evaluate against an empty (0-coercing) H, so Est. Unrealized Tax (est) reduces to 0 and Net Unrealized (est) reduces to the pre-tax Unrealized P&L value.

**Unwanted behavior:**
- IF `Snapshot.positions` contains two rows for the same symbol, THEN `render_positions` shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit a second row (defensive; structurally unreachable via the real `Map<Symbol,_>` source, but pinned as a loud guard).

Files read: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs`, `.../crates/sheets-view/tests/formula.rs`.