# Reconstructed EARS Requirements — Est. Tax Rate Cell (Positions Tab)

**SHEET-POS-EST-RATE-001 (Ubiquitous)**
The Positions tab's "Est. Tax Rate" column (H) shall be written as an engine `Cell::Value`, never a `Cell::Formula`.

**SHEET-POS-EST-RATE-002 (Ubiquitous — format)**
When a symbol has an entry in the effective-rates map (a `Ppm`), the system shall format it as `"{sign}{whole}.{frac:04}%"` where `sign` = `"-"` iff the ppm value is negative, `whole = |ppm| / 10_000`, `frac = |ppm| % 10_000` zero-padded to 4 digits (e.g. `Ppm(150_000)` → `"15.0000%"`).

**SHEET-POS-EST-RATE-003 (Event-driven)**
WHEN a position's symbol is absent from the effective-rates map (a degraded estimate), the system shall write the empty string `""` to "Est. Tax Rate" for that row — never a formula, a zero, or error text.

**SHEET-POS-EST-RATE-004 (Ubiquitous — encoding contract)**
The "Est. Tax Rate" `Cell::Value` shall be written to Sheets as a `userEnteredValue` (never a forced/`stringValue`), so that a populated cell such as `"20.0000%"` is parsed by Sheets exactly as a human-typed percent literal: the numeric fraction `0.20` under a percent number format, coercing to a real number rather than inert text.

**SHEET-POS-EST-RATE-005 (Ubiquitous — consumers)**
On each data row r, "Est. Unrealized Tax (est)" (col I) shall be the row-anchored formula `=G{r}*H{r}` (Unrealized P&L × Est. Tax Rate), and "Net Unrealized (est)" (col J) shall be `=G{r}*(1-H{r})` (Unrealized P&L × (1 − Est. Tax Rate)). Each formula shall reference only its own row's G and H cells, never any other row's.

**SHEET-POS-EST-RATE-006 (Ubiquitous — test-pinned invariant)**
A populated "Est. Tax Rate" value, read as `"X%"` and divided by 100, shall parse as a finite fraction in `[0, 1.0]`. Given such a fraction, `Est. Unrealized Tax (G×H) + Net Unrealized (G×(1−H))` shall equal `Unrealized P&L (G)` exactly.

**SHEET-POS-EST-RATE-007 (Unwanted behavior — degraded state)**
IF a row's "Est. Tax Rate" is blank (degraded estimate), WHEN Sheets evaluates the I/J formulas against that blank H, THEN the result shall be equivalent to H=0: "Est. Unrealized Tax" = 0 and "Net Unrealized" = the pre-tax Unrealized P&L (G) — not an error and not non-numeric.

Source: `render_positions` (src/lib.rs lines ~561–591, `fmt_ppm` lines 496–505, doc comments lines 439–445), and `tests/formula.rs::est_tax_rate_cell_is_numeric_percent_the_posttax_formulas_can_multiply` / `positions_shows_pretax_and_live_posttax_estimate` / `per_row_formulas_reference_their_own_row_beneath_frozen_header`.