**Concern: workbook tab ordering on republish (sheets-view + runtime adapter)**

**Ubiquitous:**
- THE system SHALL maintain a fixed canonical workbook tab order of exactly ten tabs, by literal name, in this sequence: `Positions`, `Open Lots`, `Realized`, `Tax`, `History`, `Tax Rules`, `Residency`, `Platforms & Aliases`, `Ledger Events`, `Tax Events` (`workbook_tab_order()`).
- THE system SHALL place `Positions` as the leftmost (landing) tab.
- THE system SHALL group the four view tabs first, in their fixed relative order (`Positions, Open Lots, Realized, Tax`), followed by `History`, then the three config tabs in fixed order (`Tax Rules, Residency, Platforms & Aliases`), then the two event-log tabs last, `Ledger Events` before `Tax Events`.
- THE order is a static enumeration, not a sort over any dynamic key — there is no tie-break rule because tab identity is fixed and unique by construction.
- Note: `Tax · Reserve Summary` (the Tax tab's reserve-summary band, published as its own named tab) is NOT named in `workbook_tab_order()`; its position is unconstrained by this requirement.

**Event-driven:**
- WHEN `Publisher::republish` runs, THE system SHALL, after issuing `batch_update_view` for every tab in the batch (regardless of any individual tab's success/failure), reassert the full canonical order in one `set_tab_order` call with the complete fixed list — i.e., order reassertion is unconditional and not skipped when some tabs failed/are stale.
- WHEN `set_tab_order` fails, THE system SHALL mark the overall `RepublishOutcome.published` as `false`, but SHALL NOT add any tab name to `stale_tabs` on account of the order failure alone (stale-tab membership is driven only by per-tab `batch_update_view` failures).
- WHEN the real (`runtime`) `ViewSheetsAdapter::set_tab_order` is invoked, THE system SHALL return `Ok(())` unconditionally without performing any reorder — tab-order metadata mutation (a `spreadsheets.batchUpdate updateSheetProperties` call) is out of scope for the values-grid-only primitive the adapter rides; the adapter is a stub over this operation.

**State-driven:**
- WHILE republish runs repeatedly (idempotent reruns), THE system SHALL reproduce the identical fixed tab order each time, independent of the workbook's prior/current tab arrangement — order is asserted from the constant, never diffed against or derived from existing state.

**Unwanted-behavior:**
- IF an individual tab's `batch_update_view` fails, THEN THE system SHALL still proceed to reassert tab order in the same cycle (order reassertion is not gated on per-tab publish success).

Files: `runtime/src/adapters.rs`, `sheets-view/src/lib.rs`, `sheets-view/src/testkit.rs`, `sheets-view/tests/tabs.rs`.