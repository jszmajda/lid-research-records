**SHEET-MARK-TICKER Resolution & Formula Binding:**

1. **Normalization (ubiquitous)**: A ledger symbol's ticker is resolved via `resolve_ticker(aliases, symbol)` by first normalizing the symbol: trim surrounding whitespace and uppercase. This normalization applies regardless of whether an alias is found or the identity fallback is used.

2. **Alias Lookup (state-driven)**: The normalized symbol is queried against the `AliasMap`. If an entry exists, the alias value (the canonical GOOGLEFINANCE ticker form, e.g., `"BRK.B"`, `"NASDAQ:AAPL"`) becomes the ticker. If absent, the normalized symbol itself becomes the ticker (identity).

3. **Price Formula Binding (event-driven)**: The resolved ticker is built into the `Price` cell as `=GOOGLEFINANCE("TICKER","price")`, with the ticker quoted and embedded in the formula string. The Positions tab renders one row per symbol; that row's `Price` formula uses its own resolved ticker, and no other.

4. **Quote Date Companion (event-driven)**: A locale-proof companion column (column M, "Quote Date") renders the same resolved ticker in the formula `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")`, using GOOGLEFINANCE's "tradetime" attribute, truncated and re-based to days since 1970-01-01 as a digits-only string via `TEXT(…,"0")` for locale-proof readability. An unresolved/errored price leaves this cell empty (IFERROR fallback).

5. **Row Identity Invariant (unwanted-behavior)**: The Positions tab maintains one row per symbol (keyed by symbol). Rendering asserts this invariant and errors loud (`Err(ViewError::DuplicateSymbolRow(symbol))`) if a snapshot violates it—a defensive gate against future non-Map sources.

6. **Read-Back Keyed by Symbol (state-driven)**: On a settle pass, price readings are keyed by symbol and the read-back row is identified by its symbol cell (column A), not row number. One-per-symbol structure ensures unambiguous read-back assignment of marks to rows.