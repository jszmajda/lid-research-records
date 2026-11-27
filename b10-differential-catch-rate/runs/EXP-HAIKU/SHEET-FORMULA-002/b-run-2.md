Looking at the four files, I can extract the EARS-style requirements that specify how per-row live formulas are anchored and which cells they reference:

**SHEET-FORMULA-ANCHOR-001 [ubiquitous]**: Per-row formulas on the Positions tab are anchored to row identity by 1-based row number. Each data row's row number is computed as `(row_index + DATA_START_ROW)` where `DATA_START_ROW = 2` (the frozen header occupies row 1, data begins at row 2). On every render, row indices reset from 0.

**SHEET-FORMULA-ANCHOR-002 [ubiquitous]**: Per-row live-formula cell references bind exclusively to their own row. Market Value (`E{r} × B{r}`), Unrealized P&L (`F{r} - D{r}`), Est. Unrealized Tax (`G{r} × H{r}`), Net Unrealized (`G{r} × (1 - H{r})`), and Unrealized % (`IF(D{r}=0, 0, G{r}/D{r})`) all reference column-cells within the same `{r}` row only. No formula references any other data row.

**SHEET-FORMULA-QUOTE-COMPANION-003 [ubiquitous]**: Quote Date (column 12) is a live formula encoding GOOGLEFINANCE's trade-time as days-since-1970-01-01 via `=IFERROR(TEXT(INT(GOOGLEFINANCE("{ticker}","tradetime")-DATE(1970,1,1),"0"),"")`, rendering locale-proof digits only, empty on load/error, and using the **resolved ticker** (via AliasMap) not the symbol literal.

**SHEET-POSTTAX-FORMULA-MULTIPLIER-004 [ubiquitous]**: The post-tax formulas (`=G{r} × H{r}` for tax, `=G{r} × (1 - H{r})` for net) rely on the Est. Tax Rate cell (`H{r}`) being a **numeric percent** that sheets coerces to a fraction in [0, 1]. Est. Tax Rate is written as a `Cell::Value` (not a formula) with percent-suffixed text (e.g. `"20.0000%"`), and the `SheetsViewClient` contract requires `Cell::Value` to be written as `userEnteredValue` so Sheets parses it exactly as a human typing it would—numeric fraction with percent format, never inert text.

**SHEET-FROZEN-HEADER-005 [ubiquitous]**: The Positions header is frozen (row 1) and written once. On every republish, the same byte-identical header is asserted; a mismatched header is a fatal invariant violation (panic, even in release). No formula re-anchoring happens on republish because the header never changes.

**SHEET-TAX-NO-FORMULAS-006 [ubiquitous]**: The Tax tab (accruals band) and Tax Reserve Summary band carry **no live-formula cells**—all are engine values (kernel-exact, stacked, as-of-last-sync). Both reserve all five columns (Accrued, Moved, Paid, Outstanding, Shortfall) populated with non-blank values.

**SHEET-TAIL-TRUNCATE-007 [event-driven / republish]**: Data rows are replaced wholesale and truncated to the exact row count; no half-written windows or stale tail rows remain.

---

{scratch}/audit-baseline/crates/runtime/src/adapters.rs
{scratch}/audit-baseline/crates/sheets-view/src/lib.rs
{scratch}/audit-baseline/crates/sheets-view/src/testkit.rs
{scratch}/audit-baseline/crates/sheets-view/tests/formula.rs