**P-FORMULA-005: Estimated Tax Rate Cell and Post-Tax Formulas**

The Estimated Tax Rate cell (column H, Positions tab) encodes the tax-written effective unrealized rate for live post-tax estimate formulas.

**[ubiquitous]** The cell is a **value, never a formula**. Formatted as percent-suffixed numeric with exactly 4 decimal places: `{whole}.{frac:04}%` where `whole = ppm / 10_000`, `frac = ppm % 10_000`. Source: `tax`'s `effective_unrealized_rate_ppm` (Ppm) per symbol, looked up in `effective_rates: &BTreeMap<Symbol, Ppm>`. If a symbol has no computed rate (degraded estimate), the cell is empty string.

**[state-driven]** Written as `Cell::Value` via `SheetsViewClient::batch_update_view()` contract: a `userEnteredValue` (not forced text), so Sheets parses "X%" exactly as a human would type it—the numeric fraction X/100 with percent number-format. This allows direct multiplication in dependent formulas.

**[state-driven]** Two post-tax estimate formulas multiply the rate cell on the same row:
- Est. Unrealized Tax (column I): `=G*H` (Unrealized P&L × Est. Tax Rate)
- Net Unrealized (column J): `=G*(1-H)` (Unrealized P&L × (1 − Est. Tax Rate))

**[state-driven]** For any row with a populated rate (cell H ≠ ""), the invariant `(G*H) + (G*(1-H)) = G` holds: tax and net sum to pre-tax. The numeric fraction (coerced from percent) is finite and in the range [0.0, 1.0]; negative or non-finite rates are never rendered.

**[boundary]** Empty-cell handling: post-tax columns degrade to pre-tax when the rate is absent (formula falls back to single-column reference if rate column is blank, per formula structure).