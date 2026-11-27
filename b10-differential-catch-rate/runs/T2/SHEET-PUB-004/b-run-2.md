**Concern: republish's coordination with other Sheets-mutating work (advisory lock serialization)**

**Ubiquitous:**
- SHEET-REPUB-LOCK-01: `Publisher::republish` shall acquire the runtime-owned advisory write-lock before performing any workbook-mutating call (each tab's `batch_update_view`, then `set_tab_order`), and shall hold it for no longer than that mutating sequence — released before returning, and never held during the subsequent settle-pass read.
- SHEET-REPUB-LOCK-02: The lock is acquired exactly once per `republish` invocation (covering the entire batch of tabs plus the tab-order reassert as one guarded unit), not once per tab.

**Event-driven:**
- SHEET-REPUB-LOCK-03: WHEN `republish` is called and lock acquisition succeeds, the system shall write each tab via `batch_update_view`, then reassert tab order via `set_tab_order`, then release the lock on scope exit.
- SHEET-REPUB-LOCK-04: WHEN `republish` is called and lock acquisition fails (held by another Sheets-mutating primitive, or an acquisition I/O error), the system shall perform zero workbook-mutating calls this cycle, shall return `RepublishOutcome { published: false, stale_tabs: <unchanged from before the call> }`, and shall NOT modify the stale-tab set.
- SHEET-REPUB-LOCK-05: WHEN `republish_then_settle` is called, the settle-pass read (`read_marks`/`read_price_pass` polling) shall begin only after `republish` returns (lock already released) — never inline with or before any write in the same cycle. Across a multi-tab republish, every `read_price_pass` call recorded on the seam must occur after every `batch_update_view` call in that cycle (no interleaving), even when settling requires multiple polls.
- SHEET-REPUB-LOCK-06: The advisory lock guards only the mutating half of the cycle; it does not wrap the settle read.

**Unwanted behavior:**
- SHEET-REPUB-LOCK-07: IF the advisory lock is held by another party WHEN `republish` is invoked, THEN the system shall not write any tab, partially or fully — a non-destructive refusal, not a partial/concurrent write — leaving the workbook exactly as-is for the caller (or next sync) to retry.

**Tie-break/ordering rule pinned by test:** across N tabs written in one republish cycle followed by M settle polls, `max(index of any BatchUpdate call) < min(index of any ReadPricePass call)` in the seam's call log — a strict ordering invariant, not merely "usually after."

No numeric constants govern this concern (lock is a binary acquire/release via the `Lock`/`LockGuard` trait); `SettleConfig::max_polls` (default 8) bounds settling but is orthogonal to lock coordination.