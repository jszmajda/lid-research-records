**Requirements enforced — republish's coordination with other Sheets-mutating work (advisory lock + write/settle serialization)**

1. **Ubiquitous.** The system shall acquire the shared advisory write-lock before performing any workbook-mutating operation of a republish cycle (per-tab `batch_update_view` calls and the `set_tab_order` reassert), and shall acquire it exactly once per `republish` call (not once per tab).

2. **Event-driven.** WHEN lock acquisition fails (the lock is held by another Sheets-mutating primitive, e.g. `LockError::Held`), the system shall perform zero workbook writes for that cycle, return `RepublishOutcome{ published: false, stale_tabs: <unchanged current stale set> }`, and leave the workbook untouched — a non-destructive refusal, not a partial or queued write.

3. **State-driven.** WHILE the advisory lock is held by `republish`, no other write may occur concurrently through this path; the lock guards only the mutating half of the cycle — it is released (guard drops) as soon as all per-tab writes and the tab-order reassert have completed, before any settle-pass read begins.

4. **Ubiquitous.** `republish_then_settle` shall run strictly serialized: call `republish` (write phase, lock-guarded) to completion first, then perform the marks settle-pass read (`read_marks`) only after `republish` returns — never inline with or before any formula write in that cycle. This holds even when marks polling requires multiple reads (transient→numeric): every settle read must occur after every write in the cycle (verified by call-log ordering: min(read index) > max(write index)).

5. **Event-driven — per-tab write failure (independent axis, still inside the locked write phase).** WHEN a tab's `batch_update_view` fails, the system shall: flag that tab name stale (insert into the stale set), attempt a best-effort in-tab banner write of the exact text `"STALE — last sync {stale_banner_quote_ts}"` (a failed banner write is swallowed, not propagated), continue processing remaining tabs (failure of one tab does not abort the others), and set overall `published: false` for the cycle; a subsequent successful republish of that tab clears it from the stale set.

6. **Unwanted behavior.** If `set_tab_order` fails after all tab writes, this shall also force `published: false` for the outcome, without altering already-recorded per-tab stale flags.

7. **Ubiquitous.** A tab that publishes successfully shall be removed from the stale set that same cycle, regardless of other tabs' outcomes in the same call.