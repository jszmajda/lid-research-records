**EARS: Republish-Failure Handling**

**[x] PUB-FAIL-001: Atomic write per tab** — Each view tab is rewritten as a single atomic `batchUpdate` from DATA_START_ROW (2) down, with the frozen header row never rewritten on republish; the data range is tail-truncated to the exact new row count (no leftover stale rows, no half-written window).

**[x] PUB-FAIL-002: Failed tab marking** — When a tab's `batch_update_view` call fails, the tab is immediately inserted into the stale set and remains there across republish cycles until a subsequent republish succeeds for that tab.

**[x] PUB-FAIL-003: No data landing on write failure** — A failed tab write does not publish: the tab is left absent from the workbook or, if it existed prior, remains in its prior state (the failed batchUpdate produces no workbook change).

**[x] PUB-FAIL-004: Best-effort stale banner** — When a tab's write fails, a single-cell in-tab banner is written best-effort with the fixed format `"STALE — last sync {stale_banner_quote_ts}"` (where `stale_banner_quote_ts` is the caller-supplied timestamp string); banner-write failure does not halt the cycle or change the stale flag state.

**[x] PUB-FAIL-005: All-tab outcome** — `RepublishOutcome.published` is `true` only if every tab's write succeeded; it is `false` if any tab failed, the lock was held, or lock acquisition itself errored (Held or I/O).

**[x] PUB-FAIL-006: Stale set persists** — The stale set persists across republish cycles; a tab remains flagged until a subsequent republish succeeds for it.

**[x] PUB-FAIL-007: Advisory lock gates writes** — Before any workbook mutation (before the first `batch_update_view` call), `republish` acquires the advisory write lock; if lock acquisition returns `LockError::Held`, the method returns immediately with `published: false` and the current stale set unchanged, writing nothing.

**[x] PUB-FAIL-008: Serialized settle pass** — The settle pass (`read_marks` / `read_price_pass`) runs strictly after the republish returns (never inline with the formula write), on the same single thread of control, with no concurrent workbook access between them.

**[x] PUB-FAIL-009: Offline settle errors propagate** — If the settle pass `read_price_pass` call errors (the workbook is unreachable), the error is propagated from `read_marks` to the caller; the prior cached marks are NOT carried forward by `read_marks` (that carry-forward is the caller's responsibility).

**[x] PUB-FAIL-010: Tab-order failure is non-fatal** — After all tab writes, if `set_tab_order` fails, `published` is set `false` but the cycle completes (failure does not corrupt truth; retried next sync).

Encoded constants: `DATA_START_ROW = 2`; stale banner text pattern `"STALE — last sync {ts}"`; lock semantics: `Held` → refuse; settle max polls (configurable via `SettleConfig.max_polls`, default 8).