**EARS requirements enforced — Positions/Open Lots/Realized/Tax formula-vs-value column split**

*Ubiquitous:*

1. The system shall render Positions columns Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, and Quote Date (columns E,F,G,I,J,K,M — index 12 for Quote Date) as live `Cell::Formula` cells; columns Symbol, Shares, Avg Cost/Share, Total Basis, Est. Tax Rate, and Realized P&L shall render as `Cell::Value`.
2. Every cell in Open Lots, Realized, and both Tax bands (accrual band and reserve-summary band, including all five reserve columns Accrued/Moved/Paid/Outstanding/Shortfall) shall render as `Cell::Value`; no formula cell shall appear in these tabs.
3. Each row-anchored formula shall reference only cells bearing its own row's 1-based row number (`r = row_index + DATA_START_ROW`, DATA_START_ROW=2) and shall not reference any other data row's cell address, so a row shift cannot mis-pair cells.
4. Formula text, exact: Price = `=GOOGLEFINANCE("<ticker>","price")`; Market Value = `=E{r}*B{r}`; Unrealized P&L = `=F{r}-D{r}`; Est. Unrealized Tax (est) = `=G{r}*H{r}`; Net Unrealized (est) = `=G{r}*(1-H{r})`; Unrealized % = `=IF(D{r}=0,0,G{r}/D{r})`; Quote Date = `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, ticker double-quoted and alias-resolved.
5. `Cell::Value` shall be written to Sheets as `userEnteredValue` (never forced `stringValue`), so a bare number parses as a number and a percent-suffixed string parses as its numeric fraction with percent formatting; `Cell::Formula` shall likewise be written as `userEnteredValue` holding the formula text (leading `=`).
6. The Est. Tax Rate value shall be encoded as a percent-suffixed numeric string (e.g. `"20.0000%"`) — never plain text — because formulas I and J multiply that cell directly (`=G*H`, `=G*(1-H)`) and require numeric coercion, not an error/0 result.

*Event-driven:*

7. WHEN a symbol has no `effective_rate` entry (degraded tax estimate), THEN Est. Tax Rate shall render as an empty value string (not a formula, not "0.0000%"), and the dependent post-tax formulas shall degrade to the pre-tax figure via that empty/zero-coercing input.

*Unwanted behavior:*

8. IF `GOOGLEFINANCE`'s `tradetime` read is loading or terminally errored, THEN the Quote Date formula shall evaluate to `""` (via `IFERROR`), never a raw locale-dependent datetime string or an error literal, since the settle pass parses this cell as digits-only.