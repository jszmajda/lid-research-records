## EARS-Style Specification: View-Tab Republish Preservation

**Category: State-Driven (tab state across republishes)**

### P-TAB-001: Frozen header row survives republish unchanged
When a view tab (Positions, Open Lots, Realized, or Tax) is republished via `batch_update_view` after initial creation, the tab's header row (row 1: column names, types) is preserved byte-for-byte. The header is written once on tab creation and never overwritten on subsequent republishes, even when the data rows change.

### P-TAB-002: Data rows wholly replaced on republish
Each republish atomically overwrites all data rows (rows 2 onward) with the new data set. The operation is a wholesale replace, not append-only. A row present in a prior version but absent from the new data set is deleted; human-inserted rows in the data range do not survive the next republish.

### P-TAB-003: Tail truncation: residual rows deleted
If a republish has fewer data rows than the prior version, the residual tail is deleted. Example: prior version had rows 2–10 (nine rows); new version has rows 2–5 (four rows); rows 6–10 are truncated. The tab carries no stale or leftover rows from prior syncs.

### P-TAB-004: Header identity enforced; mismatch is error
A republish presenting a header row that is not byte-identical to the tab's existing frozen header causes an assertion failure (invariant violation). The tab's schema (column order, type, width) is immutable once frozen; a caller's header change is refused.

### P-TAB-005: First-tab creation: header-write-once atomic sequence
When a tab does not yet exist, creating it is a serialized three-step sequence: (1) ensure the sheet exists; (2) write the typed header row (row 1) in a single update; (3) write the data range (rows 2+) in a second update. The header is locked (frozen) on step 2 and never rewritten thereafter.

### P-TAB-006: Cell value/formula typing per column is stable
Each republish writes each cell according to its `Cell` enum: `Cell::Value` as a `userEnteredValue` (Sheets parses it per user-input rules: bare numerals as numbers, percent-strings as numeric percents); `Cell::Formula` as a formula starting with `=` (recalculates on change). The value/formula split per column is enforced by the render functions and stable across republishes (e.g., Price column is always `Cell::Formula`, Symbol column is always `Cell::Value`).

### P-TAB-007: Live-formula columns recalculate on republish
Formula cells (`GOOGLEFINANCE("TICKER","price")`, row-anchored formulas `=B*C`, market-value, unrealized-P&L, post-tax-estimate columns) are rewritten on each republish and recalculate as their input cells update or as new data is written.

---

**Constants/boundaries:**
- `DATA_START_ROW = 2` (frozen header at row 1; data rows start row 2)
- Frozen header enforced via assertion in `InMemorySheetsView::batch_update_view`
- Wholesale row replacement: `existing.rows = tab.rows.clone()` (no append or merge)

{scratch}/audit-P-TAB-003/crates/sheets-view/src/lib.rs:427-449 (SheetsViewClient contract), {scratch}/audit-P-TAB-003/crates/sheets-view/src/testkit.rs:172-179 (fake enforcement), {scratch}/audit-P-TAB-003/crates/sheets-view/tests/tabs.rs:181-218 (test validation)