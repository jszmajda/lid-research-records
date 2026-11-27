```
CONCERN: Provenance of the Tax view's Reserve Summary figures (crates/sheets-view/src/lib.rs::render_tax; tests/formula.rs)

[Ubiquitous] The Tax Reserve Summary band shall render under the fixed header ["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"] (TAX_RESERVE_HEADER), as its own named range TAX_RESERVE_TAB = "Tax · Reserve Summary", distinct from the accrual band's TAX_TAB range, each with its own frozen header — so the reserve summary is never a label/blank row embedded inside the accrual band.

[Event-driven] WHEN render_tax(accruals, annual_rows) is invoked, the system shall produce a reserve_summary ViewTab containing exactly one row per element of the supplied `annual_rows` slice, in the same order as supplied (no independent sort, filter, or aggregation — annual_rows.len() == reserve_summary.rows.len()).

[Ubiquitous] Each reserve-summary row's Accrued, Moved, Paid, Outstanding, and Shortfall cells shall equal the corresponding `tax::AnnualRow`'s accrued_cents / moved_cents / paid_cents / outstanding_cents / shortfall_cents fields verbatim (kernel-exact) — sheets-view shall perform no independent tax computation or resummation of these figures.

[Ubiquitous] Cents values shall be formatted via the signed dollars-and-cents rule: sign (`-` if negative, else none) + absolute whole dollars + `.` + two-digit absolute cent remainder, e.g. Cents(15000) → "150.00", Cents(-150) → "-1.50".

[Ubiquitous] The Jurisdiction cell shall render `Federal` as the literal string "Federal" and `State(code)` as `"State({code})"`; the Tax Year cell shall render the year as its bare integer decimal string (no grouping separators).

[Unwanted behavior] None of the five figure cells (Accrued/Moved/Paid/Outstanding/Shortfall) shall ever render as an empty string; a zero balance renders as "0.00", never blank.

[Unwanted behavior] No cell in the reserve-summary band (nor the accrual band) shall ever be a live formula (Cell::Formula / GOOGLEFINANCE-dependent); every cell shall be Cell::Value — the reserve summary is kernel-exact and as-of-last-sync, never live-price-derived, unlike Positions.

[State-driven] WHILE a (Jurisdiction, Tax Year) pair is present in `annual_rows`, its reserve-summary row shall carry all five figures populated (never 4-of-5 with one blank) — the row is keyed by (Jurisdiction, Tax Year) matching, not partial.
```