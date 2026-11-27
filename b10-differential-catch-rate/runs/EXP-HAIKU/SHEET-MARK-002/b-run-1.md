**SHEET-MARK-PRICE-CONVERSION: USD Price → Integer Cents Mark**

The `price_to_cents` conversion applies a single scaled-integer rounding site to convert a live `GOOGLEFINANCE` price (f64 USD) into an integer `Cents` mark. The float boundary is at input only; all rounding decisions fold to integer arithmetic via a micro-cents numerator.

**Conversion pipeline:**
1. **Input boundary check:** A non-finite input (NaN or ±∞) degrades immediately with `DegradeReason::Permanent` — never a mark.
2. **Scaled numerator:** Compute `scaled = price_usd × 100.0 × SCALE` where `SCALE = 1_000_000` (constant). If this intermediate overflows to non-finite, degrade `Permanent`.
3. **Integer rounding:** Round the scaled numerator to the nearest integer via `f64::round()`, then fold to `Cents` via `round_half_up(numerator, SCALE)`. The `round_half_up` function: divide the numerator by `SCALE`, compare remainder to half; if `2 × remainder < SCALE`, truncate; else round up. This implements half-up tie-breaking (e.g., `1.005 USD → 1.01¢`, `1.015 USD → 1.02¢`).
4. **Result validation:** If the folded `Cents` is ≤ 0, degrade with `DegradeReason::SubCent` (includes positive prices rounding to 0¢, exact 0.0, and negative readings). Otherwise, return the positive `Cents` mark.

**Semantics:**
- A positive price that rounds to 0¢ (sub-cent: e.g., `0.0001 USD → 0.00¢`) is a degraded anomaly, never a real zero mark — silently understating portfolio value is forbidden.
- Exact 0.0 or negative prices degrade `SubCent`, not treated as valid marks.
- Non-finite inputs degrade `Permanent` (terminal, not retryable); other degradations are `SubCent`.
- Result is always a positive `Cents(i64)` value (cents ≥ 1 per USD × 100 scale).

<feedback_intent_not_artifact_state>
The mark read-back logic (in `read_marks`) carries prior marks forward for transiently-unknown symbols but NOT for permanent errors; this constraint is enforced by the error enum structure and the settle loop's match arms — these are consequences of the conversion pipeline's error typing, not separate requirements.
</feedback_intent_not_artifact_state>