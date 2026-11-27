Based solely on `render_tax`, `TaxView`, `TAX_RESERVE_HEADER`/`TAX_RESERVE_TAB`, `fmt_cents`, `jurisdiction_label`, and the tests `tax_tab_is_kernel_exact_not_live_formula` and `reserve_summary_carries_all_five_kernel_exact_columns`:

**Ubiquitous — data source & shape**
The system shall populate the Tax tab's reserve-summary band with exactly one row per element of the `annual_rows: &[tax::AnnualRow]` slice passed to `render_tax`, preserving input order (no sort/group/dedupe), and shall NOT derive these rows from the `accruals: &[Accrual]` parameter (that parameter feeds only the separate accrual band).

**Ubiquitous — column-to-field mapping**
For each reserve-summary row the system shall populate, verbatim from the corresponding `AnnualRow`, exactly these five columns in this order: `Accrued` ← `accrued_cents`, `Moved` ← `moved_cents`, `Paid` ← `paid_cents`, `Outstanding` ← `outstanding_cents`, `Shortfall` ← `shortfall_cents` — plus `Jurisdiction` ← `jurisdiction` and `Tax Year` ← `tax_year`. No column is computed, re-derived, or re-aggregated by `sheets-view` from any other value.

**Ubiquitous — formatting**
Each of the five monetary columns shall be rendered via the shared cents-to-string formatter: sign prefix (`-` only if negative, none if non-negative), then `{whole}.{fractional:02}` where whole = `abs(cents)/100` and fractional = `abs(cents)%100` (e.g. `Cents(5000)` → `"50.00"`). `Jurisdiction` shall render `Federal` as the literal `"Federal"` and `State(code)` as `"State({code})"`. `Tax Year` shall render as the bare integer string of `tax_year.0`.

**Ubiquitous — value typing, not live**
Every cell in both the accrual band and the reserve-summary band, including all five reserve-summary figures, shall be an engine-computed `Cell::Value`; the system shall never render any Tax-tab cell (accrual or reserve-summary) as a `Cell::Formula` — the Tax tab carries no live-price dependency, unlike Positions.

**Unwanted behavior — no blank figures**
IF an `AnnualRow` is present for a `(Jurisdiction, Tax Year)`, THEN the system shall render all five of its Accrued/Moved/Paid/Outstanding/Shortfall cells as non-empty formatted strings — none of the five shall ever render as an empty string (an all-zero figure still renders as `"0.00"`, not blank).

**Event-driven — row count**
WHEN `render_tax` is called with N `annual_rows`, the system shall emit exactly N reserve-summary rows (`reserve_summary.rows.len() == annual_rows.len()`), each keyed for lookup by its `(Jurisdiction, Tax Year)` pair.