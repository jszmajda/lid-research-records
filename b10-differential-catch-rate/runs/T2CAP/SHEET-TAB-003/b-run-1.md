P-TAB-003 — View-tab republish: what survives, what is overwritten.

**Ubiquitous.** The system shall publish exactly four view tabs — `Positions`, `Open Lots`, `Realized`, `Tax` (`VIEW_TABS`, len 4) — each as a `ViewTab` of a typed header plus data rows, one row per entity, every row exactly as wide as its header, with no blank/label/embedded-header rows among the data.

**Ubiquitous.** The system shall write data rows from the fixed anchored start row `DATA_START_ROW = 2`; row 1 is the frozen header.

**Event-driven.** When a view tab is published to a workbook where the tab does not yet exist, the system shall create the tab, write the segment-owned typed header once at `'<tab>'!A1`, then write the data range `'<tab>'!A2:Z`.

**Event-driven.** When a view tab that already exists is republished, the system shall rewrite only the data range from row 2 down as ONE atomic `batchUpdate`/`update_range`, replacing the prior data rows wholesale and truncating the residual tail to the exact new row count — so a shorter render leaves no leftover stale rows (2 rows → 1 row leaves exactly 1), and no half-written window is observable.

**Event-driven / unwanted-behavior.** When a view tab is republished, the system shall never rewrite the frozen header row; the republished header shall be byte-identical to the header written at bootstrap. A republish presenting a different header is a contract violation and shall fail loudly (unconditional assertion, all builds).

**Ubiquitous (overwrite semantics).** Any user edit inside the data range — inserted, reordered, sorted, or hand-edited rows — shall be overwritten by design on the next republish; nothing in the data range survives. Only the frozen header survives.

**Event-driven.** When republishing, the system shall acquire the advisory write-lock before any workbook mutation and release it after; the workbook tab order (`workbook_tab_order()`: Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events) shall be idempotently reasserted after the tab writes, yielding the identical order on every republish.

**Unwanted-behavior.** If the lock cannot be acquired, the system shall write nothing that cycle and return `published: false` with the stale set unchanged.

**Unwanted-behavior.** If a tab's `batch_update_view` fails (`ViewError::PublishFailed`), the system shall leave that tab as-is (prior header and prior data intact, internally consistent but behind), flag it stale, write the best-effort in-tab banner `"STALE — last sync {quote_ts}"` (at `'<tab>'!AA1`), continue with the remaining tabs, set `published: false`, and retry it next sync; a failed banner write is swallowed (TUI is the fallback surface). A `set_tab_order` failure alone also sets `published: false` without corrupting truth.

**Ubiquitous.** The Tax surface publishes two distinct typed bands — the accrual band on `Tax` under `TAX_HEADER` and the reserve summary under `TAX_RESERVE_HEADER` on the separate `Tax · Reserve Summary` range — never a summary band embedded in the accrual range.