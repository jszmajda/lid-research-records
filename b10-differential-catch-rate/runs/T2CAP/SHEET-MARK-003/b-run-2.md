SHEET-MARK-TRANSIENT (transient non-numeric price cells on read-back)

Ubiquitous. The settle pass SHALL classify each symbol's Positions `Price` cell reading as exactly one of: Numeric{price_usd: f64, quote_date: Date}, Transient (`#N/A`/`Loading...`, not-yet-known), or Permanent (terminal non-numeric error, e.g. ticker-form mismatch).

Ubiquitous. The settle read SHALL be a separate pass after the tab write, never inline with the formula write; each `read_price_pass` call is one poll, keyed by symbol (one entry per symbol).

Event-driven. When a settle pass runs, the system SHALL poll until every requested symbol is non-Transient and present, or until `max_polls` polls have been issued, whichever is first. Default `max_polls` = 8. A symbol absent from the pass is treated identically to Transient (unsettled).

Unwanted-behavior. If any requested symbol remains Transient/absent, the system SHALL NOT poll more than `max_polls` times (poll count is exactly `max_polls` when never settling — no infinite loop).

Event-driven. When all requested symbols are Numeric or Permanent, the loop SHALL terminate immediately without exhausting the window (a Permanent reading settles the loop on the first poll: read_count < max_polls).

State-driven. While a symbol's latest reading is Transient/absent after the bounded window, if a prior cached mark exists the system SHALL carry that prior Mark forward unchanged (price_cents AND quote_date) into `marks` and SHALL NOT record the symbol degraded.

State-driven. While a symbol's latest reading is Transient/absent after the bounded window and no prior mark exists, the system SHALL record it degraded with reason `TimedOut` and SHALL emit no mark for it.

Event-driven. When a symbol's reading is Permanent, the system SHALL record it degraded with reason `Permanent`, emit no mark, and SHALL NOT carry the prior mark forward (a terminal error is not transient).

Unwanted-behavior. A transient reading SHALL NEVER overwrite, null, or zero an existing cached mark.

Ubiquitous. A degraded symbol SHALL be ABSENT from the `ledger_core::Marks` projection (`to_ledger_marks`), so replay degrades it per-symbol (unrealized = None, never zero). A carried prior mark IS present, so the position values at the carried price.

Unwanted-behavior. If the read transport fails (workbook unreachable/offline), the settle pass SHALL propagate the error and produce no `MarksProduced` — never an empty/all-degraded marks set; the caller retains its prior cached marks unchanged for re-injection.

Ubiquitous. Only symbols on the Positions tab SHALL be requested; a fully-disposed symbol (qty 0) is never requested, hence neither priced nor recorded degraded, and absent from per-symbol freshness and the trading-day reduction.

Ubiquitous. The `Quote Date` companion formula SHALL wrap in `IFERROR(...,"")`, rendering an empty string while the quote is loading/errored: `=IFERROR(TEXT(INT(GOOGLEFINANCE("T","tradetime"))-DATE(1970,1,1),"0"),"")` — days since 1970-01-01, digits-only, locale-proof.

Ubiquitous. A Numeric reading converts via `round_half_to_even(price_usd × 100)` (SCALE 1e6): 1.005→100¢, 1.015→102¢. Result ≤ 0 degrades `SubCent` (0.0001, 0.0, −5.0); non-finite (NaN, ±∞) degrades `Permanent`. Marks are stamped with GOOGLEFINANCE's quote_date, never wall clock.