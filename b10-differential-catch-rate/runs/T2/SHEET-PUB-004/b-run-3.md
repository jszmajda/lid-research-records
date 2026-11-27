**Reconstructed EARS requirements — republish coordination with other Sheets-mutating work (`sheets-view` `Publisher::republish` / `republish_then_settle`)**

1. **(Event-driven)** WHEN `republish` is invoked, THE SYSTEM SHALL call `lock.acquire()` on the advisory write-lock and, IF acquisition succeeds, SHALL hold the returned guard for the entire duration of the tab writes and the tab-order reassertion, releasing it only after both complete (guard drop at scope exit) — no workbook mutation (`batch_update_view` or `set_tab_order`) SHALL occur before acquisition succeeds.

2. **(State-driven)** WHILE the advisory lock is held by another Sheets-mutating holder (`lock.acquire()` returns `Err`), WHEN `republish` is invoked, THE SYSTEM SHALL NOT call `batch_update_view` or `set_tab_order` for any tab, SHALL leave the workbook untouched, and SHALL return `RepublishOutcome { published: false, stale_tabs: <unchanged current stale set> }` — a non-destructive refusal, not a partial or concurrent write.

3. **(Ubiquitous)** THE SYSTEM SHALL acquire the lock exactly once per `republish` call (acquire count == 1 on a successful, non-held acquisition).

4. **(Event-driven)** WHEN `republish` returns (lock released, all per-tab writes attempted, `set_tab_order` attempted), AND `republish_then_settle` proceeds to the marks read-back, THE SYSTEM SHALL invoke `read_price_pass` only after that return — every `ReadPricePass` seam call SHALL occur strictly after every `BatchUpdate` seam call in the same cycle (no settle read precedes or interleaves with a write), including across multiple settle polls.

5. **(Ubiquitous)** THE advisory lock SHALL guard only the mutating half of the cycle (tab writes + tab-order reassertion); the settle/read-back pass is NOT covered by the lock guard, which has already been released by the time reads begin.

6. **(Unwanted behavior)** IF one or more tabs' `batch_update_view` calls fail during a lock-held republish, THEN THE SYSTEM SHALL still proceed through the remaining tabs and the tab-order call (all-or-nothing is per-tab, not whole-cycle), flag only the failing tab names stale, best-effort write a `"STALE — last sync {ts}"` banner per failed tab (banner-write failure is swallowed, not propagated), and set `published:false` on the outcome if any tab or the tab-order call failed — while a lock-acquisition failure short-circuits before any of this per-tab logic runs.

7. **(Ubiquitous)** A failed acquisition SHALL NOT itself add or remove entries in the stale-tab set — it reports the stale set exactly as it stood before the call.