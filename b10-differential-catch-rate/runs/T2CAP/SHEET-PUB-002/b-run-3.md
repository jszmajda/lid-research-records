U-PUB-002 / republish cell-rewrite — reconstructed EARS

**Ubiquitous**
- PUB-001 The system shall treat every published view-tab cell as either an engine-written `Value` or a live `Formula`, and shall write each cell's text through the same low-level range write, preserving that typing (a `Value` as a user-entered value Sheets parses as a human would — a bare number as number, `"20.0000%"` as the fraction 0.20 with percent format — never a forced string; a `Formula` as a user-entered formula).
- PUB-002 The system shall anchor view-tab data rows at row `DATA_START_ROW = 2`, with row 1 reserved for the typed frozen header.
- PUB-003 The system shall address a view tab's data range as `'<tab>'!A2:Z`.

**Event-driven**
- PUB-010 When a view tab is republished, the system shall rewrite its data range as one atomic operation that replaces the prior rows wholesale and truncates the residual tail to the exact new row count, leaving no leftover stale rows and no half-written window.
- PUB-011 When a view tab is republished, the system shall write row 1 exactly once (at tab bootstrap) and shall never rewrite the frozen header thereafter; a republish shall present a header identical to the published one.
- PUB-012 When a republished tab's row count exceeds `VIEW_WRITE_CHUNK_ROWS = 500`, the system shall write the rows as successive row-anchored chunks of at most 500, chunk *i* anchored at row `2 + i*500`, so no single write carries an oversized payload; at or under 500 rows it shall issue exactly one write. An empty row set shall still issue one data-range write.
- PUB-013 When the target tab does not exist, the system shall create it, write the segment-owned frozen header at `'<tab>'!A1`, then retry the data write.
- PUB-014 When all tabs have been rewritten, the system shall reassert the workbook tab order (Positions, Open Lots, Realized, Tax, History, Tax Rules, Residency, Platforms & Aliases, Ledger Events, Tax Events).
- PUB-015 When a tab's rewrite succeeds, the system shall clear that tab's stale flag.

**Unwanted behavior**
- PUB-020 If the advisory write-lock cannot be acquired, the system shall write nothing that cycle and report `published: false` with the stale set unchanged.
- PUB-021 If a tab's rewrite fails, the system shall land nothing for that tab, flag it stale, best-effort write the single-cell banner `"STALE — last sync <ts>"` at `'<tab>'!AA1`, report `published: false`, and retry on the next sync; the canonical log is unaffected.
- PUB-022 If the banner write also fails, the system shall still retain the stale flag (the TUI remains the staleness surface).
- PUB-023 If the tab-order reassert fails, the system shall report `published: false` without flagging any tab stale.
- PUB-024 If the underlying API is unreachable, the system shall surface `ViewError::PublishFailed`.

**State-driven**
- PUB-030 While a republish-then-settle cycle runs, the system shall perform every price read-back strictly after all tab rewrites, on one serialized thread of control.