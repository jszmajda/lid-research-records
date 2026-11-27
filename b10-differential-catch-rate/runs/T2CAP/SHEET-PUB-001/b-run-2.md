PUB-REPUB-001 (ubiquitous) The system SHALL run republish and mark refresh as ONE serialized loop on a single thread of control (`Publisher::republish_then_settle`), never concurrently.

PUB-REPUB-002 (event-driven) WHEN a publishing cycle is triggered, the system SHALL, in strict order: load the event log; replay ledger-core then tax with the PRIOR cycle's cached marks; render five typed bands (Positions, Open Lots, Realized, Tax accruals, Tax·Reserve Summary); republish those bands; THEN run the settle read pass; cache the read-back marks; reduce the trading-day key; and re-replay with THIS run's marks so held output is valued at this run's sync. The published tabs keep the pre-settle render (no second publish).

PUB-REPUB-003 (state-driven) WHILE a republish is in progress the system SHALL hold the runtime-owned advisory write-lock, acquired exactly once before any workbook mutation and released before the settle pass; the settle pass SHALL run outside the lock.

PUB-REPUB-004 (unwanted) IF the advisory lock is held by another holder (or acquisition errors), THEN republish SHALL write nothing, leave the stale set unchanged, and return `published: false`; the next sync retries.

PUB-REPUB-005 (unwanted) IF a settle read occurs before or inline with any republish write of the same cycle, THAT IS PROHIBITED — every price read SHALL follow the last `batchUpdate`.

PUB-REPUB-006 (event-driven) WHEN a tab's atomic `batchUpdate` fails, the system SHALL flag that tab stale, write a best-effort in-tab banner `"STALE — last sync {quote_ts}"`, report `published: false`, and retry next sync; a successful republish clears the flag. IF the banner write also fails, THEN the tab SHALL remain flagged stale (the TUI is the staleness surface). Tab-order reassert failure also sets `published: false`.

PUB-REPUB-007 (event-driven) WHEN republishing, each tab SHALL be one atomic `batchUpdate` writing data from `DATA_START_ROW = 2` beneath a never-rewritten frozen header, truncating the residual tail to the exact new row count; a fresh workbook SHALL bootstrap all five bands, header-only when empty.

PUB-REPUB-008 (ubiquitous) The settle pass SHALL price only open positions (`total_qty != 0`), polling to `SettleConfig.max_polls` (default 8; live path uses the default).

PUB-REPUB-009 (unwanted) IF the settle read transport fails, THEN the cycle SHALL propagate `ViewError` (as `CycleError::View`), emit no marks, and the caller SHALL retain and re-inject its prior cached marks.

PUB-REPUB-010 (event-driven) WHEN the headless summary runs, the TUI connects, a manual `[r]`/post-append refresh occurs, or the hourly auto-refresh is due, the system SHALL run this publishing cycle. Auto-refresh SHALL be suppressed while an entry composer is open (deferred to the first tick after close; the help overlay does not suppress) and the refresh clock SHALL advance only on a Live result.