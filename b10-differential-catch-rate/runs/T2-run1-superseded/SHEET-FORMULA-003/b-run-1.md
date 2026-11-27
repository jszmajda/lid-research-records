**Reconstructed EARS requirements — Positions pre-tax/post-tax unrealized presentation**

**Ubiquitous**

1. The Positions tab SHALL present a pre-tax "Unrealized P&L" column (header, no "(est)" suffix) as a live `Cell::Formula`: `=F{r}-D{r}` (Market Value − Total Basis), anchored to its own row `r`.

2. The Positions tab SHALL present two post-tax columns, headers labelled as estimates — "Est. Unrealized Tax (est)" and "Net Unrealized (est)" — as live `Cell::Formula`s:
   - Est. Unrealized Tax = `=G{r}*H{r}` (Unrealized P&L × Est. Tax Rate)
   - Net Unrealized = `=G{r}*(1-H{r})` (Unrealized P&L × (1 − Est. Tax Rate))
   Both MUST use the literal `1-` form (not `1 -` collapsed differently) and reference only row `r`.

3. Every live-price-dependent Positions formula (Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %) SHALL reference only its own data row's cell addresses and MUST NOT contain any other data row's cell address (prevents row-shift mispairing).

4. "Est. Tax Rate" SHALL always be an engine-written `Cell::Value` (never `Cell::Formula`), sourced from `tax`'s per-symbol `effective_rate_ppm`; all other named cells in the group above (Symbol, Shares, Avg Cost/Share, Total Basis, Realized P&L) are likewise engine values, not formulas.

5. When present, the Est. Tax Rate value SHALL be formatted `"{whole}.{frac:04}%"` — a percent-suffixed decimal with exactly 4 fraction digits (e.g. `"20.0000%"`) — and written as a `userEnteredValue` (not a forced string), so Sheets coerces it to the numeric fraction in `[0,1]` with a percent format, which the post-tax formulas (`=G*H`, `=G*(1-H)`) multiply as a number.

6. The Positions tab SHALL also present "Unrealized %" as `=IF(D{r}=0,0,G{r}/D{r})` — a pre-tax ratio guarded against division by zero (returns 0 when Total Basis is 0), row-anchored.

**State-driven**

7. WHILE a symbol is absent from `effective_rates` (degraded tax estimate), the Est. Tax Rate cell SHALL render as an empty string (never a placeholder or error), and the post-tax formulas — still `=G*H`/`=G*(1-H)` referencing the blank H — SHALL degrade to the pre-tax figure (H coerces to 0: Est. Unrealized Tax → 0, Net Unrealized → Unrealized P&L).

**Unwanted-behavior**

8. The two post-tax formulas SHALL be complementary for any rate fraction `H`: `G*H + G*(1-H) == G`, with no unaccounted remainder.

No numeric constants beyond the 4-decimal percent format and the fixed column letters (D,E,F,G,H) are pinned; no explicit error path exists for the pre/post-tax formulas themselves (only `Est. Tax Rate` has degrade behavior).