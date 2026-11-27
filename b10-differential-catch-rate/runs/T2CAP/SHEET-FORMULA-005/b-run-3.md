SHEET-VIEW-RATE (Est. Tax Rate cell — write encoding and formula consumption)

1. Ubiquitous — column identity. The Positions view tab SHALL carry exactly the header `["Symbol","Shares","Avg Cost/Share","Total Basis","Price","Market Value","Unrealized P&L","Est. Tax Rate","Est. Unrealized Tax (est)","Net Unrealized (est)","Unrealized %","Realized P&L","Quote Date"]`, placing `Est. Tax Rate` at index 7 (spreadsheet column H), `Unrealized P&L` at index 6 (column G), `Est. Unrealized Tax (est)` at 8 (I) and `Net Unrealized (est)` at 9 (J).

2. Ubiquitous — cell kind. The `Est. Tax Rate` cell SHALL be an engine `Value` (never a `Formula`), sourced from `tax`'s per-position `effective_rate_ppm`. `sheets-view` performs no tax math on it.

3. Event-driven — rate present. WHEN rendering Positions and `effective_rates` contains the row's symbol, the system SHALL write the rate as a percent literal formatted from `Ppm` as `{sign}{ppm/10_000}.{ppm%10_000:04}%` (e.g. `Ppm(200_000)` → `"20.0000%"`, `Ppm(150_000)` → `"15.0000%"`): fixed 4 fractional digits, leading `-` for negative ppm, always a trailing `%`.

4. Event-driven — rate absent. WHEN the symbol is absent from `effective_rates` (degraded estimate), the system SHALL write the empty string in `Est. Tax Rate`; the post-tax formulas then degrade to the pre-tax figure (Sheets coerces empty to 0, so `=G*H`→0 and `=G*(1-H)`→G).

5. Ubiquitous — write typing (client contract). A `Cell::Value` SHALL be written as a Sheets `userEnteredValue`, not a forced `stringValue`, so `"20.0000%"` is parsed as the numeric fraction 0.20 with a percent number-format. The rate cell MUST coerce to a number, never inert text.

6. Ubiquitous — consuming formulas, row-anchored. For data row r (r = row_index + `DATA_START_ROW`, `DATA_START_ROW` = 2, beneath the frozen header at row 1), the system SHALL emit `Est. Unrealized Tax (est)` = `=G{r}*H{r}` and `Net Unrealized (est)` = `=G{r}*(1-H{r})`, referencing only that row's cells and no other data row's number.

7. Ubiquitous — algebraic invariant. Given the rate's fraction f = percent_body/100, the pair SHALL satisfy `G*f + G*(1-f) == G`; f SHALL be finite and within [0.0, 1.0], and a positive f with positive G yields a positive estimated tax.

8. Unwanted-behavior. The `Est. Tax Rate` cell SHALL NOT be a live formula, and the Tax tab (accrual and reserve-summary bands) SHALL contain no formula cells at all.