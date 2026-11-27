**Reconstructed EARS requirements — Tax tab tax-figure computation & presentation (sheets-view)**

1. **Ubiquitous.** The system shall render the Tax tab as two independently-headed, one-row-per-entity bands: an accrual band under `TAX_HEADER = [Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State]`, and a reserve-summary band under `TAX_RESERVE_HEADER = [Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall]`, each its own named `ViewTab` (`reserve_summary.name != accruals.name`).

2. **Ubiquitous.** Every cell in both bands shall be an engine-computed `Cell::Value` — never a `Cell::Formula`. The Tax tab carries no live-price dependency; it is kernel-exact and as-of-last-sync.

3. **Event-driven.** WHEN rendering the accrual band from a set of `Accrual`s, the system shall emit exactly one row per accrual, in input order, with no blank/label/separator row and no row reproducing `TAX_RESERVE_HEADER` verbatim as data.

4. **Event-driven.** WHEN rendering the reserve-summary band from a set of `AnnualRow`s, the system shall emit exactly one row per `(Jurisdiction, Tax Year)` `AnnualRow`, carrying its Accrued/Moved/Paid/Outstanding/Shortfall cents fields unmodified (kernel-exact); all five columns shall be populated — none may render blank.

5. **Ubiquitous.** Any `Cents` value on the tab shall format as `{sign}{whole}.{frac:02}` — magnitude divided/modulo by 100, two zero-padded fraction digits, a leading `-` only when negative, no `+` prefix for non-negative values.

6. **Ubiquitous.** Jurisdiction shall render as `"Federal"` for `Jurisdiction::Federal` and `"State(<code>)"` (literal parentheses) for `Jurisdiction::State(code)`.

7. **State-driven.** WHILE an accrual's `applied_cents` is `None` (not yet applied), the Amount cell shall render as an empty string — not `"0.00"`, not an error placeholder.

8. **Ubiquitous.** Lifecycle State shall render as exactly one of `"Accrued"`, `"Allocated"`, `"Moved"`, `"Paid"`, collapsing any per-variant payload (e.g. `Moved{..}` → `"Moved"`, without amount/date).

9. **Unwanted-behavior.** IF the accrual band and reserve-summary band were ever merged into one range, THEN the system shall reject it — the two must remain distinct typed ranges so neither carries among-data summary rows and both stay natively filterable/sortable.

Row counts are pinned by test: `accruals.rows.len() == accruals.len()`; `reserve_summary.rows.len() == annual_rows.len()`.