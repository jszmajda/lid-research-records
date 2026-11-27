**MARK-PRICE-001: USD Price to Integer Cents Conversion**

A numeric USD price reading from `GOOGLEFINANCE` is converted to an integer `Cents` (i64) mark via scaling and bounded rounding. The float price is the input boundary; the conversion is always total (no float arithmetic past the boundary).

**Scaling and Rounding:** The price is scaled by 100 (to cents) × 1,000,000 (a scaled-integer divisor), yielding a numerator. This numerator is rounded to its integer cent via half-up tie-breaking: if remainder × 2 < divisor, round down; otherwise round up. Half-cent ties (and closer) always round up, never down—a tied 1.005 USD becomes 1 cent, 1.015 becomes 2 cents.

**Non-Finite Input:** If the price is non-finite (`NaN`, `+∞`, `−∞`), the conversion fails terminal (`DegradeReason::Permanent`); no mark is produced.

**Non-Positive Output:** Any price—positive or zero or negative—that rounds to ≤ 0 cents is a degraded anomaly, not a real zero or negative mark (`DegradeReason::SubCent`). Marks are always positive integers; value is never silently understated by rounding or zero-substitution.

**Integration with Settle Pass:** On each settle pass, the client reads price cells and quote dates. For each symbol:
- If numeric (finite, positive, and rounds to > 0 cents): record the mark (price in cents, stamped with `GOOGLEFINANCE` quote date).
- If transient (`#N/A`, loading): keep the prior good cached mark; do not overwrite with transient.
- If permanent (terminal error): record degraded (no mark, no prior carry).
- If still transient after `max_polls` retries (bounded window): record degraded (no mark) unless a prior mark exists, then keep prior.
- If transport fails (offline): propagate error, produce no marks (offline carry-forward is `runtime`'s responsibility).

**Poll Limit:** Settle polling bounded by `SettleConfig.max_polls` (default 8). Loop exits early if all symbols are numeric-or-terminally-errored before the window elapses.

**Degraded Symbol Semantics:** A degraded symbol (no mark) is absent from the ledger marks map, triggering per-symbol degradation in downstream replay (unrealized becomes `None`, not zero).

---

**Summary of Constants & Tie-Breaks:**
- Scale divisor: 1,000,000
- Rounding: half-up (ties always up)
- Non-finite: terminal degrade
- Non-positive result: sub-cent degrade
- Transient + prior: carry prior; transient + no prior: timeout degrade after window
- Permanent: terminal degrade, no prior carry
- Transport error: propagate, no empty marks