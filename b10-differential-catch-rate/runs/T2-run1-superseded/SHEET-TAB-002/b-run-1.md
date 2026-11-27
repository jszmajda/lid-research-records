**SHEET-ORDER-001 (Ubiquitous)** The system SHALL maintain one fixed workbook tab order, reasserted on every republish, as exactly this sequence: Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, "Platforms & Aliases", Ledger Events, Tax Events.

**SHEET-ORDER-002 (Ubiquitous)** Within that order: Positions SHALL be the first (leftmost/landing) tab; the four view tabs (Positions, Open Lots, Realized, Tax) SHALL occupy positions 1–4 in that exact sub-order; the History tab SHALL immediately follow the view tabs (after Tax, before any config tab); the three config tabs SHALL follow History in the sub-order Tax Rules, then Residency, then "Platforms & Aliases"; the two event-log tabs SHALL be last, in the sub-order Ledger Events then Tax Events, with Tax Events as the final tab.

**SHEET-ORDER-003 (Unwanted behavior)** The Tax tab's reserve-summary band ("Tax · Reserve Summary") is a distinct in-sheet range, not a separate workbook tab, and SHALL NOT appear as an entry in the tab order.

**SHEET-ORDER-004 (Event-driven)** WHEN `Publisher::republish` runs, THE system SHALL, after attempting `batch_update_view` for every tab in the republished set (regardless of which individual tab writes succeeded or failed), call `set_tab_order` with the full fixed order from SHEET-ORDER-001 — not a subset scoped to the tabs just republished, and not derived from any prior/current workbook order.

**SHEET-ORDER-005 (State-driven)** WHILE the workbook tab order already equals the fixed order, a republish SHALL leave it unchanged: reasserting the order is idempotent across repeated republish cycles (no drift, no duplication).

**SHEET-ORDER-006 (Unwanted behavior)** IF `set_tab_order` fails, THEN the system SHALL mark the overall `RepublishOutcome.published` as `false`, but SHALL NOT add any tab to `stale_tabs` and SHALL NOT write a stale banner on account of the order failure alone — order-reassert failure is tracked only via the aggregate `published` flag, distinct from per-tab publish-failure staleness.

**SHEET-ORDER-007 (Ubiquitous)** The order reassert operation is a workbook-metadata operation only (no values-grid write); it carries no content/checksum semantics and is independent of tab existence/creation, which is handled separately by each tab's own write-implies-create path.

No numeric row/column constants, locale handling, or normalization apply to tab ordering itself (those govern cell content elsewhere). No test exercises order-reassert failure recovery beyond the `published:false` flag.