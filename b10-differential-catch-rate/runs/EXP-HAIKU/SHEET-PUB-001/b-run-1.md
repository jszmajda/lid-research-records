**EARS-Style Requirements: Republish Triggers and Serialization with Mark Refresh**

PUBLISH-CYCLE-001 (event-driven): Every successful ledger event append triggers an immediate republish. Following `entry_submit`, a confirmed durable append closes the entry context, and the next tick calls `run_refresh` — which re-runs the publishing cycle so the workbook view reflects the append.

PUBLISH-CYCLE-002 (event-driven): Every successful tax event append triggers an immediate republish via the same refresh path.

PUBLISH-CYCLE-003 (event-driven): The headless `summary` run triggers a publishing cycle. A read-only cycle runs `load_run_and_publish`, which loads the log, replays, renders the view tabs, and drives the one serialized republish→settle loop.

PUBLISH-CYCLE-004 (event-driven): Manual `[r]` refresh key triggers the publishing cycle via `run_refresh`.

PUBLISH-CYCLE-005 (state-driven): Ambient hourly auto-refresh triggers the publishing cycle when `shell::should_autorefresh` decides (elapsed time exceeds `AUTOREFRESH_INTERVAL`), unless an entry composer is open (deferred refresh runs on first tick after composer closes).

PUBLISH-CYCLE-006 (ubiquitous): The republish-settle loop is ONE serialized cycle. `republish_then_settle` executes: (1) republish all five view bands (Positions, Open Lots, Realized, Tax accruals, Tax reserve summary) atomically via per-tab `batchUpdate`, (2) **THEN** (same thread, never concurrent) read marks back on the settle pass. The settle read happens only after all writes complete; every `ReadPricePass` poll falls after the final `BatchUpdate`.

PUBLISH-CYCLE-007 (ubiquitous): Republish acquires the runtime-owned advisory write-lock BEFORE mutating the workbook and releases it after. A foreign `Held` lock causes republish to write nothing — returns `published: false` with the current stale set, non-destructive refusal.

PUBLISH-CYCLE-008 (ubiquitous): The settle pass polls `read_price_pass` with bounded retry (default `max_polls: 8`, configurable via `SettleConfig`). Polling continues until every position symbol is numeric-or-terminally-errored or the window elapses. Each numeric reading converts to integer `Cents` via `round_half_to_even(price_usd × 100)`; a positive price rounding to zero cents degrades `SubCent`. Non-finite prices (NaN, ±∞) degrade `Permanent`.

PUBLISH-CYCLE-009 (ubiquitous): A symbol staying transient past the bounded window carries its prior cached good mark forward (no null override). A terminal error (`Permanent`) degrades the symbol with reason, no prior carry. Degraded symbols absent from marks; `ledger-core` replay degrades per-symbol.

PUBLISH-CYCLE-010 (ubiquitous): The trading-day key is the most-recent quote-epoch across priced (non-degraded) symbols, reduced once per cycle. Zero-key cycles (no priced symbol) carry no trading-day key — `None` branches degrade silently, no synthetic day.

PUBLISH-CYCLE-011 (ubiquitous): The cycle caches the read-back marks (good + degraded) and injects the good marks into the next replay's `ledger-core::Marks`. A per-symbol quote-epoch stamp survives for per-symbol freshness display.

PUBLISH-CYCLE-012 (unwanted-behavior): Failed republish never corrupts the canonical event log (store's Ledger/Tax tabs). A failed `batchUpdate` flags the view tab stale, writes a best-effort in-tab stale banner (`STALE — last sync {quote_ts}`), and retries on the next sync.

{scratch}/audit-baseline