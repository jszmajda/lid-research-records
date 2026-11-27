**Reconstructed EARS requirements — Est. Tax Rate cell (write + formula consumption)**

**Ubiquitous:**
1. The system SHALL render the Positions tab's "Est. Tax Rate" column as `Cell::Value` (an engine-written value), never `Cell::Formula`.
2. When a per-symbol effective unrealized tax rate (`Ppm`) is present, the system SHALL format it as `"{sign}{whole}.{frac:04}%"`, where `whole = |ppm| / 10_000`, `frac = |ppm| % 10_000` zero-padded to exactly 4 digits, and `sign` is `"-"` iff the ppm value is negative (no `"+"` for non-negative).
3. The system SHALL write the Est. Tax Rate cell via the sheets client as a `userEnteredValue` (never a forced `stringValue`), so a percent-suffixed literal (e.g. `"20.0000%"`) is parsed by Sheets exactly as a human-typed entry would be: the numeric fraction `value/100` (e.g. `0.20`) carrying a percent number format — never inert text.
4. The system SHALL compute "Est. Unrealized Tax (est)" as the row-anchored formula `=G{r}*H{r}` and "Net Unrealized (est)" as `=G{r}*(1-H{r})`, where `r` is that row's own 1-based row number, `G` is that row's Unrealized P&L and `H` is that row's Est. Tax Rate — referencing only cells on the row being rendered.

**Event-driven:**
5. WHEN a symbol is absent from the effective-rates map (a degraded tax estimate), the system SHALL render its Est. Tax Rate cell as an empty-string `Value` (not `"0.0000%"`, not omitted, not a formula) — causing the dependent formulas to evaluate with the rate coerced to 0: Est. Unrealized Tax (est) evaluates to 0 and Net Unrealized (est) evaluates to the pre-tax Unrealized P&L unchanged.
6. WHEN the effective rate is present, the rendered percent string SHALL, on Sheets' percent-to-fraction coercion, yield a finite fraction in the closed range `[0, 1]`.

**Unwanted-behavior:**
7. IF the Est. Tax Rate cell were written as a forced string type instead of a coercible `userEnteredValue`, THEN `=G*H` and `=G*(1-H)` would multiply against inert text (yielding 0/error) rather than the intended rate — the system SHALL NOT do this.

Not independently specified elsewhere in these two files: no bounds/validation on the rate at write time beyond the format above (out-of-range ppm is not tested); no requirement fixes column letters other than by position (`G`=Unrealized P&L, `H`=Est. Tax Rate) as a byproduct of `POSITIONS_HEADER` order.