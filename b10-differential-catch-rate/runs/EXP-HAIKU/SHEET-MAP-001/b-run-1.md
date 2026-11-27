## EARS-Style Requirements: Symbol → Ticker Resolution for GOOGLEFINANCE

**SHEET-TICKER-NORM-001**: Resolve a ledger symbol to a GOOGLEFINANCE ticker via normalization and alias lookup. The lookup key is the symbol **trimmed of surrounding whitespace and converted to uppercase** before consulting the alias table, so a symbol carrying incidental whitespace or case variations on import still finds its alias instead of silently falling through to identity. Examples: "brk", "  BRK  ", "BRK" all resolve to "BRK.B" when aliased; unaliased symbols resolve to their normalized form (e.g., " amzn " → "AMZN").

**SHEET-TICKER-ALIAS-002**: The alias map's resolved value (or the normalized symbol if absent from the map) becomes the ticker parameter **quoted and injected into both the Price and Quote Date formulas**:
- Price formula: `=GOOGLEFINANCE("TICKER","price")`
- Quote Date formula (locale-proof re-encoding): `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime")-DATE(1970,1,1),"0"),"")`
The ticker string is the sole input parameter to GOOGLEFINANCE in both formulas.

**SHEET-TICKER-ROWKEY-003**: The Positions tab enforces **one row per symbol**. The mark read-back is keyed by symbol (row identity); the system errors loudly with `DuplicateSymbolRow(symbol)` if the invariant is violated (a defensive assertion, as the snapshot's `Map<Symbol,_>` structure guarantees uniqueness through the real API). This binding between symbol and row position ensures the settle pass can parse price cells back by row order and map them to the correct symbol.

**SHEET-QUOTE-DATE-ENCODING-004**: The Quote Date formula companion column uses the resolved ticker and encodes GOOGLEFINANCE's raw `tradetime` (a locale-dependent datetime) as a digits-only string for locale-proof parsing: truncate tradetime to a date serial, subtract `DATE(1970,1,1)` (the kernel Date epoch), and render via `TEXT(…,"0")`. Load/error renders as empty string (via IFERROR), never an error cell.