**EARS requirements — mark timestamping (quote-date stamping of cached marks)**

1. **Ubiquitous:** The system shall stamp every settled per-symbol `Mark` with `GOOGLEFINANCE`'s own quote date (the `tradetime`-derived quote-epoch), never with the wall-clock time at which the read-back occurred.

2. **Ubiquitous (encoding):** The system shall render each symbol's `Quote Date` cell as the formula `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, where: `INT(...)` truncates the raw trade time to its date serial (drops time-of-day); the result is re-based to days-since-1970-01-01 (the kernel `Date` epoch) by subtracting `DATE(1970,1,1)`; and `TEXT(...,"0")` renders it as a digits-only integer string so every locale formats it identically (avoiding the locale-dependent, unparseable raw `tradetime` datetime).

3. **Unwanted behavior (state-driven):** While the quote is loading or errored, the `Quote Date` formula shall evaluate to the empty string `""` (via the outer `IFERROR`), not propagate an error and not fall back to wall-clock time.

4. **Event-driven:** When a settle-pass reading for a symbol is `PriceReading::Numeric { price_usd, quote_date }`, the system shall stamp the produced `Mark.quote_date` with exactly that reading's `quote_date`, unmodified, paired with `price_to_cents(price_usd)` as `price_cents`.

5. **Event-driven:** When a symbol's settle-pass reading is `Transient`/absent through the entire bounded poll window (`SettleConfig.max_polls`, default 8) and a prior cached `Mark` exists for that symbol, the system shall carry the prior `Mark` forward **unchanged** — including its original `quote_date` — rather than assigning any new timestamp.

6. **Unwanted behavior:** When a symbol's settle-pass reading is `Transient`/absent through the bounded window with **no** prior `Mark`, the system shall record the symbol degraded (`DegradeReason::TimedOut`) and shall NOT stamp/produce any `Mark` (no fabricated timestamp).

7. **Unwanted behavior:** When a settle-pass reading is `Permanent` (terminal error), the system shall record the symbol degraded (`DegradeReason::Permanent`) with no `Mark` produced, and shall NOT carry forward any prior mark/timestamp — a terminal error never reuses a stale quote date the way a transient does.

8. **Ubiquitous:** Across settled, carried-forward, and degraded cases, the system shall never derive a `Mark.quote_date` from wall-clock/system read time — the only two sources of a stamped `quote_date` are (a) `GOOGLEFINANCE`'s own quote date on a fresh numeric settle, or (b) an unmodified prior cached `Mark`'s `quote_date` on transient carry-forward.