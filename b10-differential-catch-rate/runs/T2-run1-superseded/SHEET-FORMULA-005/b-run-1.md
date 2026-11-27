Reconstructed EARS requirements — sheets-view "Est. Tax Rate" cell (write + consumption):

**Ubiquitous**

- SHEET-TAXRATE-001: The Positions tab's "Est. Tax Rate" column (column H, the 8th header entry, 0-indexed offset 7) shall always be rendered as `Cell::Value`, never `Cell::Formula`.
- SHEET-TAXRATE-002: A present effective rate (`Ppm`) shall be formatted as `{sign}{whole}.{frac:04}%`, where `whole = |ppm| / 10_000`, `frac = |ppm| % 10_000` zero-padded to 4 digits, and `sign` is `"-"` for negative ppm else empty (e.g., `Ppm(150_000)` → `"15.0000%"`).
- SHEET-TAXRATE-003: `Cell::Value` cells (including Est. Tax Rate) shall be written to the sheet as `userEnteredValue`, never a forced `stringValue`, so Sheets parses a percent-suffixed literal (e.g. `"20.0000%"`) as the numeric fraction (0.20) with a percent number-format, not inert text.
- SHEET-TAXRATE-004: The two post-tax estimate formulas on row r shall be `Est. Unrealized Tax = G{r}*H{r}` and `Net Unrealized = G{r}*(1-H{r})`, referencing only row r's own Unrealized-P&L (G) and Est.-Tax-Rate (H) cells — never any other row's G/H (verified per-row against every other rendered row).
- SHEET-TAXRATE-005: Data rows begin at `DATA_START_ROW = 2` (1-based), directly beneath the frozen header row.

**Event-driven**

- SHEET-TAXRATE-006: WHEN rendering a position's row and the symbol is present in `effective_rates`, the system shall write that rate's `fmt_ppm` string into the Est. Tax Rate cell.

**State/unwanted-behavior**

- SHEET-TAXRATE-007: IF a symbol is absent from `effective_rates` (a degraded estimate), THEN the Est. Tax Rate cell shall be written as an empty string (`Cell::Value("")`) — never omitted, never an error marker, never a formula.

**Pinned invariant (test-only, not source-commented)**: for a populated rate, the formatted string must end in `%`; stripping `%` and dividing by 100 must yield a finite fraction in `[0.0, 1.0]`; and, algebraically, `G*H + G*(1-H) == G` — i.e., the est-tax and net-unrealized formulas exactly partition pre-tax Unrealized P&L for any valid rate.

Source: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs` (`fmt_ppm`, `render_positions`, `batch_update_view` doc contract) and `{scratch}/audit-baseline/crates/sheets-view/tests/formula.rs` (`live_price_columns_are_formulas_others_are_values`, `per_row_formulas_reference_their_own_row_beneath_frozen_header`, `positions_shows_pretax_and_live_posttax_estimate`, `est_tax_rate_cell_is_numeric_percent_the_posttax_formulas_can_multiply`).