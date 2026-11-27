## EARS Requirements: Republish Serialization with Mark Refresh

**PUBLISH-REFRESH-001: Publishing cycle on every live run**
Republish runs on every call to `run_live_cycle` — including headless summary, TUI initial connect, manual refresh `[r]`, post-submit refresh, and automatic hourly refresh. These are the only times the view tabs are written to the workbook.

**PUBLISH-REFRESH-002: Serialized republish→settle loop**
The publishing cycle is ONE serialized control thread: replay with injected prior marks → render five view bands (Positions, Open Lots, Realized, Tax accruals, Tax reserve summary) → **atomic republish under the advisory write-lock** → **release lock** → **settle pass (mark read-back) without lock**. This order is enforced by the sole call path `Publisher::republish_then_settle`, which returns only after both halves complete.

**PUBLISH-REFRESH-003: Settle pass runs after all writes**
The settle pass (price-cell read-back via `read_price_pass` polling) executes only after all `batchUpdate` writes return. Test `every_settle_read_happens_after_all_writes_in_a_cycle` validates via call-log ordering that every `ReadPricePass` index exceeds every `BatchUpdate` index in the same cycle, even across multiple settle polls.

**PUBLISH-REFRESH-004: Lock acquire/release bounds**
Lock is acquired once at republish entry; released immediately after all tab writes and tab-order reassert complete. Settle pass runs without the lock held. If lock is foreign-held (LockError::Held), republish writes nothing, returns `published: false`, and leaves the stale tab set unchanged.

**PUBLISH-REFRESH-005: Bounded settle polling**
Settle pass polls up to `max_polls: 8` times (default `SettleConfig`). Each poll reads `GOOGLEFINANCE` price cells. Loop exits early when all requested symbols are numeric or terminally errored, or when poll count reaches limit.

**PUBLISH-REFRESH-006: Symbol mark production rules**
- **Numeric reading**: Convert price USD to `Cents` via `round_half_to_even(price × 100)`. Record mark with `GOOGLEFINANCE` quote date.
- **Transient (#N/A/Loading) past window**: Carry forward prior good mark; if no prior, degrade `TimedOut`.
- **Permanent error**: Degrade `Permanent`; no prior carry.
- **Positive price → 0¢**: Degrade `SubCent`.
- **Non-positive or non-finite price**: Degrade `SubCent` or `Permanent`.

**PUBLISH-REFRESH-007: Marks injection & caching**
Degraded symbols are **absent** from cached marks (never zero). Each cycle injects prior cycle's marks into replay (symbol → `Cents`). New marks from settle pass become this cycle's cache (recorded per-symbol with quote-epoch stamp). Trading-day key reduced to `max(quote_date across priced symbols)`, or `None` if no priced symbol.

**PUBLISH-REFRESH-008: Stale marking & retry**
Failed republish (write error) marks the affected tab stale, writes best-effort in-tab `STALE` banner with last-sync timestamp, and returns `published: false`. Tab is retried on next sync; stale flag cleared only when republish succeeds.

**PUBLISH-REFRESH-009: Fresh workbook publishing**
Even a fully fresh workbook (no events, no view tabs) publishes all five empty bands on first run, so the view surface exists rather than being deferred to first content.