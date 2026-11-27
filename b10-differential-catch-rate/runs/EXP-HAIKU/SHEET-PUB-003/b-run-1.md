P-PUB-011: Republish Failure Handling

**P-PUB-011-001** [ubiquitous]
When a single view tab's `batch_update_view` fails (sheets API error), that tab is inserted into the persistent per-tab stale set, persisting across republish cycles until that specific tab republishes successfully (at which point it is removed from stale). The overall `RepublishOutcome.published` flag is set to `false` only if any tab fails or `set_tab_order` fails; tabs that succeed are published atomically to the workbook.

**P-PUB-011-002** [error-semantics]
A failed tab republish writes a best-effort STALE banner to that tab's anchor cell (`{tabname}!AA1`) with exact format `"STALE — last sync {stale_banner_quote_ts}"` where `stale_banner_quote_ts` is the string passed to the `republish` call. The banner write is best-effort: if the banner write itself fails (network fully down), the stale flag is still persisted but the banner cell remains absent; the TUI is the staleness surface in that case.

**P-PUB-011-003** [event-driven]
Each view tab's publish is attempted independently in sequence (not parallel). On failure, the tab is immediately marked stale and a banner is written (if possible). Subsequent tabs in the batch continue publishing. The overall atomic outcome (all-succeeded vs. any-failed) is reported as `RepublishOutcome { published: true/false, stale_tabs: [names] }`.

**P-PUB-011-004** [state-driven]
If the advisory write-lock is held by another holder (acquire returns `LockError::Held`), `republish` returns immediately with `published: false` without attempting any workbook mutation or banner write. The stale set is unchanged; no new staleness is added, existing staleness persists for retry on the next cycle when the lock is free.

**P-PUB-011-005** [state-driven]
After a republish (success or failure), the serialize settle pass immediately reads marks back on the same thread (never concurrently), in a separate `read_price_pass` call. If the republish failed, the settle pass still runs — it reads from the client's current view state, which may be stale, but the read itself is not blocked by the republish outcome.

**P-PUB-011-006** [unwanted-behavior]
Reversion: a failed republish NEVER reverts the published view to an older state, deletes rows beyond the new row count, or corrupts the frozen header. Atomic per-tab updates and tail-truncate ensure the view is either the prior published state (if republish fails) or the new published state (if republish succeeds); no half-written intermediate state is exposed.

---

**Word count: 312**

P-PUB-011