SHEET-MARK-CENTS — Price→Cents conversion (`price_to_cents`)

**Ubiquitous / conversion rule**

- SHEET-MARK-CENTS-001 (ubiquitous): The system shall interpret a numeric `Price`-cell reading as a price in **USD** and shall convert it to an integer `Cents` mark as `price_usd × 100`, rounded to the nearest whole cent.
- SHEET-MARK-CENTS-002 (ubiquitous): The conversion shall cross the float boundary exactly once: the reading shall be scaled to an integer numerator of `round(price_usd × 100 × 1_000_000)` (SCALE = 1_000_000, i.e. micro-cents), and the cent shall be decided by a single integer fold of that numerator over SCALE — no float value shall pass beyond the conversion.
- SHEET-MARK-CENTS-003 (ubiquitous, tie-break): When the scaled numerator's remainder over SCALE is exactly half (2·r == SCALE), the system shall round **half-up** (away from zero toward +∞ for the integer quotient), never half-to-even and never half-down. Worked cases: `200.0 → Cents(200_00)`; `150.25 → Cents(150_25)`; `1.005 → Cents(1_01)`; `1.015 → Cents(1_02)`.
- SHEET-MARK-CENTS-004 (ubiquitous): The fold shall be Euclidean (`div_euclid`/`rem_euclid`, `0 ≤ r < SCALE`), so the remainder is non-negative for negative numerators as well.

**Unwanted behavior / error semantics**

- SHEET-MARK-CENTS-005 (unwanted): If the numeric reading is not finite (`NaN`, `+∞`, `−∞`), then the system shall return `Err(DegradeReason::Permanent)` and shall not produce a mark.
- SHEET-MARK-CENTS-006 (unwanted): If the scaled intermediate `price_usd × 100 × SCALE` is not finite (float overflow from a finite but very large reading), then the system shall return `Err(DegradeReason::Permanent)`.
- SHEET-MARK-CENTS-007 (unwanted): If a strictly positive price rounds to 0 cents (sub-cent, e.g. `0.0001`), then the system shall return `Err(DegradeReason::SubCent)` and shall never emit a zero mark — value shall never be silently understated.
- SHEET-MARK-CENTS-008 (unwanted): If the reading is non-positive (exactly `0.0`, or negative such as `-5.0`), then the system shall return `Err(DegradeReason::SubCent)` — never a real zero or negative mark. The boundary is the *post-fold* value: any result `cents <= 0` degrades SubCent.
- SHEET-MARK-CENTS-009 (state-driven): Where the conversion succeeds, the result shall be `Cents(n)` with `n ≥ 1` (strictly positive by construction).

**Event-driven — conversion inside the settle pass**

- SHEET-MARK-CENTS-010 (event-driven): When the settle pass yields `PriceReading::Numeric { price_usd, quote_date }` for a symbol, the system shall convert `price_usd` per the above and, on success, record `Mark { price_cents, quote_date }`, stamping the mark with GOOGLEFINANCE's own quote date (kernel `Date` = days since 1970-01-01), never wall-clock read time.
- SHEET-MARK-CENTS-011 (event-driven): When the conversion returns `Err(reason)`, the system shall record the symbol in `degraded` with that exact reason and shall record **no** mark for it; a prior cached mark shall not be carried forward for a numeric-but-invalid reading.
- SHEET-MARK-CENTS-012 (ubiquitous): A degraded symbol shall be absent from the projected `ledger_core::Marks` map, so downstream replay degrades that position's unrealized to none rather than zero.