SHEET-MARK-CENTS EARS requirements — numeric USD price → integer Cents mark

**[Ubiquitous] SHEET-MARK-CENTS-01** The system shall convert a numeric USD price reading to an integer `Cents` mark at exactly one rounding site (`price_to_cents`), computing cents as `price_usd × 100`, and shall carry no floating-point value past that boundary.

**[Ubiquitous] SHEET-MARK-CENTS-02** The system shall perform the cent decision in scaled-integer arithmetic: the float shall be scaled to an integer numerator of `price_usd × 100 × 1_000_000` (SCALE = 1_000_000, i.e. micro-cents, `i128`), and that numerator shall be folded to the cent over SCALE by a single rounding decision, so the scaled-integer fold — not the float's own rounding — decides the cent.

**[Ubiquitous] SHEET-MARK-CENTS-03** The system shall round the fold **half-up**: with quotient `q = numerator div_euclid SCALE` and remainder `r = numerator rem_euclid SCALE` (`0 ≤ r < SCALE`), the result shall be `q` when `2r < SCALE` and `q + 1` otherwise. Exact half-cent ties round up (away from zero for positives), never down and never to even. Examples pinned: `200.0 → Cents(200_00)`, `150.25 → Cents(150_25)`, `1.005 → Cents(1_01)`, `1.015 → Cents(1_02)`.

**[Event-driven] SHEET-MARK-CENTS-04** When a numeric reading converts successfully, the system shall record a `Mark { price_cents, quote_date }` for that symbol, stamped with the reading's GOOGLEFINANCE `quote_date` (kernel `Date`, days since 1970-01-01) and never with wall-clock read time.

**[Unwanted] SHEET-MARK-CENTS-05** If the converted value is `≤ 0` cents — a strictly positive price that rounds to zero (e.g. `0.0001`), an exact `0.0`, or any negative price (e.g. `-5.0`) — then the system shall return `Err(DegradeReason::SubCent)` and shall never emit a zero or negative mark; value shall never be silently understated.

**[Unwanted] SHEET-MARK-CENTS-06** If the reading is non-finite (`NaN`, `+∞`, `-∞`), or if the scaled intermediate `price_usd × 100 × SCALE` is non-finite (overflow), then the system shall return `Err(DegradeReason::Permanent)` and shall produce no mark.

**[Event-driven] SHEET-MARK-CENTS-07** When conversion returns any `Err(reason)` during a settle pass, the system shall record the symbol in `degraded` with that exact reason and shall insert **no** entry in `marks` for it, and no prior mark shall be carried forward for that symbol.

**[Ubiquitous] SHEET-MARK-CENTS-08** The `ledger_core::Marks` projection (`to_ledger_marks`) shall contain symbol → `price_cents` for good marks only; degraded symbols shall be **absent** from the map, so `ledger-core` degrades that symbol's unrealized to `None` rather than zero.

Files: `{scratch}/audit-H-MARK-002/crates/sheets-view/src/lib.rs` (`price_to_cents`, `round_half_up`), `{scratch}/audit-H-MARK-002/crates/sheets-view/tests/marks.rs`.

Note: the module docstrings claim the conversion uses `pt_core::round_half_to_even` (the "single canonical rounding site"); the code instead uses a local `round_half_up`, so the enforced tie-break is half-up.