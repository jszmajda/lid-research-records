**Ubiquitous**
- U1: Republish and the marks settle-read run as ONE serialized loop per cycle: every view-tab `batchUpdate` write completes before the settle pass's first `read_price_pass` call; settle never runs concurrently with, or before, any write in that cycle (asserted: last write index < first read index).
- U2: Republish acquires the advisory write-lock immediately before mutating any tab and releases it (guard drops) before settle begins — only the write half is lock-guarded.
- U3: Each of the five bands (Positions, Open Lots, Realized, Tax-accruals, Tax-reserve-summary) is rewritten as its own atomic `batchUpdate`: data starts at fixed row 2 (`DATA_START_ROW`) beneath a header written once and never rewritten; any residual tail past the new row count is truncated — no half-written window, no leftover rows.
- U4: After per-tab writes, the workbook tab order is unconditionally reasserted; its failure marks the cycle `published=false` but adds no per-tab stale flag.
- U5: The settle pass polls up to `SettleConfig::max_polls` (default 8) times, stopping early once every requested symbol is numeric-or-terminally-errored.

**Event-driven**
- E1: WHEN a live cycle runs (headless-summary invocation, TUI connect, manual `[r]`, the ambient auto-refresh tick, or the deferred refresh after a composer closes post-submit), the system SHALL run replay → render five bands → republish → settle-read → cache marks → reduce trading-day key → reprice by replaying once more with this cycle's marks.
- E2: WHEN the composer's submit confirms a durable append (entry context closes), the TUI SHALL immediately trigger the shared refresh rather than wait for the next tick.
- E3: WHEN a tab's `batchUpdate` fails, the system SHALL flag it stale, attempt a best-effort in-tab banner of exact text `"STALE — last sync {quote_ts}"`, still publish all other tabs, and retry the failed tab next sync.
- E4: WHEN a stale tab's `batchUpdate` later succeeds, its stale flag clears.

**State-driven**
- S1: WHILE an entry composer is open, ambient auto-refresh is suppressed.
- S2: WHILE the write-lock is held by another holder, republish writes nothing, leaves the stale set unchanged, and reports `published=false` — non-destructive refusal, no blocking/partial write.
- S3: WHILE the refreshed view is not Live, the auto-refresh clock does not advance, so the next tick retries.

**Unwanted-behavior**
- N1: IF the best-effort banner write also fails, THEN this is not an additional error — the tab stays stale (TUI is the fallback staleness surface); nothing propagates.
- N2: IF the settle read-back transport fails, THEN the error propagates (never a silently-empty marks set); the caller retains and re-injects its prior cached marks.