**Concern: degraded symbol marks — settle-pass behavior, downstream consumption, offline handling**

**Ubiquitous:**
- The system shall convert a settled numeric USD price to Cents via `round_half_to_even(price_usd × 100)`, computed by scaling to an integer numerator over a 1,000,000 fixed-point scale before rounding (the float is the input boundary only; the cent decision is integer round-half-to-even).
- The system shall never produce a Mark with price_cents ≤ 0.
- The system shall omit any degraded symbol from the `to_ledger_marks()` output (symbol → Cents), so ledger-core observes per-symbol absence, not a zero/negative mark.

**Unwanted-behavior (price_to_cents):**
- IF the numeric price is non-finite (NaN or ±Infinity), THEN the system shall return `DegradeReason::Permanent` (no Cents value).
- IF the numeric price is ≤ 0.0 (zero or negative), THEN the system shall return `DegradeReason::SubCent`.
- IF a positive price rounds to 0 Cents, THEN the system shall return `DegradeReason::SubCent` (never a real zero mark).

**Event-driven (settle pass):**
- WHEN a settle pass is run, the system shall poll `read_price_pass` repeatedly, retaining the latest reading per symbol, until every requested symbol is Numeric-or-Permanent (settled) or `max_polls` is reached (default 8), whichever comes first.
- WHEN a symbol's reading is Numeric, the system shall convert it via price_to_cents; on success record `Mark{price_cents, quote_date}`; on Err, record the symbol degraded with that reason (no mark).
- WHEN a symbol is Permanent, the system shall record it degraded (`DegradeReason::Permanent`) immediately — this settles the loop for that symbol without exhausting max_polls, and shall NOT carry forward any prior mark.

**State-driven (transient handling):**
- WHILE a symbol remains Transient/absent through the bounded poll window: IF a prior Mark exists for that symbol, THEN the system shall carry the prior mark forward unchanged and shall NOT mark it degraded; IF no prior mark exists, THEN the system shall record it degraded as `DegradeReason::TimedOut` (no mark).

**Unwanted-behavior (transport failure):**
- IF the underlying `read_price_pass` call errors (offline/unreachable), THEN `read_marks` shall propagate the `Err` and produce no `MarksProduced` — it shall NOT synthesize an empty marks set (which would misread as "all symbols degraded"). Offline mark carry-forward is the caller's (`runtime`'s) responsibility, out of this function's scope.

**Constants pinned:** `SettleConfig::default().max_polls == 8`; fixed-point scale `1_000_000`.