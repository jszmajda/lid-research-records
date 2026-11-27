**Concern: handling of transient (non-numeric) price-cell readings during the settle-pass read-back (`sheets_view::read_marks`).**

**SHEET-MARK-010 (Ubiquitous).** The settle pass SHALL treat a requested symbol's price-cell reading as *unsettled* whenever it is `PriceReading::Transient` or absent from a poll's `PricePass`; it SHALL treat `Numeric` and `Permanent` readings as *settled*.

**SHEET-MARK-011 (State-driven).** WHILE at least one requested symbol remains unsettled AND the poll count is below `SettleConfig.max_polls`, `read_marks` SHALL re-invoke `client.read_price_pass()` and update each symbol's latest tracked reading (a symbol missing from a given poll retains its previously observed reading rather than reverting to unknown).

**SHEET-MARK-012 (Event-driven).** WHEN every requested symbol becomes settled (numeric-or-terminally-errored), the poll loop SHALL stop immediately, even if `max_polls` has not been reached (e.g., a `Permanent` reading settles on the first poll without exhausting the window).

**SHEET-MARK-013 (Event-driven, unwanted-behavior guard).** WHEN the poll count reaches `SettleConfig.max_polls` (a caller-configured `u32`; default `8`) while a symbol is still `Transient`/absent, the settle pass SHALL stop polling that symbol (bounded retry — never an unbounded loop) and resolve it per SHEET-MARK-014/015.

**SHEET-MARK-014 (Event-driven).** WHEN a symbol is still `Transient`/absent at window end AND a prior cached `Mark` exists for it (`prior: &BTreeMap<Symbol, Mark>`), `read_marks` SHALL carry that prior `Mark` forward unchanged — same `price_cents` and same `quote_date` (never re-stamped to the current pass) — into the output `marks` map, and SHALL NOT insert the symbol into `degraded`.

**SHEET-MARK-015 (Event-driven).** WHEN a symbol is still `Transient`/absent at window end AND no prior cached `Mark` exists, `read_marks` SHALL insert the symbol into `degraded` with reason `DegradeReason::TimedOut` and SHALL NOT emit a mark for it (never a zero/default mark).

**SHEET-MARK-016 (Event-driven, contrast case).** WHEN a symbol's settled reading is `PriceReading::Permanent` (terminal non-numeric error), `read_marks` SHALL insert it into `degraded` with reason `DegradeReason::Permanent` and SHALL NOT carry forward any prior mark for it, even if one exists — Permanent is never treated as transient regardless of prior-cache state.

**SHEET-MARK-017 (Unwanted-behavior).** IF the underlying `client.read_price_pass()` call itself returns `Err` (transport/offline failure), THEN `read_marks` SHALL propagate that `Err` and SHALL NOT produce any `MarksProduced` (not even an empty one), and SHALL NOT consume/clear the caller's `prior` map — carry-forward on transport failure is the caller's (runtime's) responsibility, not this function's.