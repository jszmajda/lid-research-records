## SHEET-LAYOUT: View Tab Layout Contract

**Pattern**: Ubiquitous (every republish), enforced by adapters and tests.

### Tab Set & Naming
- Exactly four published view tabs, named: Positions, Open Lots, Realized, Tax (constant `VIEW_TABS`). One row per entity (symbol, lot, gain, accrual); no among-data summary rows, blank rows, labels, or embedded headers.

### Frozen Header
- Row 1 (1-based) is the typed header—written once, never rewritten on republish. Only data rows from `DATA_START_ROW` (row 2) onward are regenerated. Each row width matches its header width exactly (no ragged rows).

### Tax Tab: Two Distinct Typed Ranges
- Accruals band: one row per accrual under `TAX_HEADER` (6 columns: Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State). Reserve Summary band: one row per `(Jurisdiction, Tax Year)` under `TAX_RESERVE_HEADER` (7 columns: Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall). Both are separate typed ranges with frozen headers; no blank/label/embedded-header rows between bands.

### Workbook Tab Order (Idempotent)
- Reasserted on every republish to: Views (Positions, Open Lots, Realized, Tax) → History (reports) → Config (Tax Rules, Residency, Platforms & Aliases) → Event Logs (Ledger Events, Tax Events). Positions is the leftmost (landing) tab.

### Positions Tab: Live Price Layout
- Column 4 (0-based): Price cell; formula `=GOOGLEFINANCE("{ticker}","price")`. Column 12: Quote Date cell; formula encodes `GOOGLEFINANCE` trade-time as days-since-1970-01-01 (locale-proof integer string). Settle pass reads these columns back separately, never inline with the formula write.

### Price Cell Reading Semantics
- Numeric: positive `f64` USD → `Cents` via `price_usd × 100` rounded `round_half_to_even`; carries quote-date from column 12 as `i32` days. Transient: `#N/A`, `Loading...`, empty. Permanent: cell starts with `#` (e.g. `#ERROR!`, ticker mismatch). Non-positive numeric, non-finite, or value rounding to ≤0 Cents: degraded SubCent (no mark). Transient after bounded-window polls: degraded TimedOut (carry prior mark if cached). Permanent: degraded Permanent (drop mark).

### Cell Typing for Publish
- `Cell::Value`: engine-computed (shares, basis, P&L, tax rates); written as `userEnteredValue` so Sheets parses percent-suffix strings (e.g. `"20.0000%"`) as numeric fractions. `Cell::Formula`: live formulas; written as `userEnteredValue` (Sheets preserves formula).

### Idempotent Republish
- Each cycle regenerates all data rows beneath frozen header and tail-truncates to exact row count (no residual stale rows). Prior human-inserted/sorted rows are overwritten by design; data is canonical.