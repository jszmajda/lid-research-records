**Symbol → Ticker Mapping (SHEET-TICKER)**

1. **Ubiquitous.** THE `resolve_ticker` function SHALL resolve a ledger `Symbol` to its `GOOGLEFINANCE` ticker via the configured `AliasMap`: WHERE an alias mapping exists for the symbol, it SHALL return the mapped ticker string exactly as configured (e.g. `"BRK"` → `"BRK.B"`, `"AAPL"` → `"NASDAQ:AAPL"`); WHERE no mapping exists for the symbol, it SHALL return the symbol unchanged (identity fallback, e.g. `"AMZN"` → `"AMZN"`).

2. **Ubiquitous.** THE system SHALL build the Positions `Price` cell as the literal formula string `=GOOGLEFINANCE("<ticker>","price")`, where `<ticker>` is the value returned by `resolve_ticker` — double-quoted inside the formula — and NEVER the raw, unresolved ledger symbol when the two differ (an aliased symbol's Price formula must contain the resolved ticker text and must NOT contain the raw symbol as a quoted literal).

3. **Ubiquitous.** THE system SHALL build the `Quote Date` companion cell as `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, using the identical `<ticker>` text as that row's `Price` formula (same resolved ticker, not independently re-resolved) — truncating trade-time to a date serial, re-based to days since 1970-01-01, rendered as a digits-only string; the `IFERROR` wrapper yields an empty string (never an error literal) while the quote is loading or errored.

4. **Event-driven.** WHEN `render_positions` renders a row for a `(symbol, position)` pair, THE system SHALL resolve the ticker exactly once per row and reuse that single resolved value for both the `Price` and `Quote Date` formulas on that row.

5. **State-driven.** WHILE rendering the Positions tab, THE system SHALL emit at most one row per distinct `Symbol`, keyed by symbol identity (the row identity the marks read-back keys on).

6. **Unwanted-behavior.** IF the input snapshot's positions carry two rows for the same `Symbol` (a violated one-row-per-symbol invariant — defensive, since `Snapshot.positions: Map<Symbol,_>` makes this structurally unreachable via the real API), THEN `render_positions` SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` instead of silently rendering both rows or overwriting one. `ViewError`'s `Display` SHALL render via its derived `Debug` form, e.g. `DuplicateSymbolRow("AMZN")`.

No other normalization (case-folding, whitespace-trimming, exchange-prefix rewriting) or tie-break rule for the symbol/ticker mapping is exercised by this code or its tests.