SHEET-MARK-QDATE — Quote-date companion column (Positions tab)

1. [Ubiquitous] The Positions view tab SHALL carry a `Quote Date` column as the last (13th) typed header column, at zero-based column index 12, on every rendered row (no ragged rows). Header text SHALL be exactly `"Quote Date"`.

2. [Ubiquitous] The `Quote Date` cell SHALL be a live formula cell (`Cell::Formula`), not an engine value, and SHALL be emitted for every position row.

3. [Event-driven] When the Positions tab is rendered for a symbol, the system SHALL emit the quote-date formula built from the SAME alias-resolved ticker used by that row's `Price` formula, exactly: `=IFERROR(TEXT(INT(GOOGLEFINANCE("<TICKER>","tradetime")),"0"),"")` — the `tradetime` attribute, truncated via `INT` to its integer date serial, rendered via `TEXT(…,"0")` as a digits-only string that every spreadsheet locale formats identically, wrapped in `IFERROR`.

4. [Unwanted behavior] If the `GOOGLEFINANCE` quote is loading or errored, the `Quote Date` cell SHALL render as the empty string, never a sheet error token.

5. [State-driven] While the settle pass reads the Positions data range back through the plain values API (formatted strings, from `DATA_START_ROW` = 2 down), the system SHALL take the quote date from column index 12 of the row and parse it as a base-10 `i32` day count into the kernel `Date`.

6. [Unwanted behavior] If the column-12 cell is absent, empty, or does not parse as an `i32` (after trimming surrounding whitespace), the system SHALL default the quote date to `Date(0)` rather than failing the reading; a row whose `Price` cell is numeric still yields `PriceReading::Numeric` with that defaulted quote date.

7. [Event-driven] When a numeric `Price` reading settles, the system SHALL stamp the produced `Mark` with that row's parsed quote date (`Mark.quote_date`), i.e. `GOOGLEFINANCE`'s own quote date, not wall-clock read time.

8. [Ubiquitous] The quote date SHALL be read only on the separate settle pass (never inline with the formula write), keyed by row identity (column 0 `Symbol`); rows with an empty column-0 symbol SHALL be skipped.

9. [Unwanted behavior] The quote date SHALL NOT be parsed for non-numeric `Price` cells: transient (`""`, `"Loading..."`, `"#N/A"`) and permanent (other `#`-prefixed or unparseable) readings carry no quote date, and a carried-forward prior mark retains its own prior quote date.