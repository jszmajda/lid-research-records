Based on my analysis of the code and tests, here are the reconstructed EARS-style requirements for republish failure handling:

---

**SHEET-PUB-004: Republish Failure Handling**

**Pattern:** state-driven; event-driven (lock, stale banner timing)

**Requirements:**

1. **Lock-Based Concurrency (Acquire-Before-Mutate)**
   - Before writing ANY workbook data, acquire the advisory write-lock.
   - If `lock.acquire()` fails (Held error), return `published: false` with current stale_tabs unchanged and NO workbook mutations.
   - Lock guard is held across all per-tab writes; released on scope exit (post-outcome).

2. **Atomic Per-Tab Write**
   - Each tab publishes as one `batchUpdate` to the data range (from DATA_START_ROW down), never touching row 1 (frozen header).
   - Tail-truncate residual rows to exact new row count (wholesale replace, not append).
   - On write success: remove tab from stale set.
   - On write failure: add tab to stale set, attempt best-effort stale banner.

3. **Stale Banner (Best-Effort, Failure-Tolerant)**
   - On any tab write failure, write an in-tab banner with exact format: `STALE — last sync {stale_banner_quote_ts}` (caller provides timestamp quote; code format is literal).
   - Banner write is best-effort; failure does NOT prevent stale-set update or stop further tab processing.
   - If banner write also fails (network fully down), no banner lands; TUI remains staleness surface.
   - Banner is a single cell in tab (exact cell location: implementation detail; anchor must be stable across cycles).

4. **Tab Order Reassert (Best-Effort)**
   - After all tabs, attempt `set_tab_order(&[Positions, OpenLots, Realized, Tax, History, TaxRules, Residency, PlatformsAliases, LedgerEvents, TaxEvents])`.
   - Tab order failure does NOT revert per-tab successes; failure sets `all_ok = false`.
   - Retried next sync (non-destructive refusal).

5. **Stale Tabs Carry Forward**
   - Stale set is NOT cleared at cycle start; accumulates across cycles.
   - A tab added to stale set on failure remains stale until it publishes successfully (then removed).
   - `RepublishOutcome.stale_tabs` always reports the current set, regardless of this cycle's outcome.

6. **Overall Published Flag**
   - `published: true` only if lock acquired AND all tabs wrote successfully AND tab order reassert succeeded.
   - `published: false` if lock not acquired, OR any tab write failed, OR tab order failed.
   - Partial success (some tabs published, some stale) reports `published: false`.

7. **Settle Pass Serialization**
   - Marks read-back (`read_marks`) runs AFTER republish returns, same thread (never concurrent).
   - Settle pass runs even if `published: false` (reads stale data).
   - On `read_price_pass` error (offline), propagate error; do NOT silently emit empty marks or carry prior marks inline.

---

**Key Boundary:** the canonical event log (`store`) is never touched; only the view layer is stale-marked. Retry next sync.