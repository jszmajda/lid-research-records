**EARS requirements enforced (republish timing + serialization with mark refresh):**

1. **Event-driven.** WHEN a live cycle runs (TUI connect, TUI refresh — manual `[r]`, the hourly automatic tick, or the deferred post-submit refresh after a confirmed durable append — or a `pt summary` invocation) THE SYSTEM SHALL execute exactly one republish-then-settle cycle via the publishing path (`run_cycle_publishing` → `Publisher::republish_then_settle`); no live entry point uses a settle-only path without a preceding republish.

2. **Ubiquitous — serialization order.** THE SYSTEM SHALL republish all five typed bands (Positions, Open Lots, Realized, Tax-accruals, Tax-reserve-summary) as independent atomic per-tab `batchUpdate` writes, and SHALL run the mark settle read-back (`read_price_pass`, possibly multiple bounded polls) only after every tab write in that cycle has returned. Republish and settle SHALL NOT run concurrently — every settle read's call-order index is greater than every write's index, on one thread of control.

3. **State-driven — lock scope.** WHILE the advisory write-lock is held by another holder, WHEN republish is attempted THE SYSTEM SHALL write no tabs (`batch_update_view` is never called), leave the current stale set unchanged, and return `published: false`. Otherwise THE SYSTEM SHALL acquire the lock before the first tab write and release it after the last tab write and the tab-order reassert complete — i.e., before the settle pass begins; settle always runs unlocked, and runs regardless of whether the republish half reported `published: true` or `false`.

4. **Unwanted-behavior — per-tab write failure.** IF a tab's `batch_update_view` fails THEN THE SYSTEM SHALL flag that tab name stale, attempt a best-effort single-cell banner exactly `"STALE — last sync {stale_banner_quote_ts}"` on that tab (a banner-write failure is swallowed, not surfaced), and continue republishing remaining tabs rather than aborting the cycle. The canonical event log is unaffected by any republish failure.

5. **Ubiquitous — tab order.** THE SYSTEM SHALL reassert the full workbook tab order (`workbook_tab_order()`) once, after all per-tab write attempts, on every republish call regardless of individual tab outcomes; a reassert failure marks the overall cycle `published: false` but does not undo or block tab writes already applied.

6. **State-driven — stale persistence.** WHILE a tab's write succeeds, THE SYSTEM SHALL clear its stale flag; a tab that fails again SHALL remain in the stale set (retried next cycle) until a later success.

Files consulted: `pt/src/tui_app.rs`, `pt/src/wiring.rs`, `runtime/src/cycle.rs`, `runtime/tests/publish_cycle.rs`, `sheets-view/src/lib.rs`, `sheets-view/tests/republish.rs`.