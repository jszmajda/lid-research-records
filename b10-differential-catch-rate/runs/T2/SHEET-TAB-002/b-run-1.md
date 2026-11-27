```
SHEET-ORDER-001 [ubiquitous]: The system SHALL define one fixed workbook tab order (`workbook_tab_order()`): Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events — exactly these 10 tab names, in this sequence, encoded as a static list (no sort/comparator; no runtime-computed ordering).

SHEET-ORDER-002 [ubiquitous]: Positions SHALL be the first (leftmost/landing) tab.

SHEET-ORDER-003 [ubiquitous]: The four view tabs SHALL occupy positions 1–4, in order Positions, Open Lots, Realized, Tax.

SHEET-ORDER-004 [ubiquitous]: History SHALL sit immediately after the view tabs and before every config tab.

SHEET-ORDER-005 [ubiquitous]: Config tabs SHALL follow History in order Tax Rules, Residency, Platforms & Aliases.

SHEET-ORDER-006 [ubiquitous]: Event-log tabs SHALL be last, in order Ledger Events then Tax Events; Tax Events SHALL be the final tab in the order.

SHEET-ORDER-007 [event-driven]: WHEN `Publisher::republish` runs (lock acquired), THEN AFTER writing every view tab's `batch_update_view`, the system SHALL call `set_tab_order` with the complete fixed 10-tab order — regardless of how many/which tabs were included in that cycle's `tabs` argument (a republish touching only one view tab still reasserts all 10 names, including tabs not written that cycle).

SHEET-ORDER-008 [event-driven]: WHEN the advisory write-lock cannot be acquired, THEN the system SHALL NOT call `batch_update_view` or `set_tab_order` that cycle, SHALL return `published: false`, and SHALL leave the existing stale-tab set unmodified.

SHEET-ORDER-009 [state-driven]: WHILE republish is invoked repeatedly (consecutive cycles), the reasserted tab order SHALL be byte-for-byte identical every time (idempotent — independent of prior workbook state or prior order).

SHEET-ORDER-010 [unwanted-behavior]: IF `set_tab_order` returns an error, THEN the system SHALL set the cycle's `RepublishOutcome.published` to `false`, SHALL NOT treat it as corrupting canonical truth, and SHALL NOT add any tab name to `stale_tabs` on account of the order failure alone (`stale_tabs` only accrues from per-tab `batch_update_view` failures).

SHEET-ORDER-011 [unwanted-behavior]: The order-reassert operation SHALL NOT touch any tab's values/grid (it is a workbook-metadata-only operation, distinct from the per-tab data `batchUpdate`); a fake/test double MAY model it as a separate no-op or independently-failable seam without touching published cell contents.

(Testkit note, not itself a requirement: `InMemorySheetsView` models `set_tab_order` as a distinct seam call logged separately from `BatchUpdate`/`ReadPricePass`, independently fault-injectable via `set_order_fails`.)
```