**EARS requirements enforced (view-tab republish: survive vs. overwrite)**

**U1 (ubiquitous).** The system shall treat a view tab as two regions: a frozen header at row 1, and a data region beginning at the fixed anchor `DATA_START_ROW = 2` extending through column Z.

**U2 (ubiquitous).** On any republish of an existing tab, the system shall rewrite the entire data region as one atomic `update_range` call, replacing all previously-published data rows wholesale and truncating the tail to exactly the new row count — never appending, never leaving residual rows beyond the new count.

**UB1 (unwanted behavior).** If a tab already exists and is republished, then the system shall NOT rewrite row 1: the header supplied on republish must be byte-identical to the header already stored for that tab. A mismatch is a contract violation the client enforces unconditionally (in test/prod), not release-stripped.

**Consequence of U2/UB1:** any row a human inserted, edited, sorted, or reordered within the data region is silently overwritten/discarded on the next republish (the region is regenerated wholesale each cycle); the header alone survives untouched.

**EV1 (event-driven).** When a named view tab does not yet exist (fresh workbook / first publish), the system shall create the sheet, write the header to row 1 exactly once, then write the data region — this is the only occasion the header is ever written.

**EV2 (event-driven).** When republish runs across the four view tabs, each tab's `batchUpdate` shall be attempted independently — one tab's write failure shall not block or roll back another tab's write.

**UB2 (unwanted behavior).** If a tab's `batchUpdate` fails, then the system shall leave that tab's existing published content as-is (no partial/half-written data), mark the tab stale, best-effort write the fixed-format banner `"STALE — last sync {timestamp}"` to cell `AA1`, and retry that tab on the next sync — canonical truth (the log) is unaffected.

**EV3 (event-driven).** After every tab write attempt (success or failure), the system shall idempotently reassert the full workbook tab order via `set_tab_order`; repeated republishes yield the identical order.

**State-driven (SD1).** While the advisory write lock is held by another writer (or unacquirable), republish shall perform zero writes for the entire cycle, returning `published:false` with the stale set unchanged, rather than write partially or concurrently.

Files: `crates/runtime/src/adapters.rs`, `crates/sheets-view/src/lib.rs`, `crates/sheets-view/src/testkit.rs`, `crates/sheets-view/tests/tabs.rs` (all under the given `audit-baseline` scratchpad path).