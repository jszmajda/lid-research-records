**Ubiquitous**
- U1: The Positions tab SHALL carry a "Quote Date" companion column as the 13th column (index 12), the last column, present in every rendered data row, paired with "Price" at column index 4.
- U2: The Quote Date cell SHALL always be a live formula (never an engine value), built from the same alias-resolved ticker used for the Price formula.
- U3: The Quote Date formula SHALL be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`.
- U4: The encoded value SHALL be an integer day count re-based to days-since-1970-01-01 (matching the kernel's `pt_core::Date` epoch), derived by truncating (`INT`) the raw `tradetime` serial to a whole-day value and subtracting `DATE(1970,1,1)`.
- U5: The rendered cell text SHALL be digits-only (via `TEXT(…,"0")`), never a locale-formatted date/time string, so every locale parses it identically.

**Event-driven**
- E1: WHEN `GOOGLEFINANCE(ticker,"tradetime")` resolves to a numeric value, the formula SHALL emit the truncated, re-based day count as a plain digit string.
- E2: WHEN the settle pass reads a Positions row back, the adapter SHALL parse column index 12 as a trimmed `i32`; on successful parse, that value SHALL populate `PriceReading::Numeric.quote_date`.
- E3: WHEN the settle-pass Price reading for a row is `Numeric`, the parsed Quote Date value SHALL be attached to the produced `Mark.quote_date`.

**State-driven**
- S1: WHILE the companion Price cell's reading is `Transient` or `Permanent`, the system SHALL disregard the Quote Date column's content for that row — it contributes no value to the reading.

**Unwanted behavior**
- UB1: IF `GOOGLEFINANCE` is still loading or errors (any condition `IFERROR` catches), THEN the Quote Date cell SHALL render as the empty string `""` — never an error marker (`#N/A`, `#ERROR!`) and never raw error text.
- UB2: IF the settle-pass read of column 12 fails to parse as `i32` (empty, non-numeric, or the cell is absent/short), THEN the adapter SHALL default `quote_date` to `0` (epoch 1970-01-01) via `unwrap_or(0)` — silently, with no propagated error and no distinct degrade signal attributable to the date field itself.

No explicit tie-break beyond the defaulting rule (UB2); no other normalization, rounding, or boundary condition on this concern is pinned in these three files.