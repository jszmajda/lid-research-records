**EARS-style requirements enforced by this code for pre-tax/post-tax unrealized presentation on Positions:**

1. **Ubiquitous.** The Positions tab SHALL present, per symbol, a pre-tax "Unrealized P&L" figure alongside two post-tax estimate figures, "Est. Unrealized Tax (est)" and "Net Unrealized (est)"; both post-tax column headers SHALL carry the literal "(est)" suffix labeling them as estimates, distinct from the exact pre-tax figure.

2. **Event-driven.** WHEN a Positions row is rendered, the system SHALL emit "Unrealized P&L" as a live formula equal to (this row's Market Value cell) − (this row's Total Basis cell), referencing only cells on its own row.

3. **Event-driven.** WHEN a Positions row is rendered, the system SHALL emit "Est. Unrealized Tax (est)" as a live formula equal to (this row's Unrealized P&L cell) × (this row's Est. Tax Rate cell), and "Net Unrealized (est)" as a live formula equal to (this row's Unrealized P&L cell) × (1 − this row's Est. Tax Rate cell); both formulas SHALL reference only cells on their own row.

4. **Event-driven.** WHEN a Positions row is rendered, the system SHALL emit "Unrealized %" as a live formula yielding 0 if Total Basis is 0, else Unrealized P&L ÷ Total Basis.

5. **State-driven.** WHILE a symbol has no computed effective unrealized-tax rate (absent from the effective-rates map — a degraded estimate), the Est. Tax Rate cell SHALL render as an empty value (never 0, never an error string); this SHALL cause "Net Unrealized (est)" to evaluate equal to the pre-tax "Unrealized P&L" and "Est. Unrealized Tax (est)" to evaluate to 0 — the post-tax columns degrade to the pre-tax figure.

6. **Ubiquitous.** When present, the Est. Tax Rate value SHALL be formatted as a percent-suffixed decimal string with exactly four fractional digits (e.g. "20.0000%": whole-percent = ppm/10000, fraction = ppm mod 10000 zero-padded to 4 digits, sign preserved for negative rates), and SHALL be written as a Sheets `userEnteredValue` (never a forced/string value) so Sheets coerces it to the numeric fraction (rate/100) rather than inert text — required for the multiplying formulas in (3) to evaluate numerically instead of to 0/error.

7. **Unwanted behavior.** IF the "Unrealized P&L", "Est. Unrealized Tax (est)", "Net Unrealized (est)", or "Unrealized %" formula on a given row referenced any other data row's cell number, THEN this SHALL NOT occur (row-number leakage/mis-pairing across rows is prohibited).

8. **Ubiquitous.** Data rows begin at row 2 (row 1 is the frozen header), and each row's formulas are anchored to that row's own number accordingly.