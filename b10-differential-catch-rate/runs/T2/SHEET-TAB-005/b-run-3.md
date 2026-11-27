**EARS requirements enforced — Tax reserve summary's figures (source, values, formatting)**

1. **Ubiquitous (source):** The system shall populate each Tax · Reserve Summary row's five financial columns (Accrued, Moved, Paid, Outstanding, Shortfall) with the kernel-exact `Cents` values taken verbatim from the corresponding `tax::AnnualRow` (`accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents`) supplied to `render_tax`. `sheets-view` shall perform no accounting/tax computation of these figures — only formatting.

2. **Ubiquitous (cardinality/order):** The system shall emit exactly one reserve-summary row per input `AnnualRow`, in the same order as `annual_rows`, with no filtering, aggregation, deduplication, or reordering (row count equals `annual_rows.len()`).

3. **Ubiquitous (row key):** Each reserve-summary row shall be keyed by `(Jurisdiction, Tax Year)`, one row per entity.

4. **Ubiquitous (money formatting):** Each of the five money figures shall be rendered via the shared cents-formatter as `{sign}{whole}.{frac}` where `sign` is `"-"` for negative values and empty otherwise, `whole = |cents|/100`, `frac = |cents|%100` zero-padded to 2 digits (e.g., `Cents(150_00)` → `"150.00"`; `Cents(-500)` → `"-5.00"`).

5. **Unwanted behavior:** None of the five figures shall ever render as an empty string, regardless of whether the underlying value is zero — a zero balance renders `"0.00"`, never blank.

6. **Ubiquitous (value typing):** Every cell in the reserve-summary band, including all five money columns, shall be written as an engine `Cell::Value`; the band shall contain no `Cell::Formula` and no live `GOOGLEFINANCE`/price dependency, distinguishing it from the Positions tab's live columns.

7. **Ubiquitous (jurisdiction label):** The Jurisdiction column shall render `"Federal"` for `Jurisdiction::Federal` and `"State({code})"` for `Jurisdiction::State(code)`.

8. **Ubiquitous (tax year format):** The Tax Year column shall render as the bare integer year (no separators, prefix, or suffix).

9. **Ubiquitous (band separation):** The reserve summary shall publish as its own typed range under `TAX_RESERVE_HEADER` (tab `"Tax · Reserve Summary"`), structurally distinct from the per-accrual band (`TAX_HEADER`/`TAX_TAB`) — neither band shall contain blank rows, labels, or an embedded header belonging to the other, so both remain one-row-per-entity and natively filterable.

10. **Ubiquitous (header set):** `TAX_RESERVE_HEADER` shall be exactly `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]`, in that order, matching the reserve-summary row's column order.