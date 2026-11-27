Now I'll reconstruct the EARS-style requirements from the code and tests:

**SHEET-LAYOUT-001: Frozen Header Contract**
The Positions, Open Lots, Realized, and Tax tabs each have a typed column header in row 1 (frozen). The header is written once at tab creation and never rewritten on republish; only data rows from row 2 (DATA_START_ROW) onward are overwritten and tail-truncated to the exact current row count. A republish with a different header text is rejected loud (invariant violation).

**SHEET-LAYOUT-002: Atomic Per-Tab BatchUpdate with Tail-Truncate**
Each view tab's republish is a single atomic `batchUpdate`: write the data range (`A2:Z` for a named tab, row count variable) and truncate the residual tail to the exact row count. No partial/half-written window; stale rows below the current data are cleared. Failure leaves the tab internally consistent with the prior snapshot, flagged stale, retried next sync.

**SHEET-LAYOUT-003: One Entity Per Row, No Among-Data Summaries**
Positions: one row per symbol (keyed by position, asserted unique via duplicate-symbol guard). Open Lots: one row per open lot. Realized: one row per realized gain. Tax accrual band: one row per accrual, no blank/label/embedded-header rows stuffed inside — the accrual range is natively filterable end to end. Tax reserve band (distinct tab with own frozen header): one row per (Jurisdiction, Tax Year). No among-data summary rows in any band.

**SHEET-LAYOUT-004: Cell Value Typing (USER_ENTERED)**
`Cell::Value` text is written as a Sheets `userEnteredValue` (not `stringValue` / raw text); Sheets parses it as a human would. A bare number coerces to numeric; a percent-suffixed string like `"20.0000%"` (the Est. Tax Rate column, formatted via `fmt_ppm`) coerces to numeric fraction (0.20) with percent number-format, so live post-tax formulas (`=G*H`, `=G*(1-H)`) multiply correctly (never inert text).

**SHEET-LAYOUT-005: Cell Formula Typing and Live-Price Columns**
`Cell::Formula` (text starting with `=`) is written as `userEnteredValue` (not `stringValue`). Price (Positions col 4, 0-indexed) and Quote Date (col 12) columns carry live `GOOGLEFINANCE` formulas. Quote Date formula yields days-since-1970 (integer) via `TEXT(INT(GOOGLEFINANCE(ticker,"tradetime"))-DATE(1970,1,1),"0")` — locale-proof integer encoding for read-back.

**SHEET-LAYOUT-006: Separate Settle Pass Price Read-Back**
Price read-back (Positions tab col 4, col 12 quote date) is a separate polling pass, never inline with the formula write. Per symbol: numeric price (USD as f64) + quote date (integer days since 1970), or transient (`#N/A`, `Loading...`, empty), or terminal error (permanent `#` error code). Polls until every symbol is numeric-or-terminally-errored or max_polls (default 8) boundary elapses.

**SHEET-LAYOUT-007: Price-to-Cents Conversion and Degradation**
USD price converted to Cents via `price_usd × 100` using `round_half_to_even` (the project's single rounding site). Non-finite (NaN, ±∞) degrades Permanent. Non-positive price or rounding to 0 Cents degrades SubCent (never a real zero mark). Transient symbols retried within bounded window; past window or permanent error, prior cached mark carried forward if available, else marked degraded TimedOut/Permanent (no mark issued).

**SHEET-LAYOUT-008: Workbook Tab Order**
Views (Positions, Open Lots, Realized, Tax) → History (reports) → Config (Tax Rules, Residency, Platforms & Aliases) → Event logs (Ledger Events, Tax Events). Idempotently reasserted on each republish (set_tab_order call, no-op in test harness, batchUpdate in real client).

**SHEET-LAYOUT-009: Stale Tab Handling**
A republish failure leaves the tab internally consistent with the prior snapshot, flags it stale, and writes a best-effort in-tab STALE banner. Retried on next sync. Transport failure (offline) propagates Err, produces no MarksProduced, runtime retains cached marks (not silent carry-forward inside settle).