## QUOTE-DATE Encoding Requirements

**H-MARK-008: Quote Date Companion Column**

### SHEET-MARK-008-001 [x] — Columns and Position
The Quote Date column occupies column index 12 (M in A1 notation) in the Positions tab, immediately after the Realized P&L column (L), as a live-formula cell paired with each symbol's Price formula in column E (column 4).

### SHEET-MARK-008-002 [x] — Formula Contract and Encoding
The Quote Date cell encodes `GOOGLEFINANCE`'s quote date as a locale-proof integer day serial via the formula `=IFERROR(TEXT(INT(GOOGLEFINANCE("{ticker}","tradetime")),"0"),"")`. The formula:
- Reads GOOGLEFINANCE's `tradetime` attribute (a locale-dependent datetime)
- Truncates to INT — a plain day count serial (epoch unspecified, inherited from GOOGLEFINANCE)
- Renders via `TEXT(...,"0")` — a digits-only string every locale formats identically
- Returns empty string on load/error (IFERROR) — never an error marker

### SHEET-MARK-008-003 [x] — Ticker Resolution
The quote date formula uses the **resolved ticker** from the `config::AliasMap`, not the raw ledger symbol. A symbol "AMZN" aliased to "NASDAQ:AMZN" yields a formula referencing "NASDAQ:AMZN", not "AMZN".

### SHEET-MARK-008-004 [x] — Settle-Pass Read-Back
The settle pass reads the Quote Date cell value (the text result after GOOGLEFINANCE evaluation and TEXT rendering) as a 32-bit signed integer (`i32`), interpreting it as the day count epoch. Parsing defaults to 0 on failure; it is wrapped as `pt_core::Date(quote_days)` and paired with the numeric price as a per-symbol mark's `quote_date` timestamp.

### SHEET-MARK-008-005 [x] — Conditioning on Price Cell
The Quote Date cell is read and stored only when the corresponding Price cell (column E) evaluates to a numeric f64 value. If the Price cell is empty, transient (`#N/A`, `Loading...`), or a permanent error marker (e.g. `#ERROR!`), the Quote Date cell is not consulted and no mark is recorded for that symbol on that settle pass.

(Under 400 words; all behavior pinned by code and tests.)