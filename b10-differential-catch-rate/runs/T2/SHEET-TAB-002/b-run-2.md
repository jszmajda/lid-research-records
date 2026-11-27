**EARS requirements — workbook tab republish ordering (sheets-view)**

**SHEET-ORDER-001 (Ubiquitous).** THE system SHALL define one fixed, total workbook tab order, in this exact sequence: `Positions`, `Open Lots`, `Realized`, `Tax`, `History`, `Tax Rules`, `Residency`, `Platforms & Aliases`, `Ledger Events`, `Tax Events` (10 tabs).

**SHEET-ORDER-002 (Ubiquitous).** THE system SHALL place `Positions` first (leftmost/landing tab) and `Tax Events` last (rightmost).

**SHEET-ORDER-003 (Ubiquitous).** THE system SHALL order the four sheets-view tabs contiguously and first, in the sequence `Positions, Open Lots, Realized, Tax`.

**SHEET-ORDER-004 (Ubiquitous).** THE system SHALL place `History` (owned by `reports`) immediately after the view tabs and before all config tabs.

**SHEET-ORDER-005 (Ubiquitous).** THE system SHALL order the config tabs (owned by `config`) contiguously, after `History`, in the sequence `Tax Rules, Residency, Platforms & Aliases`.

**SHEET-ORDER-006 (Ubiquitous).** THE system SHALL order the event-log tabs (owned by `store`) contiguously and last, in the sequence `Ledger Events, Tax Events`.

**SHEET-ORDER-007 (Ubiquitous).** The `Tax · Reserve Summary` range SHALL NOT be a separately-ordered tab (it is a band within `Tax`, not a fifth entry).

**SHEET-ORDER-008 (Event-driven).** WHEN a republish cycle runs, THE system SHALL write all provided view tabs' data first, THEN reassert the fixed full tab order (SHEET-ORDER-001) via one `set_tab_order` call — never interleaved with, or ahead of, the data writes.

**SHEET-ORDER-009 (Event-driven).** WHEN republish runs, THE system SHALL reassert the SAME fixed full order every cycle, unconditionally and idempotently, regardless of which subset of tabs was passed to `republish` — the order call is not conditioned on which tabs changed or whether tabs already exist.

**SHEET-ORDER-010 (Unwanted behavior).** IF the write lock cannot be acquired before a republish cycle THEN THE system SHALL perform no writes at all that cycle (no tab data writes, no `set_tab_order` call) and SHALL report `published: false` with the stale-tab set unchanged.

**SHEET-ORDER-011 (Unwanted behavior).** IF `set_tab_order` fails (after tab data writes succeeded) THEN THE system SHALL report the overall republish outcome as `published: false`, while per-tab write results/stale flags from that cycle stand as already applied (order failure alone does not roll back or re-mark successfully-written tabs as stale).

**SHEET-ORDER-012 (State-driven).** WHILE modeling only the values grid (the in-memory test fake), `set_tab_order` SHALL be treated as a no-op that still succeeds and is still recorded in the call log — the real (`runtime`) client is the one that issues an actual `updateSheetProperties`/`batchUpdate` metadata call.