## Reconstructed EARS specs — publish/settle serialization

**Ubiquitous (serialization contract):**
1. The publishing cycle shall run republish and the marks settle-read as ONE serialized loop on a single thread of control: every tab write (all `batch_update_view` calls plus the tab-order reassert) shall complete before the first settle-pass `read_price_pass` call of that cycle begins — no settle read may interleave with an in-progress write.
2. `republish()` shall acquire the advisory write-lock before any workbook mutation and release it once all tab writes and the tab-order reassert return — i.e., before the settle read starts. The lock guards only the write half, never the settle-read half.
3. `republish_then_settle` shall invoke `read_marks` after `republish` returns, regardless of `published`'s value (a failed publish does not skip the settle read).

**Event-driven (when the cycle runs):**
4. When `pt summary` runs, when the TUI connects, or when the TUI refreshes (manual `[r]`, the hourly ambient auto-refresh, or the deferred refresh after a confirmed durable submit), the system shall execute exactly one publishing cycle — replay → render tabs → republish → settle-read marks — via the single `run_live_cycle`/`run_cycle_publishing` path.

**Unwanted behavior (contention / failure):**
5. If the advisory lock is held by another holder (or acquisition errors), republish shall write nothing, leave the stale set unchanged, and return `published:false`.
6. If a tab's `batch_update_view` fails, that tab shall be added to the stale set and a best-effort in-tab banner of exact text `"STALE — last sync {ts}"` shall be written; a banner-write failure is swallowed (non-fatal) and the tab remains stale for retry next cycle.
7. If `set_tab_order` fails, the outcome shall report `published:false` even when every tab write succeeded.
8. A previously-stale tab that republishes successfully shall be removed from the stale set.

**State-driven / normalization (write + mark-refresh mechanics):**
9. Each republish shall write data from row `DATA_START_ROW` (2) beneath the never-rewritten row-1 header, truncating the residual tail to the exact new row count.
10. While any requested symbol's latest reading is `Transient`/absent, the settle pass shall re-poll `read_price_pass`, bounded by `SettleConfig.max_polls` (default 8); on exhaustion a still-transient symbol degrades `TimedOut` (keeping its prior cached mark if any, else none); a `Permanent` reading degrades immediately with no prior carry.
11. If the settle read's transport errors (offline), `read_marks` shall propagate the error and produce no `MarksProduced`; the caller retains its existing cached marks unchanged.

Source files: tui_app.rs, wiring.rs, runtime/src/cycle.rs, runtime/tests/publish_cycle.rs, sheets-view/src/lib.rs, sheets-view/tests/republish.rs.