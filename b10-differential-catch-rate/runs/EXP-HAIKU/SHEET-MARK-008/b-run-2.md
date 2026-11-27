Looking at the three files, I can identify the requirements enforced for how the quote date companion column encodes the trade date:

## Quote Date Companion Column Encoding (SHEET-MARK-*)

**Ubiquitous:**
- Column 12 of the Positions tab carries the Quote Date companion column for every position row.
- Quote Date is a live formula (never an engine value) derived from the symbol's resolved ticker via GOOGLEFINANCE.

**Formula Contract:**
- Quote Date formula is `=IFERROR(TEXT(INT(GOOGLEFINANCE("[ticker]","tradetime")),"0"),"")`, where `[ticker]` is the symbol's resolved alias.
- The formula extracts GOOGLEFINANCE's `tradetime` attribute, truncates it to an integer date serial via `INT` (converting the locale-dependent datetime to a day count), renders it as a digit-only string via `TEXT(...,"0")` (locale-proof), and wraps the result in `IFERROR` to return empty string on loading or permanent error.

**Read-Back Normalization & Tie-Break (Settle Pass):**
- The settle pass reads the Price and Quote Date cells as formatted strings (not formulas) from the Positions tab data range (row 2 onward).
- Quote Date at column 12 is parsed as an integer day count (i32 in kernel representation, `pt_core::Date`).
- If the cell is empty, missing, or unparseable as an integer, it defaults to 0 days (epoch anchor).
- Every numeric price reading pairs with its Quote Date integer; transient/error price readings do not pair with quote dates.

**Encoding Semantics:**
- The quote date stamp originates from GOOGLEFINANCE's own quote time, not wall-clock read time.
- The integer encoding is locale-proof; `TEXT(...,"0")` produces identical digits in every locale, circumventing locale-dependent datetime parsing.
- Empty cells (loading/error state) never emit error strings like `#N/A`; they resolve to empty for silent retry.

{lid-checkout}/docs/research/experiments/b10-differential-catch-rate/answer-key

```
SHEET-MARK-010: The Positions tab Quote Date column (index 12) encodes GOOGLEFINANCE's trade date as a locale-proof integer day count via formula =IFERROR(TEXT(INT(GOOGLEFINANCE(...,"tradetime")),"0"),""), parsed by the settle pass as i32 with 0-default on empty/missing/unparseable.
```