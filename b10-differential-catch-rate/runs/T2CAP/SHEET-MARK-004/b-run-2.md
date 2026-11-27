U-MARK-004 — Cached-mark timestamping (marks read-back settle pass, `sheets-view`)

**MARK-STAMP-001 (ubiquitous).** Every mark `sheets-view` produces SHALL carry exactly two fields: an integer `price_cents` (`Cents`) and a `quote_date` (`Date`, days since 1970-01-01). There is no wall-clock, read-time, publish-time, or ingestion-time field on a mark.

**MARK-STAMP-002 (event-driven).** WHEN the settle pass yields a `Numeric` reading for a symbol and its price converts successfully, `sheets-view` SHALL stamp that symbol's mark with the `quote_date` carried by that reading — GOOGLEFINANCE's own quote date — and SHALL NOT substitute the wall-clock read time. (Test pins a reading with `price_usd: 200.0, quote_date: Date(19_100)` producing `Mark { price_cents: Cents(200_00), quote_date: Date(19_100) }`.)

**MARK-STAMP-003 (ubiquitous).** The `Quote Date` column (column M, last column of `POSITIONS_HEADER`) SHALL be published as a live formula, exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")`, using the alias-resolved ticker. Normalization is part of the contract: the trade time is truncated with `INT` to its date serial, re-based to the kernel `Date` epoch by subtracting `DATE(1970,1,1)`, and rendered digits-only via `TEXT(…,"0")` so the values-API read-back is locale-independent. While the quote is loading or errored the formula SHALL yield the empty string.

**MARK-STAMP-004 (event-driven).** WHEN a symbol is still `Transient` (or absent from the pass) after the bounded window and a prior cached mark exists, `sheets-view` SHALL re-emit that prior mark **unchanged — price and quote_date together**, never re-stamping it with a newer date, and SHALL NOT record the symbol degraded. (Prior `Mark { Cents(180_00), Date(19_100) }` emerges byte-identical.)

**MARK-STAMP-005 (unwanted behavior).** IF a reading is `Permanent`, THEN the symbol SHALL be recorded degraded (`DegradeReason::Permanent`) with no mark; its prior mark and prior quote_date SHALL NOT be carried forward.

**MARK-STAMP-006 (unwanted behavior).** IF a reading is `Transient`/absent past `max_polls` and no prior mark exists, THEN the symbol SHALL be degraded `TimedOut` with no mark. IF a numeric price fails conversion (non-positive or sub-cent → `SubCent`; non-finite → `Permanent`), THEN no mark — and therefore no quote-date stamp — SHALL be emitted for that symbol, regardless of the reading's `quote_date`.

**MARK-STAMP-007 (state-driven).** WHILE degraded, a symbol SHALL be absent from `to_ledger_marks()`, which projects only `symbol → price_cents`; the quote_date stamp is retained in `MarksProduced.marks` and never crosses into replay.

**MARK-STAMP-008 (unwanted behavior).** IF `read_price_pass` errors, THEN `read_marks` SHALL propagate `Err` and produce no `MarksProduced`; it SHALL NOT carry `prior` marks (or their stamps) forward itself — offline carry-forward of stamped marks is `runtime`'s. Default `SettleConfig.max_polls` = 8.