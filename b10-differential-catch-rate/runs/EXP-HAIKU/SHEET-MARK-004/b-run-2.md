# MARK TIMESTAMPING REQUIREMENTS

**SHEET-MARK-001-QUOTE-DATE-SOURCE** (ubiquitous): Each cached mark is stamped with `quote_date` — a Date value extracted from GOOGLEFINANCE's `tradetime` value returned on the numeric price reading. The quote_date is the GOOGLEFINANCE quote epoch (days since 1970-01-01), not wall-clock time of the read operation.

**SHEET-MARK-002-QUOTE-DATE-ENCODING** (ubiquitous): The quote_date is transmitted from sheets back to runtime as a digits-only string (via `TEXT(...,"0")` in the formula), encoding days since 1970-01-01 by truncating GOOGLEFINANCE's trade time to date and subtracting DATE(1970,1,1). This encoding is locale-proof (digits only) and matches the kernel's Date epoch.

**SHEET-MARK-003-SETTLE-POLLING-BOUNDED** (event-driven): On each settle pass, poll `read_price_pass()` iteratively until either (a) every requested symbol has a numeric or terminal-error reading, or (b) the bounded window (`cfg.max_polls`, default 8 polls) elapses. Each poll updates the latest reading per symbol; no partial settle.

**SHEET-MARK-004-NUMERIC-MARK-PRODUCTION** (state-driven): A numeric price reading (Numeric { price_usd, quote_date }) produces a mark by: (1) converting price_usd to Cents via `round_half_to_even(price_usd × 100)` with integer SCALE of 1e6; (2) stamping with the reading's quote_date; (3) any positive price rounding to ≤0 Cents degrades (SubCent), never a zero or negative mark. Non-finite prices (NaN, ±∞) degrade (Permanent).

**SHEET-MARK-005-TRANSIENT-PRIOR-CARRY** (state-driven): A symbol remaining Transient or absent through the polling window carries forward its prior cached mark (if one exists) without overwriting it — the mark retains its original quote_date. If no prior mark exists, the symbol degrades (TimedOut) instead. Transient symbols are never themselves recorded degraded if a prior mark is available.

**SHEET-MARK-006-PERMANENT-NO-PRIOR-CARRY** (state-driven): A terminal error reading (Permanent) immediately degrades the symbol — it does NOT carry forward a prior cached mark, even if one exists. The permanent error settles the loop early (within one poll).

**SHEET-MARK-007-TRANSPORT-FAILURE-PROPAGATION** (unwanted-behavior): If the settle pass read itself fails (ViewError), the error propagates and produces no marks. The system never silently emits an empty marks set (which would appear as all-symbols-degraded and wrongly null live positions). Runtime retains its existing cached marks with their quote_date stamps and re-injects them into the next replay.