```
EARS requirements — republish timing & serialization with mark refresh
(sheets-view::Publisher, runtime::cycle, pt wiring/tui_app)

[UB-1] Ubiquitous: One publishing cycle SHALL be republish-then-settle: the write (republish) phase SHALL run to completion before the settle (mark read-back) phase begins. No settle read SHALL occur before or concurrently with any tab write in the same cycle (asserted by call-log ordering: max(write index) < min(read index)).

[UB-2] Ubiquitous: `Publisher::republish_then_settle` SHALL invoke `read_marks` exactly once per cycle immediately after `republish` returns, regardless of whether `republish` reports `published: true` or `false` (a refused write due to a held lock is still followed by a settle attempt).

[UB-3] Ubiquitous: `republish` SHALL acquire the advisory write-lock exactly once (via a single `lock.acquire()` guard) covering ALL tab writes plus the tab-order reassert, releasing on scope exit — never per-tab acquire/release.

[EV-1] Event-driven: WHEN `run_live_cycle`/`run_cycle_publishing` runs (headless summary, TUI connect, TUI refresh, or the post-submit refresh after a confirmed ledger/tax append closes the entry composer), THEN the system SHALL: replay → render all five bands (Positions, Open Lots, Realized, Tax accruals, Tax reserve summary) → republish them → settle marks → re-replay with the newly-settled marks, publishing even an empty ledger (header-only tabs, no data rows) so the workbook view exists from the first run.

[ST-1] State-driven: WHILE the advisory lock is held by another holder, `republish` SHALL perform zero `batch_update_view` calls, return `published: false`, and leave `stale_tabs` unchanged — a non-destructive refusal retried on the next cycle, never a partial or concurrent write.

[UB-4 unwanted]: IF one tab's `batch_update_view` fails, THEN the Publisher SHALL flag only that tab's name stale, attempt a best-effort in-tab banner write of exactly `"STALE — last sync {stale_banner_quote_ts}"` (ignoring the banner write's own failure), and continue publishing the remaining tabs — a single tab failure SHALL NOT abort the cycle. A tab's stale flag SHALL clear only once that tab republishes successfully.

[UB-5 unwanted]: IF `set_tab_order` fails after every tab write succeeded, THEN the cycle outcome SHALL still report `published: false`.

[ST-2] State-driven: The settle phase SHALL poll `read_price_pass` until every requested symbol is Numeric-or-Permanent (not Transient/absent) or `SettleConfig::max_polls` (default 8) is reached, then stop — a bounded, not indefinite, poll loop.

Constants pinned: default `max_polls = 8`; stale banner text format `"STALE — last sync {ts}"`; lock acquired count == 1 per republish call.
```