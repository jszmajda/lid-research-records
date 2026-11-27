**Reconstructed EARS requirements — Tax tab tax-adjusted figures (render_tax)**

**Ubiquitous:**
1. The Tax tab SHALL be rendered as two distinct, separately-headered bands: an accrual band (header: Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State) and a reserve-summary band (header: Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall); the reserve-summary SHALL never be embedded as rows inside the accrual band (no blank/label/embedded-header row).
2. Every cell in both bands SHALL be an engine-written value (`Cell::Value`) — the Tax tab SHALL contain no live/formula cells (unlike Positions' pre-tax/post-tax estimates); figures are kernel-exact and as-of-last-sync.
3. All currency figures (Amount, Accrued, Moved, Paid, Outstanding, Shortfall) SHALL be formatted as `[-]D.CC`: a leading `-` iff the value is negative, then the absolute integer-cents value's whole-dollar part, `.`, and the remainder zero-padded to exactly 2 digits (e.g. `Cents(5)` → `"0.05"`; `Cents(-5)` → `"-0.05"`).
4. Jurisdiction SHALL render as `"Federal"` for Federal, or `"State(CODE)"` for a state jurisdiction (literal code interpolation).
5. Tax Year SHALL render as the plain unsigned integer string, no separators/padding.
6. Lifecycle State SHALL render as exactly one of the literal strings `"Accrued"`, `"Allocated"`, `"Moved"`, `"Paid"` per the accrual's state variant, discarding any variant payload.

**Event-driven:**
7. WHEN an accrual's applied amount is present, the Amount cell SHALL show its formatted currency value; WHEN absent, the Amount cell SHALL render the empty string (never `"0.00"` or any placeholder).
8. WHEN rendering a reserve-summary row, all five figures SHALL be copied unmodified from the matching `AnnualRow` and formatted per Rule 3 — never omitted/blank even when the underlying value is exactly 0.

**State-driven:**
9. WHILE rendering the accrual band, exactly one row SHALL be emitted per input accrual, in input order, with row width always equal to the accrual header's width (no ragged rows).
10. WHILE rendering the reserve-summary band, exactly one row SHALL be emitted per input `AnnualRow` (one per Jurisdiction×Tax-Year), in input order, with row width always equal to the reserve header's width.

**Unwanted-behavior:**
11. IF the accrual/reserve data would produce a row not matching its band's header width or containing a summary/separator/duplicate-header row THEN that row SHALL NOT be emitted — every row in both bands is a genuine one-row-per-entity data row.

Files read: `.../sheets-view/src/lib.rs`, `.../sheets-view/tests/formula.rs`, `.../sheets-view/tests/tabs.rs`.