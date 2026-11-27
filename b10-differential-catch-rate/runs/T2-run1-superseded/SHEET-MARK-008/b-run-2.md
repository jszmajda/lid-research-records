## Reconstructed EARS Requirements — Quote Date companion column (trade-date encoding)

**Ubiquitous**

1. The Positions view shall render a `Quote Date` column as the 13th header column (0-based index 12), a live formula parallel to `Price`, for every position row.

2. The `Quote Date` formula shall be exactly:
`=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`
— using the same alias-resolved ticker as that row's `Price` formula (never the raw symbol).

3. The formula shall truncate `GOOGLEFINANCE`'s `tradetime` value to its date serial via `INT(...)`, discarding time-of-day, before re-basing.

4. The formula shall re-base the truncated serial to days-since-1970-01-01 — the kernel `Date` epoch — by subtracting `DATE(1970,1,1)`.

5. The formula shall render the re-based integer via `TEXT(...,"0")`, producing a digits-only string with no thousands separator/decimal, identical across spreadsheet locales.

6. The settle-pass reader shall treat data-row column index 12 (0-based) as the quote-date companion to `Price` at column index 4, in the Positions tab's fixed column layout.

**Event-driven**

7. WHEN `GOOGLEFINANCE`'s `tradetime` read errors or is still loading, the `Quote Date` formula shall evaluate to the empty string `""` (via `IFERROR`'s fallback), never an error literal such as `#N/A`.

8. WHEN a Positions row's `Price` cell parses as a finite `f64` AND that row's column-12 cell parses as an integer, the settle pass shall use that integer as the `quote_date` (days-since-epoch) of the resulting `PriceReading::Numeric`.

**Unwanted behavior**

9. IF a row's `Price` cell parses as numeric but the column-12 `Quote Date` cell is absent, empty, or fails to parse as an integer, THEN the settle pass shall NOT fail or reject the row — it shall default `quote_date` to `0` (1970-01-01 by the re-based epoch) and still emit `PriceReading::Numeric`.

10. IF the `Price` cell itself is not numeric (empty, `Loading...`, `#N/A`, or any other leading-`#` error), THEN the `Quote Date` cell (column 12) is not consulted at all for that row's reading.

Tests additionally pin: `qcol == 12` exactly; the formula text must contain `GOOGLEFINANCE`, `tradetime`, `DATE(1970,1,1)`, `TEXT(`, and `IFERROR`; and the aliased ticker (e.g. `NASDAQ:AMZN`) appears verbatim in the formula, not the bare symbol.