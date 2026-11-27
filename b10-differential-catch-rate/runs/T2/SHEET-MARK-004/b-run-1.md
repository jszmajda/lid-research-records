**EARS reconstruction — cached-mark timestamping (sheets-view)**

1. **Ubiquitous.** The system shall stamp every per-symbol `Mark` with GOOGLEFINANCE's own quote date for that symbol, never the wall-clock time at which the settle-pass read occurred.

2. **Event-driven.** When the settle pass reads a `PriceReading::Numeric { price_usd, quote_date }` for a symbol, the system shall set that symbol's `Mark.quote_date` to the `quote_date` carried in the reading, paired with `price_usd` converted to `price_cents`.

3. **Event-driven.** When rendering the Quote Date formula for a ticker, the system shall emit exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`: truncate the raw `tradetime` to its date serial via `INT`, re-base it to days-since-1970-01-01 (the kernel `Date` epoch) by subtracting `DATE(1970,1,1)`, and render the result with `TEXT(…,"0")` as a locale-invariant, digits-only string (never the raw, locale-dependent `tradetime` datetime).

4. **Unwanted behavior.** If GOOGLEFINANCE's `tradetime` is still loading or is errored, the Quote Date formula shall (via `IFERROR`) evaluate to the empty string rather than propagating an error or a partial value.

5. **State-driven.** While a symbol's reading is `Transient` (or absent from the current pass) and the bounded settle window (`SettleConfig.max_polls`, default 8) has not elapsed, the system shall re-poll rather than assign or finalize any `quote_date` for that symbol.

6. **State-driven.** While a symbol remains `Transient`/absent once the bounded window elapses, if a prior cached `Mark` exists for that symbol, the system shall carry the entire prior `Mark` forward unchanged — including its previously-stamped `quote_date` — rather than issuing a new date, defaulting to wall-clock time, or degrading it.

7. **Unwanted behavior.** If a symbol remains `Transient`/absent past the bounded window and no prior `Mark` exists, the system shall record it degraded (`DegradeReason::TimedOut`) with no `Mark` and no `quote_date`, rather than fabricating one.

8. **Unwanted behavior.** If a symbol's reading is `Permanent` (terminal, non-numeric error), the system shall record it degraded (`DegradeReason::Permanent`) immediately, with no `Mark`/`quote_date` and no carry-forward of any prior quote_date, even if one exists.

9. **Unwanted behavior.** A degraded symbol (no settled `Mark`) shall be absent from the `to_ledger_marks()` projection — no synthetic entry or quote_date-bearing placeholder is produced for it.

Files: `.../sheets-view/src/lib.rs`, `.../sheets-view/tests/marks.rs`.