**Requirements Reconstructed — Workbook Tab-Order Reassertion on Republish**

**Ubiquitous**
- THE system SHALL define the workbook's tab order as the fixed 10-tab sequence returned by `workbook_tab_order()`: `Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events`.
- Positions SHALL be first (leftmost/landing tab); Tax Events SHALL be last.
- THE four view tabs SHALL occupy positions 1–4 in that exact order: Positions, Open Lots, Realized, Tax.
- History SHALL immediately follow the Tax view (position 5), ahead of all config tabs.
- THE three config tabs SHALL follow History in order: Tax Rules, Residency, Platforms & Aliases.
- THE two event-log tabs SHALL be last, Ledger Events immediately before Tax Events.
- `Tax · Reserve Summary` SHALL NOT appear in this ordered list — it is excluded from tab-order reassertion entirely (its own header/rows are a distinct range, not a 5th `VIEW_TABS` entry).

**Event-driven**
- WHEN `Publisher::republish` is invoked and its advisory write-lock is successfully acquired, THE system SHALL, after issuing `batch_update_view` for every tab in the input slice (regardless of each call's individual success/failure), call `set_tab_order` exactly once with the fixed order above.
- WHEN `republish` is invoked repeatedly (idempotent re-run), THE system SHALL reassert the identical fixed order every time — no drift, no reordering based on prior state.

**State-driven**
- WHILE the write-lock cannot be acquired (held by another writer, or an acquisition I/O error), `republish` SHALL perform NEITHER `batch_update_view` NOR `set_tab_order`; it SHALL return `published: false` with the stale-tab set left unchanged (non-destructive refusal, retried next cycle).

**Unwanted behavior**
- IF `set_tab_order` returns an error THEN `RepublishOutcome.published` SHALL be `false`, AND this failure SHALL NOT append any tab name to `stale_tabs` (`stale_tabs` accumulates only from per-tab `batch_update_view` failures — order failure and per-tab publish failure are tracked as distinct signals).
- IF one or more per-tab `batch_update_view` calls fail THEN `set_tab_order` SHALL still be attempted (order reassertion is unconditional on per-tab outcomes, once the lock is held).

**Adapter/production seam (pinned in code, not asserted by a test)**
- THE production `ViewSheetsAdapter::set_tab_order` SHALL unconditionally return `Ok(())` and SHALL NOT invoke the underlying `SheetsApi` primitive — reordering the live Google Sheets workbook is a no-op at this layer today. Only the in-memory test double (`InMemorySheetsView::set_tab_order`) actually records the passed `&[&str]` order (verbatim, as given) for assertion, and can be made to fail via `set_order_fails`.