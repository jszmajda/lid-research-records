Based solely on `crates/sheets-view/src/lib.rs` and `crates/sheets-view/tests/republish.rs`, the lock-coordination concern (`republish` vs. other Sheets-mutating work) pins these EARS-style requirements:

**SHEET-REPUB-LOCK-1 (Ubiquitous).** The system shall acquire the runtime-owned advisory write-lock exactly once per `republish` call, before issuing any workbook-mutating call (any `batch_update_view` per tab, and `set_tab_order`), and shall hold it for the entire span of those calls, releasing only after the last one returns (guard-on-scope-exit). One acquire covers the whole batch, not one per tab.

**SHEET-REPUB-LOCK-2 (Event-driven).** WHEN lock acquisition fails (the lock is held by another Sheets-mutating holder, or an acquisition I/O error occurs), the system shall NOT issue any `batch_update_view` or `set_tab_order` call for that cycle, shall return `RepublishOutcome { published: false, stale_tabs: <the pre-call stale set, unchanged> }`, and shall leave the workbook untouched — no tab is added to or removed from the stale set as a result of the refused attempt.

**SHEET-REPUB-LOCK-3 (Unwanted behavior).** The republish path shall never write to the workbook concurrently with another lock holder; a held lock produces a non-destructive refusal (zero writes), never a partial write, a queued write, or a silent retry within the same call.

**SHEET-REPUB-LOCK-4 (State-driven, `republish_then_settle`).** WHILE one `republish_then_settle` cycle executes, every settle-pass read (`read_price_pass`) shall occur strictly after every workbook-mutating write of that same cycle has returned — no read may be interleaved with or precede the writes, even across multiple settle polls in that cycle.

**SHEET-REPUB-LOCK-5 (Ubiquitous — lock scope).** The advisory lock shall guard only the mutating half of the cycle: `republish` acquires and releases it internally before `republish_then_settle` proceeds to `read_marks`, so all settle-pass reads run unlocked, after release.

Test-pinned specifics: lock acquired count == 1 for a successful republish (`acquire_count()`); a `HeldLock` (always `Err(LockError::Held)`) yields `published: false` and zero landed rows on that tab; ordering is asserted via seam call-log indices where `max(write indices) < min(read indices)` across a multi-tab, multi-poll cycle.