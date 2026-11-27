**EARS requirements enforced — non-positive / non-finite price-reading classification** (`price_to_cents`, `SHEET-MARK-*`)

**Ubiquitous:**
1. The system shall classify any non-finite price reading (`NaN`, `+∞`, or `-∞`) as `DegradeReason::Permanent`, returning `Err` before attempting any cent conversion.
2. The system shall classify any finite, non-positive price reading (exactly `0.0` or negative) as `DegradeReason::SubCent`.
3. The system shall classify a finite, positive price reading whose computed cent value rounds to `≤ 0` cents as `DegradeReason::SubCent` (a "sub-cent" price, e.g. `0.0001` USD) — identical classification to case 2, so callers cannot distinguish "too small" from "non-positive" by reason alone.
4. The system shall never return `Ok(Cents(0))` or `Ok(Cents(negative))` from `price_to_cents` — every non-positive or sub-cent result is an `Err`, never a real zero/negative mark.

**State-driven:**
5. While converting a price, if the raw `price_usd` input fails the finiteness check, the system shall short-circuit to `Err(Permanent)` without computing the scaled numerator.
6. While converting a price, if the intermediate scaled value (`price_usd × 100 × 1_000_000`) itself becomes non-finite (overflow) even though the raw input was finite, the system shall also classify as `Err(Permanent)` (a second, independent finiteness guard after scaling).
7. While computing the final cent value from a finite scaled numerator, if `round_half_to_even(numerator, 1_000_000) ≤ 0`, the system shall classify as `Err(SubCent)` regardless of whether the pre-rounding value was zero, negative, or a small positive fraction.

**Event-driven (settle-pass consumption in `read_marks`):**
8. When a settle-pass reading for a symbol is `PriceReading::Numeric` and `price_to_cents` returns `Err(reason)` (either `SubCent` or `Permanent`), the system shall record that symbol in `degraded` with that exact reason and shall NOT insert an entry into `marks` for it.
9. When a numeric reading degrades via `price_to_cents` (case 8), the system shall NOT carry forward any prior cached mark for that symbol — unlike the `Transient`/timeout path, a non-positive/non-finite numeric reading degrades immediately with no prior-mark fallback.

**Unwanted behavior:**
10. The system shall not silently treat a `0.0`, negative, `NaN`, or `±∞` price reading as a usable mark, and shall not propagate such a symbol into `MarksProduced::to_ledger_marks()` (degraded symbols are absent, never `Cents(0)`).

Constants pinned: `SCALE = 1_000_000`; finiteness checked via `f64::is_finite()` at two points (pre- and post-scale).