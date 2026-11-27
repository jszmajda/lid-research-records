**Concern: the "Est. Tax Rate" cell (Positions col H) — how it's written and how the post-tax formulas consume it.**

**Ubiquitous:**
- SHEET-POS-TAXRATE-01: The Positions "Est. Tax Rate" column SHALL be written as an engine `Cell::Value` (never `Cell::Formula`), sourced from the per-symbol effective unrealized tax rate (`Ppm`) supplied by `tax`.
- SHEET-POS-TAXRATE-02: A `Cell::Value` SHALL be written to the sheet as a `userEnteredValue` (never a forced/string value), so Sheets parses it exactly as a human-typed entry would.

**Event-driven:**
- SHEET-POS-TAXRATE-03: WHEN a symbol has an entry in the effective-rates map, the system SHALL render its `Ppm` as `"{sign}{whole}.{frac:04}%"`, where `sign` = `"-"` iff the ppm value is negative, `whole` = `|ppm| / 10_000` (integer division), `frac` = `|ppm| % 10_000` zero-padded to exactly 4 digits (e.g. `Ppm(150_000)` → `"15.0000%"`).
- SHEET-POS-TAXRATE-04: WHEN a symbol is absent from the effective-rates map (degraded estimate), the system SHALL render the cell as the empty string `""` (not zero, not an error marker).
- SHEET-POS-TAXRATE-05: WHEN Sheets parses a percent-suffixed value string (e.g. `"20.0000%"`), it SHALL coerce it to the numeric fraction `value/100` (e.g. `0.20`) under a percent number format, never inert text.

**Consuming formulas (state/row-driven):**
- SHEET-POS-TAXRATE-06: The "Est. Unrealized Tax (est)" cell on row r SHALL be the formula `=G{r}*H{r}`.
- SHEET-POS-TAXRATE-07: The "Net Unrealized (est)" cell on row r SHALL be the formula `=G{r}*(1-H{r})`.
- SHEET-POS-TAXRATE-08: Both formulas SHALL reference only their own row r's G and H cells; a formula on row r SHALL NOT contain any other row's cell reference (verified per-row against every other row number present).

**Boundary / unwanted behavior:**
- SHEET-POS-TAXRATE-09: The rate, interpreted as `text-without-% / 100`, SHALL be a finite number in `[0, 1]` — never NaN or out-of-range — so `G*H` and `G*(1-H)` sum to `G`.
- SHEET-POS-TAXRATE-10: IF the Est. Tax Rate cell were written as a forced string type THEN `=G*H`/`=G*(1-H)` would fail to coerce to a number (0/error) — this SHALL NOT occur; value-typing (TAXRATE-02) is required to prevent it.

Source: `resolve`/`render_positions` (H = `eff_rate.map(fmt_ppm).unwrap_or_default()`), `fmt_ppm`, `price_formula`/formula strings in `render_positions`; pinned by `formula.rs` tests `live_price_columns_are_formulas_others_are_values`, `per_row_formulas_reference_their_own_row_beneath_frozen_header`, `positions_shows_pretax_and_live_posttax_estimate`, `est_tax_rate_cell_is_numeric_percent_the_posttax_formulas_can_multiply`.