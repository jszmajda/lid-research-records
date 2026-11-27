**Scope note:** The Tax tab itself (`render_tax`) carries NO tax-*adjusted* computed figures — it is pinned to be kernel-exact pass-through. The only tax-adjusted *estimate* computation in these files is on the Positions tab (post-tax columns, fed by `tax`'s effective rate). Both are reconstructed below.

**Tax tab (accrual band + reserve-summary band):**

1. (Ubiquitous) The system shall render every cell in both the Tax accrual band and the Tax reserve-summary band as an engine `Cell::Value` — never a `Cell::Formula` — since both are kernel-exact, as-of-last-sync figures, distinct from Positions' live estimate.
2. (Ubiquitous) The accrual band shall contain exactly one row per `Accrual` under header `[Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State]`, row width equal to header width, with no blank/label/embedded-second-header rows among the data.
3. (State-driven) WHILE an accrual's `applied_cents` is present, the Amount cell shall render `fmt_cents` (sign + `whole.frac` with frac zero-padded to 2 digits); WHILE absent, Amount shall render the empty string.
4. (Ubiquitous) Jurisdiction shall render `"Federal"` or `"State({code})"`; Lifecycle State shall render one of `"Accrued"|"Allocated"|"Moved"|"Paid"`.
5. (Ubiquitous) The reserve-summary band shall be a structurally distinct range (own name, own header `[Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall]`), one row per `(Jurisdiction, Tax Year)` `AnnualRow`, never nested inside the accrual band.
6. (Ubiquitous) All five reserve-summary figures (Accrued, Moved, Paid, Outstanding, Shortfall) shall be the kernel-exact `AnnualRow` values via `fmt_cents`, and none shall be blank, even when zero.

**Positions tab post-tax estimate columns (the actual tax-adjusted figures):**

7. (Ubiquitous) "Est. Tax Rate" shall render as a `Value` percent-suffixed string via `fmt_ppm`: `ppm/10_000` whole, `ppm%10_000` as a 4-digit-padded fraction, suffixed `%` (e.g. `"20.0000%"`) — written as `userEnteredValue` so Sheets coerces it to numeric fraction `[0,1]`, never inert text.
8. (State-driven) WHILE a symbol is absent from `effective_rates`, Est. Tax Rate shall render empty.
9. (Ubiquitous) On each row `r`: "Est. Unrealized Tax (est)" = formula `=G{r}*H{r}`; "Net Unrealized (est)" = formula `=G{r}*(1-H{r})`; "Unrealized %" = `=IF(D{r}=0,0,G{r}/D{r})`. Each formula references only its own row's cells, never another data row's.