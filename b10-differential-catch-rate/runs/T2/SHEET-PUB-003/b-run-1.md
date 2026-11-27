**Requirements enforced — republish failure handling (sheets-view / runtime adapter)**

1. (Event-driven) WHEN a view tab's `batch_update_view` write fails during `Publisher::republish`, the system SHALL leave that tab's previously-published content unchanged (no partial/half-written data range), mark the tab name into the stale set, and best-effort-write an in-tab STALE banner to that tab.

2. (Ubiquitous) The banner text SHALL be exactly `"STALE — last sync {ts}"` where `{ts}` is the caller-supplied `stale_banner_quote_ts` string, verbatim, un-reformatted.

3. (Unwanted behavior) IF the best-effort banner write itself fails, THEN the system SHALL NOT propagate that failure or abort the cycle — the tab SHALL remain recorded in the stale set (the TUI is the fallback staleness surface) and no banner value SHALL be recorded.

4. (Unwanted behavior) IF the workbook tab-order reassert (`set_tab_order`) fails, THEN `RepublishOutcome.published` SHALL be `false`, but no tab SHALL be added to `stale_tabs` on that account alone (tab-order failure and per-tab publish failure are tracked independently).

5. (Event-driven) WHEN a previously-stale tab's next republish attempt succeeds, the system SHALL remove it from the stale set (retried each sync until it clears).

6. (State-driven) WHILE the advisory write-lock is held by another holder (`Lock::acquire` returns `Err`), WHEN `republish` is invoked, the system SHALL write to NO tab, SHALL NOT attempt any `batch_update_view`/`set_tab_order` call, and SHALL return `published: false` with the stale set unchanged from before the call — a non-destructive refusal, not a partial write. The lock SHALL be acquired exactly once per successful republish and released on scope exit, strictly before any tab mutation.

7. (Ubiquitous) A republish failure SHALL never corrupt or touch canonical truth (the event log, owned by `store`) — only the view tab's rendered state is affected.

8. (Event-driven) At the adapter (`ViewSheetsAdapter`) level: WHEN the low-level primitive's `update_range` for an existing tab errors, the adapter SHALL surface `ViewError::PublishFailed`. WHEN the primitive reports the tab itself missing, the adapter SHALL instead attempt `ensure_sheet` + one header write + one retried data write; IF any of those three steps errors, the adapter SHALL surface `PublishFailed` (never a distinct "tab missing" error to the caller).

9. (Event-driven) WHEN the underlying primitive is unreachable/offline, both `batch_update_view` and `read_price_pass` SHALL map to `ViewError::PublishFailed` (no distinct offline/unreachable variant for the view seam).