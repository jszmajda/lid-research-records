Looking at the two files, I can reconstruct the EARS-style requirements for the estimated tax rate cell's encoding and consumption by formulas.

## EARS Spec: Estimated Tax Rate Cell Behavior

**SHEET-TAX-RATE-001:** Est. Tax Rate cell is an engine-written **value** (never a live formula), sourced from the `tax` crate's computed per-symbol effective unrealized rate (`UnrealizedEstimate.effective_rate_ppm`).

**SHEET-TAX-RATE-002:** When a symbol has no computed effective rate (rate lookup missing or degraded), the cell renders as an empty string; no error marker, no fallback numeric.

**SHEET-TAX-RATE-003:** The cell is formatted as a percent literal with exactly four fractional digits: `{whole}.{frac:04}%`, where `whole = ppm / 10_000` and `frac = ppm % 10_000`. Negative rates preserve the sign prefix (e.g., `"-5.0000%"`).

**SHEET-TAX-RATE-004:** The cell MUST be written via the Sheets API as a `userEnteredValue` (not `stringValue`), so Sheets parses `"20.0000%"` identically to user-typed input — a numeric fraction `0.20` with percentage number-format.

**SHEET-TAX-RATE-005:** This numeric parsing is load-bearing: the post-tax estimate columns (H) are consumed by row-anchored formulas `=G*H` (Est. Unrealized Tax) and `=G*(1-H)` (Net Unrealized), where G is Unrealized P&L. The formulas depend on H coercing to a dimensionless fraction in [0, 1], never text or a percentage points value.

**SHEET-TAX-RATE-006:** For any symbol with a populated rate cell, the resulting fraction must satisfy: `(pre-tax) × (fraction) + (pre-tax) × (1 - fraction) = pre-tax`, and a positive rate must yield a positive tax estimate.

**SHEET-TAX-RATE-007:** The cell is always present (one column per row, no ragged structure); an empty cell is valid and distinct from missing/malformed.

---

{scratch}/audit-P-FORMULA-005