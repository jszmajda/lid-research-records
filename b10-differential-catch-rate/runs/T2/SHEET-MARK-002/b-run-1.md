**EARS requirements enforced — USD price → Cents mark conversion (`price_to_cents`, sheets-view)**

*Ubiquitous:*
1. The system shall convert a numeric USD price reading to a `Cents` mark via the project's single canonical rounding site: `round_half_to_even(price_usd × 100)`. Implementation constant: an integer `SCALE = 1_000_000`. The conversion computes `numerator = round(price_usd × 100.0 × SCALE)` at f64 precision (the float/integer boundary), then folds `numerator` through `round_half_to_even(numerator, SCALE)` — so the half-to-even rule, not the float's own rounding, decides the cent.
2. A tie exactly at a half-cent (price × 100 lands on X.5) shall resolve to the nearest even cent: `1.005` → `Cents(100)` (rounds down to even 0); `1.015` → `Cents(102)` (rounds up to even 2).
3. Inputs already exact to the cent shall convert exactly: `200.0` → `Cents(20000)`; `150.25` → `Cents(15025)`.

*Unwanted behavior:*
4. IF `price_usd` is non-finite (`NaN` or `±Infinity`) THEN the system shall return `Err(DegradeReason::Permanent)` and produce no `Cents` value.
5. IF the intermediate scaled value (`price_usd × 100 × SCALE`) is itself non-finite (overflow before rounding) THEN the system shall return `Err(DegradeReason::Permanent)`.
6. IF `price_usd` is zero or negative THEN the system shall return `Err(DegradeReason::SubCent)` — never a zero or negative `Cents` mark. (Verified for `0.0` and `-5.0`.)
7. IF `price_usd` is positive but rounds to `0` `Cents` (a positive sub-cent price, e.g. `0.0001`) THEN the system shall return `Err(DegradeReason::SubCent)` rather than `Ok(Cents(0))` — a positive price must never silently degrade to a real zero mark.
8. The boundary test is `cents <= 0` (a single check covering both the non-positive-input case and the positive-rounds-to-zero case): both classify as `SubCent`, never `Permanent`; the two scenarios are not distinguished by returned reason.

*State-driven (composition, from `read_marks`):*
9. WHILE converting a settled `PriceReading::Numeric` into a `Mark`: IF `price_to_cents` returns `Ok(cents)`, the system shall record the symbol's `Mark` as `{price_cents: cents, quote_date: reading's quote_date}`. IF it returns `Err(reason)`, the system shall record the symbol in `degraded` with that `reason` and produce no `Mark` for that symbol this pass (no fallback to a prior mark on a `SubCent`/`Permanent` degrade from a numeric reading — prior-mark carry-forward is reserved for `Transient`/absent readings only).

Files read: `crates/sheets-view/src/lib.rs` (`price_to_cents`, lines 362–385; `read_marks`, lines 848–869), `crates/sheets-view/tests/marks.rs` (lines 62–129).