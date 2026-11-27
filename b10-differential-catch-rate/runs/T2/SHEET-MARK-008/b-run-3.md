**Ubiquitous:**
- The system shall render the Positions tab's "Quote Date" column (fixed header/column index 12, immediately after "Realized P&L") as a live formula cell for every position row: `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, where `<ticker>` is the same alias-resolved ticker used by the row's Price formula.
- The system shall encode the quote date as an integer count of days since 1970-01-01 (the kernel `Date` epoch): truncate GOOGLEFINANCE's `tradetime` to its date serial via `INT(...)`, then rebase by subtracting `DATE(1970,1,1)`.
- The system shall render that day-count via `TEXT(...,"0")` — a digits-only, locale-invariant string — rather than emitting GOOGLEFINANCE's raw `tradetime`, which is a locale-dependent datetime not reliably parseable back.

**Event-driven / unwanted-behavior:**
- WHEN the underlying GOOGLEFINANCE tradetime is loading or erroring, the Quote Date formula (via `IFERROR`) shall evaluate to the empty string `""`, never to an error-marker string.
- The system shall NOT render the Quote Date column as an engine-written value; it is always a `Cell::Formula`, even though it is a companion to other engine values on the row.

**State-driven (read-back / settle pass):**
- WHILE reading back a settle-pass row where the companion Price cell (column 4) parses as a numeric reading, the system shall read the Quote Date cell (fixed column index 12) and parse it as a signed 32-bit integer (days since 1970-01-01).
- IF the Quote Date cell at column 12 is absent or fails to parse as an i32 (e.g., still empty from a pending formula) THEN the system shall default the parsed quote date to `0` (i.e., the 1970-01-01 epoch day) rather than erroring or propagating a parse failure.
- The quote-date read-back is only attempted when the Price reading is `Numeric`; Transient/Permanent price readings do not read or interpret the Quote Date cell at all.

**Ubiquitous (constants pinned by tests):**
- Column index for "Quote Date" is fixed at 12 in the Positions header/row layout.
- The formula text must contain, verbatim/functionally: `GOOGLEFINANCE`, the `"tradetime"` attribute, `DATE(1970,1,1)` as the rebase subtrahend, a `TEXT(` wrapper, and an `IFERROR` wrapper.
- The formula must reference the alias-resolved ticker (e.g., `AMZN` → `NASDAQ:AMZN`), identical to the Price formula's ticker resolution — no independent/unresolved symbol is ever used.