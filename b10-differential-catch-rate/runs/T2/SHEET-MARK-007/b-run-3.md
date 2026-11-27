**EARS reconstruction — price-reading validity classification (`sheets_view::price_to_cents`, `read_marks`)**

**Ubiquitous**
- U1: `price_to_cents` shall convert a USD price to `Cents` by scaling `price_usd × 100` into an integer numerator over `SCALE = 1_000_000` and rounding exactly once via `round_half_to_even`; the float crosses the boundary once and the half-to-even rule, not float rounding, decides the final cent (e.g. `1.005 → 1.00`, `1.015 → 1.02`, both ties resolved to even).

**Unwanted behavior — non-finite input**
- U2: If `price_usd` is non-finite (`NaN`, `+Infinity`, or `-Infinity`), then `price_to_cents` shall return `Err(DegradeReason::Permanent)` immediately, without computing a scaled numerator or a cents value.
- U3: If the scaled intermediate (`price_usd × 100 × SCALE`) is itself non-finite (e.g. overflow from an extreme finite input), then `price_to_cents` shall likewise return `Err(DegradeReason::Permanent)`.

**Unwanted behavior — non-positive result**
- U4: If, after rounding, the resulting `Cents` value is ≤ 0 — whether from an exact `0.0` price, any negative price, or a positive sub-cent price (e.g. `0.0001`) that rounds down to `0` — then `price_to_cents` shall return `Err(DegradeReason::SubCent)`, and shall never return `Ok(Cents(0))` or a negative `Ok(Cents(_))`. This is a distinct degrade reason from non-finite input: a positive-but-sub-cent price is `SubCent`, never `Permanent`; a non-finite reading is `Permanent`, never `SubCent`.

**State-driven — settle-pass consumption (`read_marks`)**
- U5: While `read_marks` is resolving a settled `PriceReading::Numeric` reading, if `price_to_cents` returns `Err(reason)` (either `SubCent` or `Permanent`), the system shall insert the symbol into `MarksProduced.degraded` keyed by that exact `reason`, and shall NOT insert an entry for that symbol into `MarksProduced.marks`.
- U6: This degrade-and-omit behavior shall occur regardless of whether a prior cached mark exists for the symbol — a non-positive or non-finite numeric reading never falls back to the prior mark (prior-mark carry-forward is reserved exclusively for `Transient`/absent readings, not for a numerically-received-but-invalid price).
- U7: A symbol recorded in `degraded` shall be absent from `MarksProduced.to_ledger_marks()`, so a non-positive/non-finite reading propagates as per-symbol mark absence (degrades `unrealized_cents` to `None`) rather than as a silently-understated zero or negative mark.