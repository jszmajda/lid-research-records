**EARS requirements enforced by `price_to_cents` (and its use in `read_marks`) for classifying non-positive/non-finite price readings:**

**Ubiquitous**
- U1: The price→Cents conversion shall take `price_usd: f64` (USD) as the sole float input boundary and compute the cent value as `round_half_to_even(numerator, SCALE)` where `SCALE = 1_000_000`, `numerator = (price_usd * 100.0 * SCALE).round() as i128` — i.e. scale to micro-cents in f64, round to an integer, then apply the canonical half-to-even rounding over `SCALE`.
- U2: Rounding ties at exactly half a cent shall resolve via round-half-to-even (banker's rounding), not round-half-up: `1.005` → 100 cents (`1.00`); `1.015` → 102 cents (`1.02`).

**Unwanted behavior**
- UB1: If `price_usd` is non-finite (`NaN`, `+∞`, or `−∞`), the conversion shall return `Err(DegradeReason::Permanent)` and shall not produce a `Cents` value.
- UB2: If the scaled intermediate (`price_usd * 100.0 * SCALE`) is itself non-finite (overflow), the conversion shall likewise return `Err(Permanent)`.
- UB3: If the rounded cent value is `≤ 0` — whether because `price_usd` is exactly `0.0`, negative (e.g. `-5.0`), or a positive value so small it rounds to `0` cents (e.g. `0.0001`) — the conversion shall return `Err(DegradeReason::SubCent)`, never `Ok(Cents(0))` and never a negative `Cents`. A positive sub-cent reading is classified identically to zero/negative input: a degraded anomaly, not a real value — value must never be silently understated.
- UB4: `SubCent` and `Permanent` shall remain mutually exclusive classifications: only non-finite input (or non-finite scaled intermediate) yields `Permanent`; only finite input whose rounded result is non-positive yields `SubCent`.

**Event-driven (settle pass / `read_marks`)**
- E1: When a settle pass yields `PriceReading::Numeric{price_usd, quote_date}` for a symbol and `price_to_cents(price_usd)` returns `Err(reason)`, the system shall record that symbol as degraded with `reason` and shall NOT insert a `Mark` for it, and shall NOT carry forward any prior cached mark for that symbol — distinct from the `Transient`/`TimedOut` path, which does carry the prior mark forward.
- E2: When producing the ledger `Marks` map via `to_ledger_marks`, any symbol recorded degraded for any reason (including `SubCent` and `Permanent`) shall be entirely absent from the map, never present with a zero or negative `Cents` value.