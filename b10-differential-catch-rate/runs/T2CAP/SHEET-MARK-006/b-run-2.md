SHEET-MARK-TRANSPORT (transport failure during the marks read-back / settle pass)

**SHEET-MARK-ERR-001 (Unwanted behavior).** IF the underlying `SheetsViewClient::read_price_pass` call fails during the settle pass (workbook unreachable / offline / transport error), THEN the marks read-back SHALL abort immediately at that poll and propagate the `ViewError` to its caller, and SHALL NOT return a `MarksProduced` value.

**SHEET-MARK-ERR-002 (Unwanted behavior).** IF the settle pass fails on transport, THEN the system SHALL NOT emit an empty or partial marks set for the requested symbols, and SHALL NOT record any symbol as degraded on account of that failure — an empty set would read as "all symbols degraded" and wrongly null live positions.

**SHEET-MARK-ERR-003 (Unwanted behavior).** IF the settle pass fails on transport, THEN the read-back SHALL NOT itself carry the supplied `prior` marks forward into a returned result; the `prior` map SHALL be left unapplied even when it holds a good mark for a requested symbol.

**SHEET-MARK-ERR-004 (Event-driven).** WHEN the marks read-back returns an error, THEN `runtime` SHALL retain its existing cached marks together with their per-symbol quote-date stamps and re-inject them into the next replay, so the kernels continue on the last known good marks.

**SHEET-MARK-ERR-005 (Event-driven).** WHEN transport fails on the *first* poll, THEN the failure SHALL propagate without further polling; no bounded-window exhaustion (`SettleConfig.max_polls`, default 8) and no degrade classification SHALL be applied to that cycle.

**SHEET-MARK-ERR-006 (State-driven).** WHILE a settle pass is running as the second half of a republish-then-settle cycle, IF the read-back errors, THEN `republish_then_settle` SHALL propagate that error and return no result pair, discarding the already-computed `RepublishOutcome` — the workbook write already performed is not rolled back and truth (the canonical event log) is unaffected.

**SHEET-MARK-ERR-007 (Ubiquitous, classification).** A transport failure SHALL be represented as a transport-class error distinct from both the transient `#N/A`/`Loading…` reading (`PriceReading::Transient` → retry / prior carry) and the terminal non-numeric error (`PriceReading::Permanent` → `DegradeReason::Permanent`); no transport failure SHALL be reduced to a `DegradeReason`.

**SHEET-MARK-ERR-008 (Event-driven, boundary).** WHEN the Positions tab does not yet exist on a fresh workbook, the price pass SHALL return an empty `PricePass` successfully (no marks) rather than a transport error — a missing tab is a cold start, not an outage; conversely a genuine transport failure SHALL never be classified as a missing tab/cold start.