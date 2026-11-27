Looking at these files, I can now reconstruct the EARS-style requirements for what survives or is overwritten when a view tab is republished.

**P-TAB-001 — Frozen Header Permanence**
Once a view tab is published and its header written to row 1, that header is never rewritten on any subsequent republish. The header is locked in place. A republish that presents a different header (even a single cell changed) is in violation of the contract and surfaces as a development panic in test/verification builds (testkit.rs line 176).

**P-TAB-002 — Data Range Wholesale Replacement (Tail-Truncate)**
Each republish atomically replaces all data rows (from row 2 onwards) as a single operation. The publisher writes the full set of new data rows via one `update_range` call anchored at `DATA_START_ROW` (row 2). After the write completes, the residual tail (all rows beyond the new data set) is truncated to the exact row count of the incoming rows, so a republish with fewer rows deletes the prior excess, and a republish with more rows appends. No row is left half-written or stale.

**P-TAB-003 — Cell Typing Regeneration**
Every cell's type — `Cell::Value` (engine-computed) or `Cell::Formula` (live `GOOGLEFINANCE` formula) — is regenerated fresh on every republish. Both are written as Sheets `userEnteredValue` entries (not forced strings), so `Value` cells parse per Sheets' rules and formula cells are recognized by their leading `=`. The typing is structural and always flows from the current view-rendering logic, never preserved from prior publishes.

**P-TAB-004 — Tab Order Idempotent Reassertion**
On every republish, the workbook tab order is reasserted to match `workbook_tab_order()` (views left-to-right, then History, then config tabs, then event logs far right). The Positions tab is always leftmost. This reassertion is separate from the data write and is unconditionally retried even if one tab's data write fails.

**P-TAB-005 — Write-Lock Serialization**
A republish acquires an advisory write-lock before any workbook mutation and holds it through the data writes. If the lock cannot be acquired (another segment is writing), the republish does not write anything this cycle; it returns `published: false` and leaves the stale set unchanged, so control passes back to the caller to retry.

**P-TAB-006 — Failure Isolation (No Half-Write)**
If a tab's `batch_update_view` fails (network error, workbook unreachable), that tab is flagged stale for retry on the next sync cycle, and a best-effort in-tab stale banner is written at a fixed cell. The failure does not corrupt other tabs' prior publishes or the canonical event log. Tabs not in the failing tab's write attempt are unaffected.

All behaviors pinned by code (lines 214–237 adapters.rs; 159–192 testkit.rs; lines 181–218 tabs.rs).

<Output: EARS requirements for P-TAB-001 through P-TAB-006 under 400 words, ready for harness consumption>