SHEET-PUB-001 (Ubiquitous) — Republish and mark refresh shall run as ONE serialized loop on a single thread of control: all view-tab writes complete first, then the settle read pass runs. Every `read_price_pass` call in a cycle shall occur strictly after every `batch_update_view` of that cycle; no settle read may be inline with or before a formula write.

SHEET-PUB-002 (Event-driven) — WHEN a publishing cycle is triggered, the system shall load the event log, replay with the prior cached marks, render the five typed bands (Positions, Open Lots, Realized, Tax accruals, Tax·Reserve Summary), republish them, then settle. Triggers: TUI connect; manual `[r]`; the ambient auto-refresh; a refresh after a confirmed durable event append (entry context closed); each headless `summary` run. Every trigger rides the same one path.

SHEET-PUB-003 (Event-driven) — WHEN the auto-refresh interval has elapsed since the last successful refresh, the system shall run that same cycle, EXCEPT while an entry composer is open, in which case it is deferred to the first tick (1 s poll) after the composer closes; a help overlay shall not suppress it. Only a refresh yielding a live connection advances the last-refresh clock, so a failed cycle is retried on the next tick.

SHEET-PUB-004 (State-driven) — Republish shall acquire the runtime-owned advisory write-lock before any workbook mutation and release it when the writes return; the settle pass shall run outside the lock.

SHEET-PUB-005 (Unwanted) — IF the advisory lock is held by another holder (or acquisition errors), THEN republish shall write nothing, return `published: false` with the stale set unchanged, and the cycle shall still settle; retry occurs on the next sync.

SHEET-PUB-006 (Unwanted) — IF a tab's atomic `batchUpdate` fails, THEN that tab shall be flagged stale, a best-effort in-tab banner `"STALE — last sync {quote_ts}"` written (the live ts is the run's `as_of` as `YYYY-MM-DD`), `published` set false, and the tab retried next sync; a successful republish clears the flag. IF the banner write also fails, THEN the tab stays flagged and the TUI remains the staleness surface.

SHEET-PUB-007 (Unwanted) — IF the workbook tab-order reassert (performed on every republish) fails, THEN `published` shall be false without flagging any tab stale.

SHEET-PUB-008 (Event-driven) — WHEN settling, the system shall poll only open-position symbols (`qty != 0`), bounded by `max_polls` (default 8; live runs use the default).

SHEET-PUB-009 (Unwanted) — IF the settle read errors (offline), THEN the whole cycle shall return `Err`, discarding the republish outcome; the caller retains and re-injects its prior cached marks.

SHEET-PUB-010 (Event-driven) — WHEN settle completes, the system shall cache the marks and re-replay in-run with them; it shall NOT republish again that cycle (published tabs keep the pre-settle render).

SHEET-PUB-011 (State-driven) — WHERE view tabs or the whole workbook are missing/empty, republish shall still bootstrap all five bands (frozen header row 1, data from row 2, tail truncated to the exact row count).