**EARS requirements enforced by `price_to_cents` (and its call site in `read_marks`) for the USD-price → integer-`Cents` mark conversion:**

**Ubiquitous**
- U1: The system shall convert a numeric USD price reading to a `Cents` mark via a single canonical rounding site: `round_half_to_even(price_usd × 100)`, computed by scaling to an integer numerator `round(price_usd × 100 × SCALE)` with `SCALE = 1_000_000` (i128), then dividing via `round_half_to_even(numerator, SCALE)` — the float crosses into integer exactly once, at the initial multiply; the cent decision itself is integer-only.
- U2: The system shall treat the input `price_usd` as already-USD (no currency/unit conversion).

**Event-driven**
- E1: When `price_to_cents` is called with a finite `price_usd`, the system shall compute `numerator = round(price_usd × 100 × 1_000_000)` and return `Ok(Cents(round_half_to_even(numerator, 1_000_000) as i64))` if that result is `> 0`.
- E2: When the rounded candidate cents value is `<= 0`, the system shall return `Err(DegradeReason::SubCent)` instead of any `Cents` value.
- E3: When `read_marks` receives a `PriceReading::Numeric` and `price_to_cents` returns `Ok`, it shall insert a `Mark { price_cents, quote_date }` keyed by symbol into `marks`. When it returns `Err(reason)`, it shall insert `(symbol, reason)` into `degraded` and NOT carry forward any prior mark for that symbol (unlike the transient-timeout path).

**State-driven (tie-break)**
- S1: While the scaled numerator lands exactly on a half-cent boundary, the system shall round to the nearest even cent (banker's rounding) — pinned examples: `1.005 → Cents(100)` (rounds down to even 100), `1.015 → Cents(102)` (rounds up to even 102).
- S2: While `price_usd` yields exact whole-cent values, conversion is exact — pinned examples: `200.0 → Cents(20000)`, `150.25 → Cents(15025)`.

**Unwanted behavior**
- UB1: If `price_usd` (or the intermediate scaled value) is non-finite (`NaN`, `+∞`, `-∞`), the system shall return `Err(DegradeReason::Permanent)` — never attempt rounding, never a mark.
- UB2: If `price_usd` is exactly `0.0` or negative (e.g. `-5.0`), the system shall return `Err(DegradeReason::SubCent)` — never `Ok(Cents(0))` and never a negative `Cents`.
- UB3: If a positive `price_usd` rounds to `0` cents (e.g. `0.0001`), the system shall return `Err(DegradeReason::SubCent)` rather than `Ok(Cents(0))` — a positive price must never silently degrade to a reported zero mark (value must never be silently understated).

Files: `crates/sheets-view/src/lib.rs` (`price_to_cents`, lines 362–385; `read_marks`, lines 848–869), `crates/sheets-view/tests/marks.rs` (lines 62–129).