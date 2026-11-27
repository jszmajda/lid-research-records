P-TAB-003 (republish survival/overwrite) — reconstructed EARS

**Ubiquitous**
- U1. The system shall write each view tab's typed column header exactly once, on the write that creates the tab (`ensure_sheet` then a write to `'<tab>'!A1`), and shall treat row 1 as frozen thereafter.
- U2. The system shall anchor view-tab data rows at a fixed start row `DATA_START_ROW = 2` (range `'<tab>'!A2:Z`), immediately beneath the frozen header.
- U3. The system shall publish each view tab as one atomic `batchUpdate` (a single `update_range` of the data range), so no half-written intermediate state is observable.
- U4. The system shall reassert the full workbook tab order on every republish, idempotently, as exactly: Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events (Positions leftmost/landing; the two event logs last). Repeated republishes shall yield an identical order.

**Event-driven**
- E1. When a view tab is republished, the system shall replace the entire data range wholesale with the newly rendered rows and truncate the residual tail to the exact new row count — no appending, no merge. Consequently any prior data-row content shall not survive: human-inserted, hand-edited, re-sorted, or now-surplus rows (row count 2 → 1) are overwritten/removed by design.
- E2. When a view tab is republished, the system shall not rewrite row 1; the header presented by the republish shall be byte-identical to the frozen header, and a differing header is a contract violation (asserted unconditionally at the seam, in all builds).
- E3. When the tab does not yet exist (fresh workbook), the system shall create the sheet, write the frozen header once, then retry the data write; failure of any step yields `ViewError::PublishFailed`.
- E4. When a tab's `batchUpdate` succeeds, the system shall clear that tab's stale flag.
- E5. When the advisory write-lock cannot be acquired, republish shall write nothing that cycle and return `published: false` with the stale set unchanged (non-destructive refusal; retried next sync).

**Unwanted-behavior**
- X1. If a tab's `batchUpdate` fails, the system shall leave that tab exactly as-is (prior published content survives, internally consistent but behind), never corrupting canonical truth; shall flag the tab stale; shall best-effort write the single-cell banner `"STALE — last sync {quote_ts}"` at `'<tab>'!AA1` (outside the rewritten `A2:Z` data range, so it survives republishes); shall report `published: false` with the tab listed in `stale_tabs`; and shall retry it on the next sync.
- X2. If the banner write also fails, the system shall proceed silently (the TUI is the fallback staleness surface).
- X3. If `set_tab_order` fails, the system shall report `published: false` without flagging any tab stale.
- X4. Tabs absent from the republish set shall be left untouched.

Files: `{scratch}/audit-P-TAB-003/crates/sheets-view/src/lib.rs`, `.../src/testkit.rs`, `.../tests/tabs.rs`, `.../crates/runtime/src/adapters.rs`