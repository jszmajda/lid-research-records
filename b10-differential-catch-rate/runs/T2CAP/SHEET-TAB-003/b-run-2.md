P-TAB-003 reconstructed requirements — "what survives or is overwritten on republish"

**[Ubiquitous] VIEW-PUB-1 (frozen header).** Each view tab's typed header SHALL occupy row 1 and be written exactly once — at tab bootstrap (`ensure_sheet` then a single write to `'<tab>'!A1` of the `ViewTab.header`). Republish SHALL NOT rewrite row 1. A republish presenting a header not byte-identical to the stored one is a contract violation and SHALL fail loudly (unconditionally, in all builds).

**[Event-driven] VIEW-PUB-2 (wholesale data regeneration).** When a view tab is republished, the system SHALL rewrite the data range from `DATA_START_ROW = 2` (`'<tab>'!A2:Z`) as ONE atomic `batchUpdate`, replacing prior data rows wholesale (never appending) and truncating the residual tail to the exact new row count, so no stale leftover row and no half-written window survives. Consequently any human edit inside the data range — inserted, re-sorted, or hand-typed rows — SHALL NOT survive republish (by design); only row 1 survives.

**[Event-driven] VIEW-PUB-3 (order reassert).** On every republish the system SHALL reassert the full workbook tab order idempotently: Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events — Positions leftmost (landing), event logs last. Repeated republishes SHALL yield an identical order.

**[Event-driven] VIEW-PUB-4 (per-band separation).** The Tax surface SHALL republish two distinct typed bands with their own frozen headers — the accrual band (`Tax`) and `Tax · Reserve Summary` — one row per entity, never blank/label/embedded-header rows inside the accrual band.

**[Unwanted] VIEW-PUB-5 (failed tab write).** If a tab's `batchUpdate` fails, the system SHALL leave that tab's prior contents intact (stale, internally consistent, canonical log unaffected), flag the tab stale, write a best-effort single-cell banner `"STALE — last sync <ts>"` outside the data range (`'<tab>'!AA1`), continue publishing the remaining tabs, report `published: false` with the stale-tab list, and retry next sync. A failed banner write SHALL be ignored (TUI is the fallback surface). A successful republish of a tab SHALL clear its stale flag.

**[Unwanted] VIEW-PUB-6 (order-reassert failure).** If `set_tab_order` fails, `published` SHALL be false, but no tab SHALL be flagged stale.

**[Unwanted] VIEW-PUB-7 (lock refusal).** The advisory write-lock SHALL be acquired before any workbook mutation and released after. If acquisition fails, republish SHALL write nothing that cycle, leave every tab and the stale set unchanged, and return `published: false`.

**[State-driven] VIEW-PUB-8.** While a settle pass runs, it SHALL occur only after all republish writes return (separate pass, same thread); a transiently-unknown symbol SHALL keep its prior cached mark rather than being overwritten.