**EARS requirements enforced by this code for "what happens when a republish fails":**

**Event-driven**
1. WHEN a view tab's `batch_update_view` (batchUpdate) call fails during `Publisher::republish`, the system SHALL leave that tab's previously published content unchanged (no partial/half-written state; the canonical event log is untouched — there is no store interaction in this path), add the tab's name to the stale set, and continue attempting the remaining tabs in the same republish call (a per-tab failure does not abort the batch).
2. WHEN a tab is added to the stale set on a failed batchUpdate, the system SHALL attempt a best-effort write of an in-tab banner to cell `'{tab}'!AA1` with exact text `"STALE — last sync {stale_banner_quote_ts}"`.
3. WHEN `republish` is invoked, the system SHALL acquire the advisory write-lock before any tab mutation; IF acquisition fails (held by another holder, or an I/O error), THEN republish SHALL write to no tab, return `published: false`, and leave the stale set exactly as it was (a non-destructive refusal, not a partial write).
4. WHEN a previously-stale tab's next republish attempt succeeds, the system SHALL clear that tab from the stale set.

**Unwanted behavior**
5. IF the best-effort STALE-banner write itself fails, THEN the system SHALL NOT surface an additional error or retry it inline — the tab remains recorded stale, no banner is stored, and the TUI (not the sheet) remains the staleness surface.
6. IF any underlying Sheets error occurs on `batch_update_view` or `read_price_pass` (including the workbook being unreachable), THEN `ViewSheetsAdapter` SHALL collapse it to the single `ViewError::PublishFailed` variant — EXCEPT a "missing tab" error, which instead triggers write-implies-create (ensure_sheet → write the frozen header once → retry the data write); a failure at any step of that create/retry sequence also collapses to `PublishFailed`.
7. IF `set_tab_order` fails after all per-tab writes complete, THEN `RepublishOutcome.published` SHALL be `false` even though no tab name is added to `stale_tabs` for that failure specifically.

**State-driven / ubiquitous**
8. `RepublishOutcome.published` SHALL be `true` if and only if every tab's write succeeded AND the tab-order reassert succeeded.
9. The write-lock guard SHALL cover only the mutating (republish) half; it is released before the settle-pass read runs.