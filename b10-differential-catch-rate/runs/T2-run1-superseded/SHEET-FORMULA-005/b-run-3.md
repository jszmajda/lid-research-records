**Concern: the "Est. Tax Rate" cell (Positions tab, column H) — how it's written and how the post-tax formulas consume it.**

**Ubiquitous — typing.** THE system SHALL render the "Est. Tax Rate" cell as an engine-written `Cell::Value`, never a `Cell::Formula`, for every position row.

**Ubiquitous — format.** WHEN a symbol has a computed effective rate (`Ppm`), THE system SHALL format it as `{sign}{whole}.{frac:04}%`, where `whole = |ppm|/10_000`, `frac = |ppm|%10_000` zero-padded to exactly 4 digits, and `sign` is `"-"` iff `ppm<0` (else empty) — always exactly 4 fractional digits before a literal `%` suffix (e.g. `Ppm(150_000)` → `"15.0000%"`).

**State-driven — degraded estimate.** WHILE a symbol is absent from the effective-rates map (its unrealized-tax estimate is degraded), THE system SHALL write Est. Tax Rate as the empty string — never omit the cell, never write an error token.

**Event-driven — formula generation.** WHEN rendering position row r (r ≥ `DATA_START_ROW`=2), THE system SHALL emit `Est. Unrealized Tax` (col I) = `"=G{r}*H{r}"` and `Net Unrealized (est)` (col J) = `"=G{r}*(1-H{r})"`, each referencing only row r's own G/H cells — never another data row's number (no cross-row leakage on shift).

**Unwanted-behavior — blank-rate degrade.** IF Est. Tax Rate (H) is blank (degraded symbol) THEN `=G*H` SHALL evaluate to 0 and `=G*(1-H)` SHALL evaluate to G unchanged — post-tax estimates degrade to (0, the pre-tax Unrealized P&L figure) rather than erroring, relying on Sheets coercing a blank referenced cell to 0 in arithmetic.

**Contract requirement (MUST, pinned by test).** THE Sheets-write implementation MUST write this `Cell::Value` as a Sheets `userEnteredValue` (never a forced string/`stringValue`), so a percent-suffixed literal such as `"20.0000%"` is parsed exactly as a human-typed entry: the numeric fraction `0.20` with a percent number format, coercing to a real number — never inert text — so `=G*H`/`=G*(1-H)` multiply correctly instead of yielding 0/error.

**Invariant on rate domain (pinned by test).** WHEN present, the rate's numeric percent ÷ 100 SHALL be a finite fraction in the closed range [0.0, 1.0] — never NaN or out-of-range — such that `G*H + G*(1-H) == G` holds.

Source: `crates/sheets-view/src/lib.rs` (`fmt_ppm`, `render_positions`, `SheetsViewClient::batch_update_view` doc) and `crates/sheets-view/tests/formula.rs` (`est_tax_rate_cell_is_numeric_percent_the_posttax_formulas_can_multiply`, `positions_shows_pretax_and_live_posttax_estimate`).