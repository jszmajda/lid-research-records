**EARS requirements — Positions "Quote Date" companion column (trade-date encoding)**

**Ubiquitous**
1. The Positions view tab SHALL carry a "Quote Date" column at fixed index 12 (13th column, letter M), the companion to the "Price" column at fixed index 4 (letter E).
2. The Quote Date cell SHALL always be a live `Cell::Formula` (never an engine `Cell::Value`).
3. The Quote Date formula SHALL resolve its ticker via the same alias-resolved ticker used by that row's Price formula (`resolve_ticker`), never a raw/unaliased symbol.

**Event-driven**
4. WHEN rendering a Positions row for a symbol, the system SHALL emit the Quote Date formula as exactly:
   `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`
5. The formula SHALL truncate `GOOGLEFINANCE(...,"tradetime")` to its date serial via `INT(...)`, then re-base it to days-since-1970-01-01 by subtracting `DATE(1970,1,1)` — matching the kernel `Date` epoch exactly (no other epoch/offset).
6. The result SHALL be rendered as a digits-only string via `TEXT(...,"0")` so every sheet locale parses it identically (never the raw locale-dependent `tradetime` datetime).

**Unwanted behavior**
7. IF `GOOGLEFINANCE(...,"tradetime")` is loading or errors, THEN the Quote Date formula SHALL evaluate (via the wrapping `IFERROR`) to the empty string `""` — never an error literal (e.g. `#N/A`, `#ERROR!`) and never a stale/placeholder date.

**State-driven (settle-pass read-back, in the adapter)**
8. WHILE parsing a Positions data row on the settle-pass read-back, the system SHALL read the Quote Date companion from the fixed grid column index 12, independent of the Price cell at index 4.
9. WHEN that cell's trimmed text parses as a valid `i32`, the produced `PriceReading::Numeric.quote_date` SHALL be `pt_core::Date` of that integer (days-since-1970-01-01), unmodified.
10. IF the Quote Date cell is absent (row shorter than 13 columns) or fails to parse as `i32` (e.g. still `""` because the formula errored or is loading), THEN the read-back SHALL default `quote_date` to `Date(0)` (1970-01-01) rather than failing the row or propagating an error.
11. The Quote Date cell's parseability SHALL NOT gate whether the row's price reading is classified Transient/Permanent/Numeric — that classification depends solely on the Price cell (col 4); a bad/missing Quote Date only affects the stamped date on an otherwise-Numeric reading.