**EARS requirements enforced — republish's coordination with other Sheets-mutating work (advisory-lock serialization)**

**Ubiquitous:**
- U1: The system shall acquire the runtime-owned advisory write-lock before performing any workbook-mutating operation of a republish cycle (per-tab `batch_update_view` writes and the `set_tab_order` reassertion).
- U2: The system shall acquire the advisory lock exactly once per `republish` call (not once per tab), and shall release it only after all mutating operations in that call have completed (guard scope ends at `republish`'s return), whether those operations succeeded or failed per-tab.
- U3: Within `republish_then_settle`, every workbook write in the cycle (all per-tab batchUpdates and the tab-order set) shall complete, and the lock shall be released, strictly before the settle-pass price read (`read_price_pass`) is invoked. No settle-pass read call may occur before, or concurrently with, any write call in the same cycle — i.e., across the full call log, every `ReadPricePass` entry's index must exceed every `BatchUpdate` entry's index.
- U4: The advisory lock guards only the mutating (write) half of the cycle; the settle-pass read runs unlocked, after the guard has already been released, relying on single-threaded sequencing (never concurrent) rather than the lock itself.

**Event-driven:**
- E1: WHEN `republish` is invoked and the lock's `acquire()` returns `Err` (held by another Sheets-mutating primitive), the system shall perform zero workbook writes, shall return `RepublishOutcome { published: false, stale_tabs: <the stale set exactly as it was before the call> }`, and shall not add to, remove from, or otherwise mutate the existing stale-tab set.
- E2: WHEN the lock is held, this refusal shall be non-destructive: no tab content already published is altered, and no partial/half-written state results — the caller (or next sync cycle) retries.

**Unwanted behavior:**
- UB1: IF the lock is held at the time `republish` is called THEN the system shall NOT write any tab (not even a subset), shall NOT call `set_tab_order`, and shall NOT attempt the settle-pass read as part of that refused cycle.

Pinned by tests: a free lock is acquired exactly once per successful `republish` (`acquire_count() == 1`); a `HeldLock` (`acquire()` → `Err(LockError::Held)`) yields `published == false` with nothing landed in the fake client; in a multi-tab, multi-poll republish-then-settle cycle, the maximum index of any `BatchUpdate` call in the seam call log is strictly less than the minimum index of any `ReadPricePass` call.