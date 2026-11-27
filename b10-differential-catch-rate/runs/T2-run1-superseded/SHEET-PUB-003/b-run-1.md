**EARS requirements enforced for "what happens when a republish fails" (sheets-view / runtime adapter):**

1. **(Event-driven)** WHEN the low-level `SheetsApi.update_range` call for a view tab's data range fails for any reason — including when the tab is missing and the bootstrap sequence (`ensure_sheet` → header `update_range` at `'{tab}'!A1` → data `update_range`) fails at any step — the `ViewSheetsAdapter` SHALL return `Err(sheets_view::ViewError::PublishFailed)` for that tab.

2. **(Event-driven)** WHEN `Publisher::republish` receives `PublishFailed` for a tab, it SHALL insert that tab's name into the stale set and SHALL attempt (best-effort) to write an in-tab banner via `write_stale_banner` with exact text `"STALE — last sync {stale_banner_quote_ts}"` (em dash, literal "last sync "), where `{stale_banner_quote_ts}` is the caller-supplied timestamp string, verbatim.

3. **(Unwanted-behavior)** IF the best-effort banner write itself fails, THEN the Publisher SHALL NOT propagate or surface that secondary failure — the tab SHALL remain recorded stale (the TUI is the fallback staleness surface), and no banner SHALL be recorded.

4. **(Ubiquitous)** A tab whose publish failed SHALL have nothing new land for it — its prior published state (absent, if never before published) is unchanged; the canonical event log is unaffected.

5. **(Event-driven)** Republish SHALL attempt every tab in the given list independently: one tab's `PublishFailed` SHALL NOT prevent attempting subsequent tabs in the same cycle.

6. **(Event-driven)** WHEN a previously-stale tab's republish succeeds, the Publisher SHALL remove it from the stale set (retry-clears on next successful sync).

7. **(State-driven)** WHILE the advisory lock's `acquire()` returns `Err` (held by another holder), republish SHALL write to no tab, SHALL leave the stale set exactly as it was, and SHALL return `RepublishOutcome{published:false, stale_tabs:<unchanged>}` — a non-destructive refusal, never a partial/concurrent write.

8. **(Ubiquitous)** On a successful acquisition, the lock SHALL be acquired exactly once per `republish` call, before any tab mutation, and released after all tab writes and the `set_tab_order` reassert complete.

9. **(Event-driven)** WHEN `set_tab_order` fails, `RepublishOutcome.published` SHALL be `false` for the cycle, though this failure is not itself added to `stale_tabs` (which tracks only per-tab `batch_update_view` failures).

10. **(Ubiquitous)** `RepublishOutcome.published` SHALL be `true` iff every tab's `batch_update_view` succeeded AND `set_tab_order` succeeded; otherwise `false`.