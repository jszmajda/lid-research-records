SHEET-MARK-TRANSIENT (transient non-numeric price cells during read-back)

**Ubiquitous / classification**
- Each `Price` cell read on a settle pass SHALL be classified as exactly one of: `Numeric{price_usd, quote_date}`, `Transient` (`#N/A`/`Loading...`, not-yet-known), or `Permanent` (terminal non-numeric error, e.g. ticker-form mismatch). A symbol absent from a pass SHALL be treated identically to `Transient`.
- The settle read SHALL be a separate pass after the write, never inline with the formula write.
- The companion `Quote Date` formula SHALL yield an empty string (`IFERROR(...,"")`) while the quote is loading or errored: `=IFERROR(TEXT(INT(GOOGLEFINANCE("T","tradetime"))-DATE(1970,1,1),"0"),"")`.

**Event-driven / state-driven (settle loop)**
- WHILE any requested symbol's latest reading is `Transient` or absent, the settle pass SHALL poll `read_price_pass` again, retaining the latest reading per symbol, up to `max_polls` (default `SettleConfig{max_polls: 8}`).
- WHEN every requested symbol is `Numeric` or `Permanent`, the loop SHALL exit immediately without exhausting the window (a `Permanent`-only pass SHALL cost fewer than `max_polls` reads; exactly one poll settles when all readings arrive numeric/permanent).
- Total polls SHALL never exceed `max_polls` (a permanently-transient symbol with `max_polls: 3` yields exactly 3 reads; `max_polls: 4` yields exactly 4).
- Only symbols in the requested `symbols` list SHALL be settled or degraded; a symbol not requested (e.g. a fully-closed position at qty 0) SHALL be neither marked nor recorded degraded.

**Unwanted behavior (transient must not destroy value)**
- IF a symbol remains `Transient`/absent past the bounded window AND a prior good cached mark exists, THEN the system SHALL carry that prior `Mark` forward unchanged (both `price_cents` and its original `quote_date`) into this pass's `marks`, and SHALL NOT record it degraded.
- IF a symbol remains `Transient`/absent past the window AND no prior mark exists, THEN it SHALL be recorded `degraded = TimedOut` with no mark.
- IF a reading is `Permanent`, THEN the symbol SHALL be recorded `degraded = Permanent` with no mark, and the prior mark SHALL NOT be carried (terminal ≠ transient).
- A degraded symbol SHALL be ABSENT from `to_ledger_marks()`, so replay leaves `unrealized_cents = None` (never `Some(0)`).
- IF the underlying `read_price_pass` fails (offline/unreachable), THEN `read_marks` SHALL propagate the `Err` and produce no `MarksProduced` — it SHALL NOT emit an empty marks set nor itself carry `prior` forward; the caller retains its existing cached marks.

**Numeric conversion boundary (applies to settled readings)**
- `price_to_cents` SHALL be `round_half_to_even(price_usd × 100)` via the canonical helper (scale 1e6): 200.0→20000¢, 150.25→15025¢, 1.005→100¢, 1.015→102¢.
- Non-finite (`NaN`, `±∞`) SHALL degrade `Permanent`; any result ≤ 0 cents — including a positive sub-cent price (0.0001), 0.0, or negative — SHALL degrade `SubCent` with no mark, never a zero/negative mark.
- A settled mark SHALL be stamped with GOOGLEFINANCE's own `quote_date`, never wall-clock read time.