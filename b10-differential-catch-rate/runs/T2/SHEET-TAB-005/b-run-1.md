**EARS requirements enforced (Tax reserve-summary figure sourcing):**

1. **Ubiquitous — source of record.** The system shall populate the Tax view's reserve-summary band with exactly one row per element of the `tax::AnnualRow` slice passed to `render_tax`, in the order supplied (no reordering, filtering, or deduplication), such that `reserve_summary.rows.len() == annual_rows.len()`.

2. **Ubiquitous — kernel-exact values, no derivation.** For each reserve-summary row, the system shall render the Accrued, Moved, Paid, Outstanding, and Shortfall columns as the verbatim `accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, and `shortfall_cents` fields of the corresponding `AnnualRow` — `sheets-view` shall perform no computation, aggregation, or adjustment of these amounts itself.

3. **Ubiquitous — engine values, never formulas.** The system shall write every cell of the reserve-summary band (and the accrual band) as `Cell::Value`; it shall never write a `Cell::Formula` there — the reserve summary carries no live-price (`GOOGLEFINANCE`) dependency, unlike the Positions tab.

4. **Ubiquitous — Cents formatting.** The system shall format each Cents amount as `[-]<whole>.<hundredths>`, where the fractional part is exactly two digits, zero-padded, sign emitted only when the value is negative, and magnitude split via integer division/remainder by 100 (e.g., `Cents(15000)` → `"150.00"`).

5. **Ubiquitous — Jurisdiction label.** The system shall render `Jurisdiction::Federal` as the literal string `"Federal"` and `Jurisdiction::State(code)` as `"State({code})"`.

6. **Ubiquitous — Tax Year.** The system shall render Tax Year as the plain decimal string of the year integer.

7. **Unwanted-behavior — no partial rows.** For any (Jurisdiction, Tax Year) row present, the system shall never leave any of the five figure columns (Accrued/Moved/Paid/Outstanding/Shortfall) as an empty string — all five render together whenever an `AnnualRow` exists.

8. **Ubiquitous — structural separation.** The system shall publish the reserve summary as its own typed band (own `ViewTab`, name `TAX_RESERVE_TAB` = `"Tax · Reserve Summary"`, header `TAX_RESERVE_HEADER` = [Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall]), distinct from the per-accrual band (`TAX_TAB`), so neither band contains embedded/blank summary rows and both remain one-row-per-entity and natively filterable.

Scope note: `render_tax` takes pre-computed `accruals`/`annual_rows` as input — the code and tests pin only projection/formatting/structuring behavior, not the accrual/reserve computation itself (owned by the `tax` crate).