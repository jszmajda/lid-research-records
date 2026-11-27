**Reconstructed EARS requirements — transport failure during the marks read-back (settle) pass**

**SHEET-MARK-a (Event-driven).** WHEN a settle-pass poll's underlying `read_price_pass` call fails (workbook unreachable/offline — a transport failure, not a per-symbol reading), THE SYSTEM SHALL have `read_marks` immediately return `Err(ViewError)` and abort the poll loop, without completing further polls.

**SHEET-MARK-b (Unwanted behavior).** IF the underlying transport read fails, THEN `read_marks` SHALL NOT return `Ok` with an empty or partial `MarksProduced`. An empty result would be indistinguishable from "every requested symbol degraded" and would wrongly null out live positions' marks.

**SHEET-MARK-c (Unwanted behavior / state-driven).** IF the transport read fails, THEN `read_marks` SHALL NOT itself carry the caller-supplied `prior` marks into any returned value (none is returned). Retaining the last-good cached marks and re-injecting them into the next replay is the caller's (`runtime`'s) responsibility over its own cache, not this function's.

**SHEET-MARK-d (Ubiquitous).** The bounded retry window (`SettleConfig.max_polls`, default `8`) governs only per-symbol `PriceReading::Transient`/absent readings within an otherwise-succeeding poll loop. A hard transport error is never retried inside `read_marks`: it terminates the pass on the first failing poll regardless of `max_polls` or how many symbols had already settled.

**SHEET-MARK-e (State-driven).** WHILE the target view tab does not yet exist (fresh/cold-start workbook, no prior publish), reading the price pass SHALL succeed with `Ok` and an empty `PricePass` (zero entries) rather than an error — a missing tab is classified distinctly from, and MUST NOT be misread as, a transport failure.

**SHEET-MARK-f (Ubiquitous, boundary/tie-break).** The transport-failure classification (`ViewError`/unreachable) and the missing-tab/cold-start classification (empty result, not an error) are mutually exclusive outcomes keyed on the adapter's own missing-vs-unreachable state, not on read count or retry exhaustion — a missing tab never degrades into a timed-out transport error, and an unreachable transport never resolves to an empty-but-successful pass.

No constants beyond `max_polls = 8` (default) apply to this specific concern; per-symbol degrade reasons (`TimedOut`, `Permanent`, `SubCent`) and cent-rounding are separate concerns not enforced by the transport-failure behavior above.