SHEET-MARK-QDATE — Quote-date companion column (locale-proof trade-date encoding)

**SHEET-MARK-QDATE-001 (ubiquitous).** The Positions view tab shall carry a `Quote Date` companion column as the last typed header column, at zero-based column index 12 (spreadsheet column M), present on every rendered data row so no row is ragged.

**SHEET-MARK-QDATE-002 (ubiquitous).** Every `Quote Date` cell shall be a live formula cell (`Cell::Formula`), not an engine value, of the exact form `=IFERROR(TEXT(INT(GOOGLEFINANCE("<TICKER>","tradetime")),"0"),"")`, where `<TICKER>` is the symbol resolved through the `config` alias map (the same resolved ticker used by the row's `Price` formula in column E), double-quoted inside the formula.

**SHEET-MARK-QDATE-003 (ubiquitous).** The encoding shall be: `GOOGLEFINANCE`'s `tradetime` attribute (the quote's own trade date, not wall-clock read time), truncated to its whole-day date serial by `INT`, rendered by `TEXT(…,"0")` as a digits-only string that every spreadsheet locale formats identically, because the settle pass reads the tab back through the plain values API as formatted strings.

**SHEET-MARK-QDATE-004 (unwanted behavior).** If the `GOOGLEFINANCE` `tradetime` lookup is loading or errored, then the `Quote Date` cell shall render the empty string via `IFERROR`, never a sheet error token.

**SHEET-MARK-QDATE-005 (event-driven).** When the settle pass reads a Positions data row back, the system shall take the quote date from column index 12 of that row, trim surrounding whitespace, and parse it as a signed 32-bit integer day count into `pt_core::Date`; the resulting `Date` stamps the symbol's `Mark.quote_date`.

**SHEET-MARK-QDATE-006 (unwanted behavior).** If the quote-date cell is absent from the row, empty, or not parseable as an `i32`, then the system shall default the quote date to `Date(0)` — the numeric price reading is still accepted as a `Numeric` reading; a missing quote date shall not degrade or reject the mark.

**SHEET-MARK-QDATE-007 (state-driven).** While a row's `Price` cell (column index 4) is non-numeric — empty, `Loading...` (ASCII-case-insensitive), `#N/A`, or any `#`-prefixed error — the quote-date cell shall not be read or interpreted; the reading is `Transient` (empty / `Loading...` / `#N/A`) or `Permanent` (other `#`-prefixed or unparseable), and carries no quote date.

**SHEET-MARK-QDATE-008 (ubiquitous).** The quote date obtained this way shall be the per-symbol quote-epoch stamp carried on `Mark` and persisted with History points (`marks: symbol → (price_cents, quote_epoch)`), and shall be carried forward unchanged with a prior mark when a symbol is only transiently unknown.