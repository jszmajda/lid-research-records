EARS requirements for the estimated tax rate cell (Positions tab, column H `Est. Tax Rate`):

**P-FORMULA-005-a (ubiquitous).** The Positions view tab SHALL carry the column header row `["Symbol","Shares","Avg Cost/Share","Total Basis","Price","Market Value","Unrealized P&L","Est. Tax Rate","Est. Unrealized Tax (est)","Net Unrealized (est)","Unrealized %","Realized P&L","Quote Date"]`, placing `Est. Tax Rate` at zero-based index 7 (spreadsheet column H), between `Unrealized P&L` (G) and `Est. Unrealized Tax (est)` (I).

**P-FORMULA-005-b (ubiquitous).** The `Est. Tax Rate` cell SHALL be an engine-written **value** (`Cell::Value`), never a live formula — it is `tax`'s per-position `effective_rate_ppm`, not a sheet computation. `sheets-view` SHALL perform no rate math.

**P-FORMULA-005-c (event-driven).** WHEN rendering a position row for symbol S, IF `effective_rates` contains S, THEN the `Est. Tax Rate` cell SHALL be the `Ppm` rendered as a percent literal: sign prefix `-` when negative, then `|ppm| / 10_000` as integer percent, `.`, then `|ppm| % 10_000` zero-padded to exactly 4 digits, then `%` (e.g. `Ppm(150_000)` → `"15.0000%"`, `Ppm(200_000)` → `"20.0000%"`). Exactly 4 fractional digits always; no trimming.

**P-FORMULA-005-d (event-driven / degraded).** WHEN rendering a position row for symbol S, IF `effective_rates` has no entry for S (degraded estimate), THEN the `Est. Tax Rate` cell SHALL be the empty string `""` (a value, not a formula, not an error), and the post-tax columns SHALL degrade to the pre-tax figure via Sheets' empty-cell-as-0 coercion.

**P-FORMULA-005-e (ubiquitous, consumption).** For a data row at 1-based sheet row `r = index + DATA_START_ROW` (DATA_START_ROW = 2, beneath the frozen header at row 1), `Est. Unrealized Tax (est)` SHALL be the formula `=G{r}*H{r}` and `Net Unrealized (est)` SHALL be `=G{r}*(1-H{r})`, each referencing only its own row's cells and no other data row's number.

**P-FORMULA-005-f (unwanted behavior / typing contract).** The `Est. Tax Rate` cell SHALL be written through `batch_update_view` as a Sheets `userEnteredValue` — NOT a forced `stringValue` — so a percent-suffixed literal such as `"20.0000%"` is parsed as the numeric fraction `0.20` with a percent number-format. IF it were written as inert text, `=G*H` would yield 0 or an error; therefore the client MUST NOT force string typing.

**P-FORMULA-005-g (state-driven invariant).** WHILE a rate is populated, its coerced fraction (`percent_body / 100`) SHALL be finite and within `[0.0, 1.0]`, and SHALL satisfy `G*H + G*(1-H) == G` (post-tax split exhausts pre-tax), with a positive rate yielding a positive estimated tax.