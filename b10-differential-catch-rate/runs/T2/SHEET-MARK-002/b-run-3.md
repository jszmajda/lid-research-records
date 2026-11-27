**EARS requirements enforced by `price_to_cents` (and its call site in `read_marks`), for the USD-price → Cents mark conversion:**

**Ubiquitous:**
1. The system shall convert a numeric USD price to `Cents` via `round_half_to_even(price_usd × 100)`, the project's single canonical rounding rule — the price value crosses the float boundary at most once, and the tie-break decision is delegated to the integer `round_half_to_even` helper, never to float rounding.
2. The scaling shall be computed as `numerator = round(price_usd × 100 × SCALE)` with `SCALE = 1_000_000` (an integer literal), then `cents = round_half_to_even(numerator, SCALE)`.

**Unwanted behavior:**
3. If `price_usd` is non-finite (`NaN` or `±∞`), either as given or after the `×100×SCALE` scaling, the conversion shall return `Err(DegradeReason::Permanent)` and produce no mark.
4. If the resulting `cents` is `≤ 0` — covering an exact `0.0` price, any negative price, or a positive price whose rounded value is `0` cents — the conversion shall return `Err(DegradeReason::SubCent)`, never `Ok(Cents(0))` and never a negative `Cents`. A positive sub-cent price must never be silently recorded as a real zero mark (value must never be silently understated).
5. There is no separate "negative price" error variant: negative and zero prices both fall through the same `cents ≤ 0` unwanted-behavior branch to `SubCent`.

**State-driven:**
6. While `cents > 0`, the system shall return `Ok(Cents(cents as i64))`.

**Tie-break (pinned only by tests, exact values):**
7. `200.0 → 200_00`; `150.25 → 150_25` (exact cents pass through unchanged).
8. At an exact half-cent boundary, ties round to even: `1.005 → 1_00` (100 is even) and `1.015 → 1_02` (102 is even).

**Event-driven (integration, in `read_marks`):**
9. When a settled `PriceReading::Numeric{price_usd, quote_date}` is obtained for a symbol, the system shall pass `price_usd` through `price_to_cents`; on `Ok(price_cents)` it shall record `Mark{price_cents, quote_date}` for that symbol; on `Err(reason)` it shall record the symbol in the degraded map with that `DegradeReason` and store no mark for it (test: `price_usd: 0.0001` and `price_usd: 0.0` each produce `degraded == SubCent`, no entry in `marks`).

Files read: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs`, `.../tests/marks.rs`.