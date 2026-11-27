**EARS requirements — cached-mark timestamping (settle pass)**

1. **Ubiquitous:** The system shall stamp every settled numeric mark with the price reading's own `GOOGLEFINANCE` quote date, never the wall-clock time of the read.

2. **Event-driven:** WHEN a symbol's latest settle-pass reading is `Numeric{price_usd, quote_date}` and `price_to_cents(price_usd)` succeeds, the system shall record `Mark{price_cents, quote_date}` using exactly that reading's `quote_date` (paired 1:1 with the price it came from, not a separately-sourced timestamp).

3. **State-driven (poll overwrite):** WHILE the settle loop polls (bounded by `SettleConfig.max_polls`, default 8), each poll's reading for a symbol shall overwrite that symbol's previously-latched reading, so only the last poll's reading (and its `quote_date`) before settling/timeout is used.

4. **State-driven (transient carry-forward):** WHILE a symbol's latest reading remains `Transient` (or absent) once the loop terminates (settled-or-bounded), IF a prior cached `Mark` exists for that symbol, the system shall carry that prior `Mark` forward **unchanged** — both `price_cents` and `quote_date` — as this cycle's mark, never re-stamping it with a new/current timestamp. IF no prior mark exists, the symbol shall be recorded degraded (`TimedOut`), with no mark and no timestamp.

5. **Unwanted behavior (permanent, no carry):** IF a symbol's latest reading is `Permanent`, the system shall record it degraded (`Permanent`) immediately, without exhausting the poll window, and shall discard any prior mark/timestamp for that symbol — permanent errors never carry forward a stale `quote_date`.

6. **Unwanted behavior (sub-cent degrade discards timestamp):** IF a `Numeric` reading's price converts to `Cents ≤ 0` (`price_to_cents` returns `Err(SubCent)`, including the exact-0.0004999→0¢ boundary at `0.0001`, `0.0`, and negative prices), the system shall record the symbol degraded (`SubCent`) with no `Mark` produced — the reading's `quote_date` is discarded, never attached to a fabricated zero mark.

7. **Unwanted behavior (transport failure):** IF the underlying `read_price_pass` call errors, `read_marks` shall propagate the `Err` and produce no `MarksProduced` at all — it shall neither emit an empty/degraded-everything mark set nor itself carry `prior` forward (that carry-forward, preserving prior quote-epoch stamps, is the caller's — `runtime`'s — responsibility on `Err`).

8. **Ubiquitous (sheet-side encoding):** The companion Quote Date formula shall encode `GOOGLEFINANCE`'s `tradetime` as an integer day-count since 1970-01-01 (`INT(tradetime) - DATE(1970,1,1)`), rendered via `TEXT(...,"0")` as a digits-only, locale-independent string, falling back to empty string via `IFERROR` while loading/errored.