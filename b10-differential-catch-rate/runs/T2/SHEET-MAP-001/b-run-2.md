**Symbol → Ticker Resolution (sheets-view)**

**Ubiquitous:**
- The system shall resolve a ledger `Symbol` to its GOOGLEFINANCE ticker by delegating unconditionally to the configured `AliasMap`: `resolve_ticker(aliases, symbol) == aliases.resolve(symbol)` — a pure passthrough, no additional transformation.
- The Positions header shall place the "Quote Date" column at index 12 (0-based, the 13th column), immediately after "Realized P&L".

**State-driven:**
- While a symbol has a matching alias-map entry, resolution shall yield that mapped ticker string exactly (e.g., `"BRK"` → `"BRK.B"`, `"AAPL"` → `"NASDAQ:AAPL"`), including any embedded exchange-prefix/suffix — no further normalization.
- While a symbol has no alias-map entry, resolution shall fall back to the symbol string itself, unchanged (identity fallback) — e.g., `"AMZN"` → `"AMZN"`.

**Event-driven:**
- When rendering a Positions row for a symbol, the system shall build the `Price` cell as `Cell::Formula` with text `=GOOGLEFINANCE("<resolved-ticker>","price")`, using the RESOLVED ticker (double-quoted) as the argument — never the raw ledger symbol. (Pinned by test asserting the formula contains the resolved ticker and does NOT contain the raw symbol quoted, e.g. `"BRK"` must be absent when resolved is `BRK.B`.)
- When rendering the same row, the system shall build the "Quote Date" companion cell as `Cell::Formula` with text `=IFERROR(TEXT(INT(GOOGLEFINANCE("<resolved-ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, using the identical resolved ticker used for `Price` on that row. Fixed constants: epoch `DATE(1970,1,1)`, digit format `"0"` (locale-invariant), `INT(...)` truncates tradetime to the date serial before re-basing.
- When the wrapped `GOOGLEFINANCE(...,"tradetime")` is loading or erroring, `IFERROR` shall render the empty string `""`, never an error token — so read-back never mis-parses an error as a date.

**Unwanted behavior:**
- IF `Snapshot.positions` ever yields two rows for the same symbol (violating the one-row-per-symbol invariant the settle-pass read-back keys on), THEN `render_positions` shall abort rendering and return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than emit both rows. `Display` for this error renders exactly `DuplicateSymbolRow("<symbol>")` (derived `Debug`, `Display` = `{self:?}`). Tests note this branch is structurally unreachable via the real `Map<Symbol,_>`-backed API but is pinned as a defensive/loud-failure contract.

Both `Price` and `Quote Date` cells are typed `Cell::Formula` (`is_formula() == true`), never `Cell::Value`, distinguishing them from engine-written cells in the same row.