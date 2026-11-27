SHEET-MARK-TRANSIENT (transient non-numeric price cells on read-back)

**Ubiquitous / classification.** The system shall classify each Positions-tab `Price` cell reading on a settle pass as exactly one of: `Numeric{price_usd: f64, quote_date: Date}`, `Transient` (a not-yet-resolved `#N/A`/`Loading...`), or `Permanent` (a terminal non-numeric error, e.g. a ticker-form mismatch). The companion `Quote Date` cell shall render as `=IFERROR(TEXT(INT(GOOGLEFINANCE("T","tradetime"))-DATE(1970,1,1),"0"),"")` — a locale-independent digits-only day count on the kernel `Date` epoch — yielding the empty string while the quote is loading or errored.

**Event-driven (settle loop).** When a settle pass runs, the system shall poll `read_price_pass` repeatedly, retaining the latest reading per requested symbol, and shall stop as soon as every requested symbol is non-transient and present, or when the poll count reaches `SettleConfig.max_polls` (default 8), whichever is first. Polling shall be bounded: with an always-transient symbol and `max_polls = N`, exactly N polls occur. A `Permanent` reading terminates the loop immediately (poll count strictly below `max_polls`); a symbol that settles numeric on poll 2 causes ≥2 polls.

**State-driven (carry-forward).** While a requested symbol's latest reading is `Transient` or absent after the bounded window, the system shall, if a prior cached mark exists for that symbol, emit that prior `Mark` unchanged (both `price_cents` and its original `quote_date`) and shall not record the symbol degraded; if no prior mark exists, it shall record the symbol degraded with `DegradeReason::TimedOut` and emit no mark.

**Unwanted behavior — no transient overwrite.** The system shall never overwrite or null a good cached mark with a transient reading; the carried mark shall value the position on the next replay (a carried 170.00 over 3 shares at 150.00 basis yields 60.00 unrealized).

**Unwanted behavior — Permanent is not transient.** If a symbol reads `Permanent`, the system shall record it degraded with `DegradeReason::Permanent`, emit no mark, and shall not carry the prior mark forward, even when one exists.

**Degradation projection.** A degraded symbol shall be absent from `to_ledger_marks()`, so the kernel degrades it per-symbol (`unrealized_cents = None`, never zero) and it contributes nothing to the trading-day-key reduction (most-recent quote epoch across priced symbols; `None` when none priced) or to per-symbol freshness.

**Unwanted behavior — transport failure is not degradation.** If `read_price_pass` returns `Err`, `read_marks` shall propagate the error and produce no `MarksProduced`; it shall not emit an empty marks set nor itself carry `prior` forward. The caller retains its prior cached marks.

**Request scope.** Only symbols passed in `symbols` (open positions) shall be settled; a fully-disposed symbol (qty 0) is never requested and therefore never recorded `TimedOut`.

**Numeric conversion boundary.** A `Numeric` reading converts via `round_half_to_even(price_usd × 100)` (scale 1e6): 1.005 → 100¢, 1.015 → 102¢. Result ≤ 0 (sub-cent positive, 0.0, negative) degrades `SubCent`; non-finite (NaN, ±∞) degrades `Permanent`. Marks are stamped with `GOOGLEFINANCE`'s quote date, never wall-clock read time. The read-back is a separate pass after the write, never inline.