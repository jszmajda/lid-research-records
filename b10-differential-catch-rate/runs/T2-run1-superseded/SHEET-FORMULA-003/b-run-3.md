**EARS requirements enforced (Positions tab: pre-tax vs. post-tax unrealized presentation)**

**Ubiquitous**
- U1: The Positions tab SHALL render "Unrealized P&L" (col G) as a live formula `=F{r}-D{r}` (Market Value − Total Basis) on its own row.
- U2: The Positions tab SHALL render two post-tax *estimate* columns, headered exactly "Est. Unrealized Tax (est)" and "Net Unrealized (est)": `=G{r}*H{r}` (Unrealized P&L × Est. Tax Rate) and `=G{r}*(1-H{r})` (Unrealized P&L × (1 − Est. Tax Rate)), respectively, distinguishing them from the un-suffixed pre-tax "Unrealized P&L" column.
- U3: The Positions tab SHALL render "Unrealized %" (col K) as `=IF(D{r}=0,0,G{r}/D{r})` — literal 0 when Total Basis is zero (divide-by-zero boundary).
- U4: Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), and Unrealized % SHALL be `Cell::Formula`; Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L SHALL be `Cell::Value`.
- U5: Every per-row formula SHALL reference only cells on its own row (row `r` = row-index + `DATA_START_ROW`(2)); it SHALL NOT contain any other data row's number.
- U6: "Est. Tax Rate" SHALL be rendered as a percent-suffixed value string `{sign}{whole}.{frac:04}%`, where whole = |ppm|/10_000 and frac = |ppm|%10_000 zero-padded to 4 digits (e.g. `Ppm(150_000)` → `"15.0000%"`), and SHALL be written as a Sheets `userEnteredValue` (never a forced string) so it is parsed as the numeric fraction (e.g. "20.0000%"→0.20) that `=G*H` / `=G*(1-H)` require to coerce correctly rather than error/zero on text.

**State-driven**
- S1: WHILE a symbol is absent from the `effective_rates` map (its tax-effective-rate estimate is degraded), the Positions render SHALL leave "Est. Tax Rate" as an empty string (not "0.0000%", not an error). Consequence pinned by formula construction: Sheets coerces the blank H cell to 0, so "Est. Unrealized Tax (est)" evaluates to 0 and "Net Unrealized (est)" evaluates to exactly the pre-tax Unrealized P&L value (G×(1−0)=G) — i.e., the post-tax net figure silently degrades to the pre-tax figure while the tax-amount figure degrades to zero.

No unwanted-behavior/error pattern is pinned specifically for this concern (the `DuplicateSymbolRow` guard governs row identity generally, not pre/post-tax computation).