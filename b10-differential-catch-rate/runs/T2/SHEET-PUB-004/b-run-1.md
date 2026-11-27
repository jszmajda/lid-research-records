**EARS requirements — republish's coordination with other Sheets-mutating work (advisory write-lock)**

*Ubiquitous:*
- U1: The system SHALL acquire the runtime-owned advisory write-lock before performing any workbook-mutating operation in a republish cycle — every `batch_update_view` call, the `set_tab_order` reassert, and any `write_stale_banner` call — and SHALL release it (guard drop at scope exit) once those mutations complete, regardless of whether any of them succeeded or failed.
- U2: Lock scope covers only the mutating half of a `republish_then_settle` cycle; the marks settle-pass read (`read_price_pass`) is NOT covered by the held guard — it runs after the guard has already been released.
- U3: A single `republish` invocation SHALL acquire the lock exactly once, covering all tabs passed to it (not once per tab).

*Event-driven:*
- E1: WHEN `republish` is invoked, the system SHALL attempt lock acquisition first, before writing any tab; only WHEN acquisition succeeds SHALL it proceed to write tabs and reassert tab order.
- E2: WHEN `republish_then_settle` is invoked, the system SHALL execute `read_marks`'s settle-pass poll only AFTER `republish` (its writes and lock release) has returned — never inline with, before, or concurrently with any tab write in that cycle. Every settle-pass read in the call log must be ordered after every write in the call log.

*Unwanted behavior (lock held):*
- UB1: IF lock acquisition fails (lock held by another Sheets-mutating primitive), THEN `republish` SHALL NOT call `batch_update_view`, `set_tab_order`, or `write_stale_banner` for any tab in that cycle; the workbook SHALL be left untouched (no partial/concurrent write); the call SHALL return `RepublishOutcome { published: false, stale_tabs: <unchanged existing stale set> }`; the existing stale-tab set SHALL NOT be modified as a result of the refused attempt.

*State-driven:*
- S1: WHILE the advisory lock is held by another holder, `republish` SHALL refuse to write for the entire cycle and return control non-destructively (not queue, not partially write), leaving retry to the next sync cycle.

No numeric constants apply to this concern beyond "acquire exactly once per call" (test-pinned via `acquire_count() == 1`). No tie-break/normalization/boundary rules beyond acquire-before-mutate, release-before-settle-read, and refusal-leaves-state-unchanged are pinned for this concern by the code or tests.