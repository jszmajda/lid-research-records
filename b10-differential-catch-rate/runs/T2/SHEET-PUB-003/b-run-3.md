**EARS requirements enforced for "republish failure" (portfolio-tracker sheets-view/runtime):**

1. **Event-driven (per-tab failure, no abort):** WHEN a view tab's `batch_update_view` call fails during `Publisher::republish`, THE system SHALL insert that tab's name into the stale set, best-effort write an in-tab banner to cell `'{tab}'!AA1` with exact text `"STALE — last sync {stale_banner_quote_ts}"`, and continue republishing the remaining tabs in the batch (a single tab's failure never halts the cycle).

2. **Unwanted-behavior (banner write also fails):** IF the best-effort banner write itself errors, THEN the system SHALL discard that error (`let _ = ...`), still record the tab stale, and rely on the TUI as the staleness surface — no escalation, no panic.

3. **State-driven (stale persists until success):** WHILE a tab is in the stale set, THE system SHALL retry it on every subsequent republish cycle; only a subsequent successful `batch_update_view` for that tab SHALL remove it from the stale set.

4. **Event-driven (aggregate outcome):** WHEN any tab fails to publish OR the trailing `set_tab_order` call fails, THE `RepublishOutcome.published` SHALL be `false`; `stale_tabs` SHALL list only tabs whose data write failed (an order-reassert failure alone adds no entry).

5. **Unwanted-behavior (lock held):** IF the advisory write-lock cannot be acquired, THEN `republish` SHALL write nothing to any tab, leave the existing stale set unchanged, and return `published: false` — non-destructive refusal, never a partial/concurrent write.

6. **Ubiquitous (lock scope):** THE lock SHALL be acquired before the first tab mutation and released when the mutation loop's guard drops.

7. **Event-driven (settle ordering unaffected by outcome):** WHEN `republish_then_settle` runs, THE settle-pass read SHALL occur strictly after `republish` returns, regardless of republish's success/failure — never inline with or before a write.

8. **Event-driven (truth untouched):** A failed republish SHALL NOT mutate canonical truth (the event log) and SHALL leave the tab's prior content intact — no half-written window.

9. **Event-driven (adapter mapping):** WHEN the primitive's write fails for a reason other than missing-tab, `ViewSheetsAdapter` SHALL map it to `ViewError::PublishFailed` only.

10. **Event-driven (missing-tab is bootstrap, not failure):** WHEN the tab doesn't exist, THE adapter SHALL create it, write the frozen header once, then retry the data write; failure at any sub-step still maps to `PublishFailed`.

11. **Unwanted-behavior (settle offline):** IF `read_price_pass` fails, THEN the adapter SHALL surface `PublishFailed`, never a silently-empty pass.