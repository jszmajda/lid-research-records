SHEET-MARK-TRANSPORT (unwanted-behavior / event-driven set for transport failure during the marks read-back settle pass)

**SHEET-MARK-TRANSPORT-001 (unwanted).** If any `read_price_pass` poll of the settle pass returns an error (workbook unreachable / offline transport failure), then the settle pass shall abort immediately at that poll and propagate that `ViewError` to the caller, returning no `MarksProduced` value.

**SHEET-MARK-TRANSPORT-002 (unwanted).** If the settle pass fails on transport, then it shall not return a `MarksProduced` with an empty (or partial) `marks` map, and shall not record any symbol in `degraded` — an empty marks set would read as "all symbols degraded" and wrongly null live positions.

**SHEET-MARK-TRANSPORT-003 (unwanted).** If the settle pass fails on transport, then the pass shall not itself carry the supplied `prior` marks forward into an output; carry-forward of prior marks on transport failure is `runtime`'s responsibility — `runtime` retains its existing cached marks with their quote-date stamps and re-injects them into the next replay. This holds even when `prior` is non-empty (a prior good mark, e.g. `Cents(180_00)` @ `Date(19_100)`, is not emitted).

**SHEET-MARK-TRANSPORT-004 (event-driven).** When a poll errors, the settle pass shall abort regardless of poll index — including the first poll, before `max_polls` (default 8) is reached — and shall not continue polling after the error.

**SHEET-MARK-TRANSPORT-005 (unwanted).** If a transport failure occurs, it shall be surfaced as a transport-class `ViewError` distinct from the settle-window-exhausted case (`ViewError::SettleTimeout`) and from per-symbol degradation (`DegradeReason::TimedOut` / `Permanent` / `SubCent`) — transport failure never degrades symbols.

**SHEET-MARK-TRANSPORT-006 (event-driven, `republish_then_settle`).** When the settle read fails on transport inside a combined republish-then-settle cycle, the cycle shall propagate the error and return neither the `RepublishOutcome` nor marks, even though the republish half already ran and committed its per-tab writes/stale flags.

**SHEET-MARK-TRANSPORT-007 (unwanted, classification boundary).** A missing Positions tab (fresh workbook) shall not be classified as a transport failure: `read_price_pass` shall return `Ok` with an empty `PricePass` ("no tab yet ⇒ no marks, not an outage"), while an unreachable workbook shall classify as the transport/unreachable error and never be misread as a missing tab.

**SHEET-MARK-TRANSPORT-008 (ubiquitous).** A failed sheets-view I/O crossing shall never corrupt canonical truth; the append-only log is `store`-owned and unaffected — a failure leaves views stale, to be retried on the next sync.