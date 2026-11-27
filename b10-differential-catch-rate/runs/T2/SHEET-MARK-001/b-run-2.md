**Concern: marks read-back (settle pass) after GOOGLEFINANCE formula writes.**

**Event-driven:** WHEN a republish cycle completes (`republish_then_settle`), the system SHALL read Price/Quote-Date cells back as a pass strictly AFTER the write returns and never inline with/before the formula write; every read call in the seam log SHALL follow every write call in that cycle.

**Ubiquitous — location/format:** The settle read SHALL target the Positions tab range `'{tab}'!A{DATA_START_ROW}:Z` (DATA_START_ROW=2), Symbol at column 0, Price at column 0-indexed column 4, Quote Date at column 12. A row whose Symbol cell is empty SHALL be skipped (not entered into the pass).

**State-driven:** WHILE any requested symbol's latest reading is Transient or absent, the system SHALL keep polling `read_price_pass`, retaining the most recent reading per symbol across polls, bounded by `SettleConfig.max_polls` (default 8); polling SHALL stop once every requested symbol is Numeric or Permanent, or once max_polls is reached, whichever first.

**Ubiquitous — cell normalization:** Price text SHALL be trimmed. Empty string, case-insensitive `"Loading..."`, or exact `"#N/A"` SHALL classify as Transient. Any other text starting with `#` SHALL classify as Permanent. Text parsing as f64 SHALL classify Numeric (with Quote Date parsed as i32 from column 12, defaulting to `Date(0)` if missing/unparseable); non-numeric, non-`#` text SHALL classify as Permanent.

**Ubiquitous — rounding:** `price_to_cents` SHALL compute `round_half_to_even(price_usd × 100)` via integer scaling (×1,000,000) before rounding (banker's rounding): e.g. 1.005→1.00, 1.015→1.02.

**Unwanted behavior:** IF a Numeric price is non-finite (NaN/±Inf) THEN the system SHALL degrade it Permanent. IF a Numeric price rounds to ≤0 cents THEN the system SHALL degrade it SubCent — never emit a zero/negative mark.

**State-driven (window/carry):** IF the poll window elapses while a symbol is still Transient/absent AND a prior mark exists THEN the system SHALL carry the prior mark forward unchanged and SHALL NOT record it degraded. IF no prior mark exists THEN it SHALL degrade TimedOut with no mark. IF a symbol's latest reading is Permanent THEN it SHALL degrade Permanent immediately (loop need not exhaust the window) with NO prior-mark carry, even if a prior mark exists.

**Unwanted behavior (transport):** IF `read_price_pass` itself errors THEN `read_marks` SHALL propagate `Err` and SHALL NOT emit an empty `MarksProduced` (would misread as all-degraded).

**Boundary:** A not-yet-created Positions tab SHALL read as an empty `PricePass`, not an error.

**Ubiquitous:** Degraded symbols SHALL be absent (not zero) from `to_ledger_marks`.