```
TAX-RESERVE-001: Reserve Summary Origin & Exactness
The Tax Reserve Summary tab carries kernel-exact figures from `tax::annual_report`'s `AnnualRow` output, rendered one row per `(Jurisdiction, Tax Year)` pair. All seven columns (Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall) are populated on every row; the five monetary columns (Accrued / Moved / Paid / Outstanding / Shortfall) are never blank. All values are engine-written (not live formulas).

TAX-RESERVE-002: Reserve Summary Columns & Formatting
Each reserve-summary row projects five kernel-exact `Cents` figures from its `AnnualRow`:
- Column 3 (Accrued): `AnnualRow.accrued_cents`
- Column 4 (Moved): `AnnualRow.moved_cents`
- Column 5 (Paid): `AnnualRow.paid_cents`
- Column 6 (Outstanding): `AnnualRow.outstanding_cents`
- Column 7 (Shortfall): `AnnualRow.shortfall_cents`

All monetary values are formatted via `fmt_cents()` to dollar strings: signed, two decimal places (e.g., "150.00", "-20.00"). Negative amounts render with a leading minus sign.

TAX-RESERVE-003: Reserve Summary Lifecycle Accounting
The five columns form a stacked lifecycle: accrued → allocated → moved → paid → outstanding. The figures represent:
- Accrued: total tax liability accrued on all sales in that jurisdiction+year
- Moved: amount moved from accrual to a named reserve account
- Paid: amount paid from the reserve in that jurisdiction+year (e.g., quarterly estimated payment)
- Outstanding: accrued minus paid (the unpaid remainder)
- Shortfall: negative outstanding when estimated taxes paid exceed accrued (a deficit requiring acceleration)

TAX-RESERVE-004: Reserve Summary Keying & Grain
Each row is keyed by the `(Jurisdiction, Tax Year)` pair — one row per unique pair from the `annual_rows` input. The grain is annual per jurisdiction; sub-annual detail (e.g., quarterly or per-sale) does not appear in this summary (accrual detail lives in the Accrual band above).

TAX-RESERVE-005: Reserve Summary Row Count & Completeness
The reserve-summary rows count equals the `annual_rows` input count; no filtering, reordering, or deduplication. Every `AnnualRow` that flows in yields exactly one reserve-summary row. All five monetary columns are always populated — a blank field violates the spec and indicates a kernel computation or projection error.
```