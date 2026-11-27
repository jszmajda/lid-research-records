**EARS requirements enforced (Tax tab tax-adjusted figures):**

1. **[Ubiquitous]** The system shall render the Tax tab as two distinct typed bands — the accrual band, one row per `Accrual`, under header exactly `["Sale ID", "Lot ID", "Jurisdiction", "Tax Year", "Amount", "Lifecycle State"]`; and the reserve-summary band, one row per `(Jurisdiction, Tax Year)`, under header exactly `["Jurisdiction", "Tax Year", "Accrued", "Moved", "Paid", "Outstanding", "Shortfall"]` — each with its own frozen header, never combined into one range.

2. **[Ubiquitous]** The system shall render every cell in both Tax-tab bands as an engine value (`Cell::Value`), never a live formula — distinct from Positions' live post-tax estimate.

3. **[Ubiquitous]** The system shall format every Cents figure identically: `{sign}{whole}.{frac:02}` (e.g. `Cents(15000)` → `"150.00"`; negative values prefixed `-`, no other sign handling).

4. **[Ubiquitous]** The system shall render `Jurisdiction` as `"Federal"` for `Jurisdiction::Federal` and `"State({code})"` for `Jurisdiction::State(code)`; and `Lifecycle State` as `"Accrued"`/`"Allocated"`/`"Moved"`/`"Paid"` for the four `AccrualState` variants (variant payload fields, e.g. move/pay details, are not rendered).

5. **[Event-driven]** WHEN rendering the accrual band from an `Accrual` whose `applied_cents` is `Some`, the system shall render `Amount` as its formatted-cents value; WHEN `applied_cents` is `None`, the system shall render `Amount` as the empty string (never `"0.00"` or an error marker).

6. **[Event-driven]** WHEN rendering the accrual band, the system shall emit rows in the same order as the input `accruals` slice, one row per accrual, each row width equal to the 6-column header (no ragged rows).

7. **[Event-driven]** WHEN rendering the reserve-summary band from `AnnualRow`s, the system shall emit exactly `annual_rows.len()` rows, in the same order as the input slice, each carrying its `AnnualRow`'s `accrued_cents`/`moved_cents`/`paid_cents`/`outstanding_cents`/`shortfall_cents` verbatim (kernel-exact, no recomputation) formatted per rule 3.

8. **[Unwanted behavior]** The system shall never insert an among-data row into either band: no blank/separator row, no literal `"RESERVE SUMMARY"` label row in column 1, and no row whose cell texts equal `TAX_RESERVE_HEADER` embedded inside the accrual band.

9. **[Unwanted behavior]** IF a reserve-summary row is emitted, THEN none of its five figure cells (Accrued/Moved/Paid/Outstanding/Shortfall) shall be an empty string — all five are always populated, even when zero (rendered `"0.00"`, not blank).