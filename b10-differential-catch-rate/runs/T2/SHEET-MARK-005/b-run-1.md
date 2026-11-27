**Concern: degraded symbol marks — downstream effect & offline behavior**

**Ubiquitous:**
- SHEET-MARK-U1: The system shall convert a numeric price reading to `Cents` via `round_half_to_even(price_usd × 100)`, computed by scaling to an integer numerator over `SCALE = 1_000_000` and rounding once (half-to-even), never via float rounding.
- SHEET-MARK-U2: The system shall represent each settle-pass reading as exactly one of `Numeric{price_usd, quote_date}`, `Transient` (`#N/A`/`Loading...`), or `Permanent` (terminal non-numeric error).
- SHEET-MARK-U3: The system shall omit any symbol recorded degraded (in `degraded`) from the ledger-facing marks map (`to_ledger_marks`); a degraded symbol shall never appear with a value, including 0.

**Event-driven:**
- SHEET-MARK-E1: WHEN a numeric reading's converted price is ≤ 0 cents (a positive price rounding to 0, an exact 0.0, or a negative price), the system shall degrade the symbol with reason `SubCent` and record no mark — never a zero or negative mark.
- SHEET-MARK-E2: WHEN a numeric reading is non-finite (NaN or ±infinity), the system shall degrade the symbol with reason `Permanent` and record no mark.
- SHEET-MARK-E3: WHEN a symbol's reading is `Permanent`, the system shall degrade it immediately with reason `Permanent`, record no mark, and NOT carry forward any prior mark, without waiting for the poll window to elapse.
- SHEET-MARK-E4: WHEN a symbol remains `Transient`/absent after the bounded poll window (default `max_polls = 8`) AND a prior mark exists, the system shall carry the prior mark forward unchanged and shall NOT record the symbol as degraded.
- SHEET-MARK-E5: WHEN a symbol remains `Transient`/absent after the bounded poll window AND no prior mark exists, the system shall degrade it with reason `TimedOut` and record no mark.
- SHEET-MARK-E6: WHEN the underlying settle-pass read transport call itself errors (offline/unreachable), the system shall propagate the error and produce no `MarksProduced` at all.

**Unwanted behavior:**
- SHEET-MARK-N1: IF the settle read fails, THEN the system shall NOT silently emit an empty marks/degraded set (which would misread as "all symbols degraded").

**State-driven:**
- SHEET-MARK-S1: WHILE polling, the system shall continue until every requested symbol is numeric-or-terminally-errored, up to `max_polls` polls, then stop.

Constants: `SCALE = 1_000_000`; `SettleConfig::default().max_polls = 8`.