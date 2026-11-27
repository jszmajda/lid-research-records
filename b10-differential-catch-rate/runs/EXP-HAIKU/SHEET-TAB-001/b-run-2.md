Looking at these five files, I can now reconstruct the EARS-style requirements for the view-tab layout contract. This concerns the published sheet structure, the cell-grid projection, the frozen-header preservation across republish, and the separate settle pass for price read-back.

---

**SHEET-TAB-LAYOUT (state-driven)**

The workbook SHALL contain exactly four view tabs in this left-to-right order: Positions, Open Lots, Realized, Tax. The full workbook tab ordering is idempotently asserted on republish per `workbook_tab_order()`: views → History → Config tabs → Event logs (far right).

**SHEET-POSITIONS-LAYOUT (state-driven)**

The Positions tab has a frozen header row (row 1, never rewritten) with exactly 13 columns: Symbol, Shares, Avg Cost/Share, Total Basis, Price, Market Value, Unrealized P&L, Est. Tax Rate, Est. Unrealized Tax, Net Unrealized, Unrealized %, Realized P&L, Quote Date. Data begins at row 2. The tab contains exactly one row per position symbol from Snapshot.positions; duplicate symbols trigger ViewError::DuplicateSymbolRow. Each row is exactly 13 cells (no ragged rows). Column E (Price, index 4) is a live GOOGLEFINANCE formula. Column M (Quote Date, index 12) is a companion GOOGLEFINANCE formula that renders the trade-time date as days-since-1970-01-01 via TEXT(…,"0") — an integer-only string locale-proof for read-back parsing as i32.

**SHEET-OTHER-TABS-LAYOUT (state-driven)**

Open Lots and Realized tabs each have frozen headers (10 and 11 columns respectively) with one row per entity (open lot, realized gain); no among-data summary rows. The Tax tab is two distinct typed bands: accrual band (tab "Tax", 6 columns, one row per accrual) and reserve summary band (tab "Tax · Reserve Summary", 7 columns, one row per (Jurisdiction, Tax Year)). Neither band contains blank/label/separator/embedded-header rows.

**SHEET-PUBLISH-CONTRACT (event-driven)**

batch_update_view writes a tab's data range from DATA_START_ROW (row 2) as one atomic batchUpdate + tail-truncate, leaving no mid-write window or stale residual rows. The frozen header (row 1) is written once on tab creation (ensure_sheet) and never rewritten; only data rows are rewritten. Cell::Value is written as userEnteredValue (Sheets parses as human-typed: bare number as number, percent-suffixed string as numeric fraction); Cell::Formula is written as userEnteredValue formula (prefixed `=`).

**SHEET-SETTLE-PASS-CONTRACT (event-driven)**

A separate settle pass (never inline with formula write) reads Positions Price (col E) and Quote Date (col M) back. Price cells: empty/"Loading..." → Transient; "#N/A" → Transient; other # prefix → Permanent; numeric f64 → Numeric { price_usd, quote_date }; non-numeric → Permanent. Quote Date: parsed as i32 days-since-1970, default 0 if absent. Poll until all symbols are numeric-or-terminal or max_polls elapsed; carry prior good marks forward for still-transient symbols; degrade transient-past-window (TimedOut) or terminal (Permanent) without mark. price_to_cents: non-finite → Permanent; non-positive → SubCent; positive → round via pt_core::round_half_to_even (canonical rounding); result of 0¢ → SubCent.

{scratch}/audit-baseline/crates/sheets-view/src/lib.rs
{scratch}/audit-baseline/crates/sheets-view/tests/tabs.rs
{scratch}/audit-baseline/crates/runtime/src/adapters.rs
{scratch}/audit-baseline/crates/runtime/tests/cold_start.rs