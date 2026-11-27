**P-FORMULA-005: Estimated Tax Rate Cell Write & Formula Consumption**

**[x] P-FORMULA-005-A: Cell Type & Encoding**
The `Est. Tax Rate` column (Positions tab, column H) is written as a `Cell::Value` (engine-computed, not a formula). The value is a percent-suffixed string formatted by `fmt_ppm(Ppm)` to the pattern `SIGN WHOLE.FRAC%`, where WHOLE is ppm÷10_000, FRAC is (ppm mod 10_000) zero-padded to 4 digits, and SIGN is "-" for negative rates or "" for non-negative. Example: `Ppm(150_000)` → `"15.0000%"`. Sheets parses a `userEnteredValue` text string ending in `%` as a numeric percentage (the numeric value X/100 with percent number-format), not inert text.

**[x] P-FORMULA-005-B: Formula Consumption Contract**
The post-tax estimate columns (H: `Est. Unrealized Tax (est)` = `=G*H`, J: `Net Unrealized (est)` = `=G*(1-H)`) depend on the Est. Tax Rate cell (H) coercing to a numeric fraction in [0, 1]. The two formulas must satisfy the identity `=G*H + G*(1-H) == G` (the pre-tax P&L decomposes as tax plus net). A non-numeric H (text) would yield a zero or error, violating the contract.

**[x] P-FORMULA-005-C: Value Range & Validation**
The effective tax rate is a `Ppm` value (parts per million, signed 64-bit integer from the tax crate). When formatted, it represents a real tax rate in the range [0, 1] as a fraction. No rate clipping occurs; negative rates are formatted as-is (e.g., `Ppm(-50_000)` → `"-5.0000%"`). Sheets' numeric coercion parses the result as a decimal fraction and validates it as in-range for the formulas; out-of-range values (>100% or <-100%) render but are unexpected and warrant investigation.

**[x] P-FORMULA-005-D: Per-Row Formula Binding**
Each row's post-tax formulas reference **that row's own** Est. Tax Rate cell (by row number: `=G2*H2`, `=G3*H3`, etc.). Row numbers are computed as `(row_index as u32) + DATA_START_ROW`, where `DATA_START_ROW = 2` (row 1 is the frozen header). Formulas do NOT reference other rows' cells — a mismatched row number would corrupt the calculation. The invariant is enforced by the render loop, which computes `cell_ref('H', r)` once per row.

**[x] P-FORMULA-005-E: Degraded Estimate Semantics**
If a symbol has no computed effective unrealized tax rate (entry absent from `effective_rates: BTreeMap<Symbol, Ppm>`), the cell is written as an empty string. The post-tax estimate formulas (`=G*H`, `=G*(1-H)`) then evaluate to empty/zero (depending on Sheets' handling of an empty multiplicand); the post-tax estimate columns degrade to match the pre-tax figure or render blank, but the Positions row itself remains visible and navigable — no double-nulling of live market data.

**[x] P-FORMULA-005-F: No Formula Permitted**
The Est. Tax Rate cell is never a `Cell::Formula`. It is always a `Cell::Value` (or empty string value). Live post-tax formulas in columns I and J depend on H being a static, tax-kernel-written value that does not itself recalculate; if H were a formula, a future design change could introduce circular references or race conditions between the price-settle pass and tax-state updates.