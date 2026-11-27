**EARS requirements enforced — Positions "Quote Date" companion column (trade-date encoding)**

**Ubiquitous**
- The system SHALL render a "Quote Date" column as the fixed companion to "Price", at Positions header/column index 12 (0-based; column M), one per position row.
- The Quote Date cell SHALL be a live formula (`Cell::Formula`), never an engine-written value.
- The Quote Date formula SHALL be row-anchored, referencing only its own row's ticker resolution — no cross-row reference.
- The Quote Date formula SHALL use the same resolved ticker (via `config`'s alias table) as that row's Price formula.
- The Quote Date formula SHALL be exactly: `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`.
- The formula SHALL truncate GOOGLEFINANCE's `tradetime` to its date serial via `INT(...)`, discarding intraday time-of-day.
- The truncated serial SHALL be re-based to days-since-1970-01-01 (the kernel `Date` epoch) by subtracting `DATE(1970,1,1)`.
- The re-based day count SHALL be rendered via `TEXT(...,"0")` as a digits-only string, so the read-back parses it identically regardless of spreadsheet locale.

**State-driven**
- WHILE the underlying GOOGLEFINANCE quote is loading or erroring, the Quote Date formula SHALL evaluate to the empty string `""` (via `IFERROR`) — never a literal error token (e.g. `#N/A`) and never a partial value.

**Event-driven (settle-pass read-back)**
- WHEN the settle pass reads a Positions row whose Price cell (column 4) parses as numeric, the system SHALL also read that row's Quote Date cell (column 12), trim whitespace, and parse it as a signed 32-bit integer day count.
- WHEN that parse succeeds, the system SHALL set the produced mark's `quote_date` to `pt_core::Date(parsed_days)`.
- WHEN that cell is empty or fails to parse as an integer, the system SHALL default `quote_date` to `Date(0)` (1970-01-01) rather than erroring or rejecting the row.

**Unwanted behavior**
- An unparseable or empty Quote Date cell SHALL NOT affect the Price cell's own numeric/transient/permanent classification, and SHALL NOT cause the read-back to reject, retry, or degrade that symbol's price — Quote Date is only consulted, and only defaulted, after Price is already judged Numeric.

Sources: `sheets_view::quote_date_formula`/`render_positions` (lib.rs); `price_reading_from_cells` `QUOTE_DATE_COL=12` read-back (adapters.rs); `positions_carries_a_locale_proof_quote_date_companion_column` test (formula.rs), which pins `qcol==12`, formula substrings (`GOOGLEFINANCE`, `tradetime`, `DATE(1970,1,1)`, `TEXT(`, `IFERROR`), and resolved-ticker use.