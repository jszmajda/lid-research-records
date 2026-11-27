SHEET-MARK-SETTLE-POLLING-WINDOW: The settle pass polls `client.read_price_pass()` up to `cfg.max_polls` times. Each poll reads all requested symbols' current price readings. The loop exits early when all requested symbols have settled (no symbol is `PriceReading::Transient` or absent from all passes), or when the poll count reaches `cfg.max_polls`, whichever comes first.

SHEET-MARK-TRANSIENT-PRIOR-CARRY: A symbol that is `PriceReading::Transient` or absent from every pass during the polling window is handled by the final settlement:
- If a prior good cached Mark exists (from the prior cycle's cache): the prior Mark (with its prior quote_date stamp) is recorded as this cycle's mark — the symbol is NOT degraded
- If no prior Mark exists: the symbol is recorded degraded with `DegradeReason::TimedOut`

SHEET-MARK-PERMANENT-NO-CARRY: A symbol that yields `PriceReading::Permanent` (terminal non-numeric error) is recorded degraded with `DegradeReason::Permanent` and settles the loop immediately (exits without waiting for remaining polls). Prior cached marks are NOT used; a Permanent error overrides them.

SHEET-MARK-NUMERIC-CENTS-CONVERT: A symbol reading `PriceReading::Numeric { price_usd, quote_date }` is converted to `Cents` via `price_to_cents(price_usd)`:
- The conversion rounds via `round_half_to_even` at the cent boundary: `price × 100` is scaled to an integer numerator (× 1e6 intermediate scale), passed to `round_half_to_even(numerator, 1e6)`, yielding a cent value
- A positive price that rounds to `≤ 0` Cents (sub-cent anomaly, e.g., 0.0001 → 0¢) degrades with `DegradeReason::SubCent`
- Any exact-zero or negative price (0.0, −5.0) degrades with `DegradeReason::SubCent`
- Any non-finite price (NaN, ±∞) degrades with `DegradeReason::Permanent`
- On degrade, no Mark is recorded

SHEET-MARK-ROUNDING-HALF-TO-EVEN: At the half-cent tie (when `price × 100` lands on `.5` of a Cent), the rounding rounds to the nearest even Cent: 1.005 USD → 100¢ (round down to even), 1.015 USD → 102¢ (round up to even).

SHEET-MARK-QUOTE-DATE-STAMP: Each recorded Mark carries its `quote_date` from the numeric reading (`GOOGLEFINANCE`'s own quote epoch), not the wall-clock settle-pass timestamp. The quote date is per-symbol and invariant across cycles if the symbol remains transient and the prior Mark is carried forward.

SHEET-MARK-TRANSPORT-PROPAGATE: If `read_price_pass()` errors (workbook unreachable / offline), the error propagates immediately. No `MarksProduced` is emitted — the function returns `Err`, not an empty marks set. The caller retains its prior cached marks unchanged and re-injects them into the next replay.