**Ubiquitous:**
- The system shall run republish (writing the view tabs) and the marks settle pass (reading back GOOGLEFINANCE `Price`/`Quote Date` cells) as one serialized loop per cycle: every settle read shall occur strictly after all of that cycle's tab writes complete — never inline with or before them.
- The system shall hold the advisory write-lock only for the republish (write) half; the settle (read) half shall run unlocked, after the lock guard has already been released.
- The system shall restrict the settle-pass symbol set to open positions only (`total_qty != 0`); closed/fully-disposed symbols shall never be priced.
- The system shall write each view tab as one atomic per-tab update from row `DATA_START_ROW` (2), truncating the tail to the exact new row count, and shall never rewrite the frozen header row (row 1).
- The system shall reduce per-symbol quote-epochs to one trading-day key = the maximum quote-epoch across priced symbols, or `None` when no symbol is priced this cycle.
- Price→Cents conversion is the single canonical `round_half_to_even(price_usd × 100)`; a positive price rounding to ≤0 cents, or any non-positive/non-finite reading, is never a real mark.

**Event-driven:**
- WHEN the advisory lock cannot be acquired (held by another holder), the system shall write nothing that cycle and report `published=false` with the stale set unchanged.
- WHEN a tab's write fails, the system shall flag that tab stale, best-effort write an in-tab banner `"STALE — last sync {ts}"`, leave other tabs unaffected, and retry that tab next cycle.
- WHEN a previously-stale tab's write succeeds, the system shall clear its stale flag.
- WHEN the tab-order reassert fails after all per-tab writes succeed, the system shall still report `published=false`.
- WHEN a settled symbol's numeric reading is sub-cent or non-finite, the system shall record it degraded (`SubCent`/`Permanent`) instead of a mark.
- WHEN a symbol stays transient/absent past `max_polls` (default 8) polls, the system shall degrade it `TimedOut`, carrying forward its prior cached mark if one exists, else recording no mark.
- WHEN a confirmed ledger/tax append closes the entry composer, or on manual/hourly (absent an open entry) refresh, the system shall re-run the publish-then-settle cycle.

**Unwanted-behavior:**
- IF the settle transport errors, THEN the system shall propagate the error (never fabricate an empty marks set); the caller retains its previously cached marks rather than discarding them.
- IF a symbol is still transient, THEN the system shall never overwrite its previously cached good mark with the transient reading.