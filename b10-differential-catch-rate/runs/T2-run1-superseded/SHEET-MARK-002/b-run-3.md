**Requirements enforced (price → Cents conversion), reconstructed as EARS:**

**Ubiquitous:**
1. The system shall convert a settled numeric USD price reading to an integer `Cents` value by computing `round_half_to_even(price_usd × 100)`.
2. The system shall perform this via a fixed-point path, not native float rounding: scale `price_usd × 100 × SCALE` where `SCALE = 1_000_000` (an `i128` constant), round that intermediate to the nearest integer (`f64::round`), then reduce it through `round_half_to_even` with denominator `SCALE` — the float crosses the value boundary exactly once; the half-to-even rule alone decides the final cent.
3. The tie-break rule at an exact half-cent is round-half-to-even (banker's rounding): `1.005` USD → `100¢` (100 is even); `1.015` USD → `102¢` (102 is even).

**Unwanted behavior:**
4. If `price_usd` is non-finite (`NaN`, `+∞`, `-∞`), or the scaled intermediate (`price_usd × 100 × SCALE`) is non-finite, the system shall reject the conversion, returning `Err(DegradeReason::Permanent)` — no `Cents` produced.
5. If the rounded cents result is `≤ 0` — covering an exact `0.0` price, any negative price, and a positive price that rounds down to `0` — the system shall reject the conversion, returning `Err(DegradeReason::SubCent)`, never `Ok(Cents(0))` or a negative `Cents`. A positive-price-to-zero-cents result is treated as a degraded anomaly, not a legitimate zero mark; value must never be silently understated.

**Event-driven (settle-pass integration):**
6. When a symbol's settled reading is `Numeric` and `price_to_cents` succeeds, the system shall record `Mark { price_cents, quote_date }` (the reading's own `GOOGLEFINANCE` quote date, not wall-clock time) into that pass's produced marks.
7. When `price_to_cents` returns `Err(SubCent)` or `Err(Permanent)` for a `Numeric` reading, the system shall insert the symbol into the degraded map keyed by that exact `DegradeReason`, and shall NOT insert any mark for that symbol this cycle (no partial/zero cents value crosses the boundary on error).
8. A symbol recorded degraded (from either reason) shall be absent from the `MarksProduced → ledger_core::Marks` projection (`to_ledger_marks`), rather than present with a substitute value.

Constants pinned: `SCALE = 1_000_000`; dollars-to-cents factor `100`; degrade threshold `cents <= 0`.