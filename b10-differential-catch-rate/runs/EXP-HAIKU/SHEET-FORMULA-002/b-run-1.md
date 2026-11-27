Based on reading the four files, here are the EARS-style requirements for per-row live formula anchoring and cell references:

---

**SHEET-FORMULA-ANCHOR-001:** [State-Driven] Each per-row live formula references ONLY its own data row's cells beneath the frozen header (row 1). For a position symbol at data row R (R ≥ 2, where DATA_START_ROW = 2), all live formulas in that row reference only cells E through M of row R, never any other row's cells. A formula that leaks a reference to row R' where R' ≠ R is structurally invalid and must be caught in tests. (Test: `per_row_formulas_reference_their_own_row_beneath_frozen_header`)

**SHEET-FORMULA-ANCHOR-002:** [Ubiquitous] The Positions tab's five live-formula columns are locked to fixed column letters and row-relative cell references:
- Column E (Price): `=GOOGLEFINANCE("{ticker}","price")`
- Column F (Market Value): `=E{r}*B{r}` where {r} is the row number
- Column G (Unrealized P&L): `=F{r}-D{r}`
- Column I (Est. Unrealized Tax): `=G{r}*H{r}`
- Column J (Net Unrealized): `=G{r}*(1-H{r})`
- Column K (Unrealized %): `=IF(D{r}=0,0,G{r}/D{r})`
- Column M (Quote Date): `=IFERROR(TEXT(INT(GOOGLEFINANCE("{ticker}","tradetime"))-DATE(1970,1,1),"0"),"")`

**SHEET-FORMULA-ANCHOR-003:** [State-Driven] The Quote Date formula (column M, index 12) encodes `GOOGLEFINANCE`'s tradetime as days since 1970-01-01 (the kernel Date epoch) via `INT(tradetime) - DATE(1970,1,1)`, then renders it as a locale-proof digits-only string via `TEXT(...,"0")`. While loading or errored, it renders empty (via `IFERROR`), never an error marker. The settle-pass read-back parses this string back to a kernel Date.

**SHEET-FORMULA-ANCHOR-004:** [State-Driven] The Est. Tax Rate cell (column H) is written as a percent-suffixed numeric value (e.g. `"20.0000%"`), NOT a formula. The post-tax formulas (`=G*H` and `=G*(1-H)`) multiply this cell; Sheets must coerce the percent-format value to a fraction (0.20) for the multiplication to yield correct pre-tax and net figures. A numeric percent is the load-bearing type; text or zero would break the contract.

**SHEET-FORMULA-ANCHOR-005:** [Ubiquitous] Data rows start at fixed row 2 (DATA_START_ROW = 2). Row 1 is the frozen header, written once and never rewritten on republish. Any republish that presents a header different from the prior write (byte-identical) violates the contract and triggers a panic (seen in `testkit.rs` line 176).

**SHEET-FORMULA-ANCHOR-006:** [State-Driven] The settle pass reads Price (column 4, zero-indexed E) and Quote Date (column 12, zero-indexed M) from the Positions tab back as strings. A numeric Price is parsed as f64 and rounded via `round_half_to_even(price × 100)` to Cents; non-positive values and non-finite values degrade (Permanent or SubCent). A quote date string is parsed as `i32` days-since-epoch; parse failure or empty string leaves the mark absent (transient retry or degradation based on prior marks).

---

{scratch}/audit-baseline/crates/runtime/src/adapters.rs, {scratch}/audit-baseline/crates/sheets-view/src/lib.rs, {scratch}/audit-baseline/crates/sheets-view/src/testkit.rs, {scratch}/audit-baseline/crates/sheets-view/tests/formula.rs