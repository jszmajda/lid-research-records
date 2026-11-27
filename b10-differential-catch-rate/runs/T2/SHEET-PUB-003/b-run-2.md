**Reconstructed EARS requirements — republish failure handling (sheets-view / runtime adapter)**

1. WHEN a view tab's `batch_update_view` call fails during `Publisher::republish`, the system SHALL flag that tab name into the persistent stale set, SHALL leave nothing written to that tab (no partial data lands), and SHALL set the cycle's `RepublishOutcome.published` to `false`.

2. WHEN a tab's `batch_update_view` fails, the system SHALL attempt a best-effort write of an in-tab STALE banner to that tab, with exact text `"STALE — last sync {stale_banner_quote_ts}"` (the caller-supplied timestamp verbatim).

3. IF the best-effort STALE-banner write itself fails, THEN the system SHALL swallow that failure (not propagate/panic) — the tab SHALL remain recorded stale, `published` SHALL remain `false`, and the TUI remains the fallback staleness surface.

4. A single tab's write failure SHALL NOT abort the cycle: the system SHALL continue attempting every remaining tab's `batch_update_view` in the same `republish` call (per-tab independence).

5. WHILE a tab is flagged stale from a prior cycle, the system SHALL retry that tab's write on the next `republish` call; WHEN that retry's `batch_update_view` succeeds, the system SHALL clear the tab's stale flag.

6. WHEN `set_tab_order` fails (after all per-tab writes), the system SHALL set `published` to `false` but SHALL NOT add any tab to the stale set and SHALL NOT attempt a banner write for this failure.

7. `RepublishOutcome.published` SHALL be `true` if and only if every tab's write succeeded AND `set_tab_order` succeeded; any single failure forces `false`. `RepublishOutcome.stale_tabs` SHALL always reflect the full persistent stale set, not just the current call's failures.

8. WHEN `republish` is invoked, the system SHALL acquire the advisory write-lock BEFORE mutating any tab. IF acquisition fails (lock held), THEN the system SHALL write NOTHING that cycle and SHALL return `published: false` with `stale_tabs` unchanged from before the call.

9. A republish failure SHALL NOT corrupt or touch canonical ledger truth (owned elsewhere) — only the view tab is left stale/behind.

10. (Adapter/error-mapping) IF the underlying low-level Sheets call for a view-tab write fails for any reason other than "tab missing," THEN the adapter SHALL surface exactly `ViewError::PublishFailed`. IF the tab is missing, THEN this is fresh-workbook bootstrap, NOT a failure: the adapter SHALL create the sheet, write the frozen header once, and retry the data write once — only a failure of that bootstrap sequence surfaces as `PublishFailed`.