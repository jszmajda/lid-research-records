**SHEET-MARK — Transient (non-numeric, retryable) price-cell handling on settle read-back**

1. **Ubiquitous.** The system shall determine "settled" for a settle pass as: every symbol in the requested set has a latest reading that is `Numeric` or `Permanent` — i.e., neither `Transient` nor absent from every poll so far.

2. **State-driven.** WHILE at least one requested symbol's latest reading is `Transient` (or absent) AND the poll count is below `cfg.max_polls`, the system shall re-invoke `read_price_pass` and overwrite each symbol's "latest reading" with the newest poll's value (a later `Numeric`/`Permanent` reading for a symbol supersedes an earlier `Transient` for that same symbol, ending its retry).

3. **Ubiquitous (bound).** The settle loop shall perform at most `cfg.max_polls` polls; when no requested symbol ever settles, the loop shall perform exactly `max_polls` polls (verified: `max_polls=3` → 3 reads; `max_polls=4` → 4 reads) — never fewer (no early giveup) and never more (no unbounded retry).

4. **Event-driven (window elapsed, prior exists).** WHEN the bounded window elapses (or the loop breaks) with a symbol's latest reading still `Transient`/absent, AND a prior cached `Mark` exists for that symbol, the system shall carry the prior `Mark` forward **unchanged** — identical `price_cents` and identical `quote_date` (the original stamp, not refreshed) — into this cycle's output, and shall NOT record the symbol as degraded.

5. **Event-driven (window elapsed, no prior).** WHEN the window elapses with a symbol still `Transient`/absent AND no prior mark exists, the system shall record the symbol degraded with reason `TimedOut` and emit no mark for it.

6. **Unwanted behavior.** IF a reading is `Transient`, THEN the system shall NOT value it as a zero/absent-priced mark and shall NOT overwrite an existing prior mark with a null/transient value.

7. **Event-driven (contrast: terminal non-numeric).** WHEN a symbol's latest reading is `Permanent` (terminal non-numeric error, e.g. ticker-form mismatch), the system shall treat it as settled immediately (no further retry consumed) and record it degraded with reason `Permanent` — with NO carry-forward of any prior mark, even if one exists (distinguishing it from `Transient`'s carry-forward rule).

8. **Unwanted behavior (transport failure, distinct from per-symbol transient).** IF the underlying `read_price_pass` call itself errors, THEN the system shall propagate that `Err` and produce no `MarksProduced` value at all (no empty marks map, no per-symbol degrade entries) — never synthesizing a result that resembles "all symbols degraded."