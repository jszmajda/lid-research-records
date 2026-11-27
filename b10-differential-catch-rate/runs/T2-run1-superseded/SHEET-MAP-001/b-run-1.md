**Ubiquitous requirements**

- The system shall resolve a ledger `Symbol` to its `GOOGLEFINANCE` ticker exclusively through the configured alias map (`AliasMap::resolve`); `resolve_ticker(aliases, symbol)` is a pure pass-through with no additional logic of its own.
- The system shall build the Price cell as the exact formula `=GOOGLEFINANCE("<ticker>","price")`, where `<ticker>` is the *resolved* ticker (never the raw ledger symbol) and is wrapped in double quotes.
- The system shall build the companion Quote Date cell as the exact formula `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, using the **same** resolved ticker as the Price cell for that row.
- Both the Price and Quote Date cells shall be rendered as `Cell::Formula`, never `Cell::Value`.

**Event-driven requirements**

- When a symbol has a configured alias, the system shall resolve it to the aliased ticker string (e.g., `"BRK"` → `"BRK.B"`, `"AAPL"` → `"NASDAQ:AAPL"`) and use that resolved form — not the raw symbol — in both the Price and Quote Date formulas.
- When a symbol has no configured alias, the system shall resolve it to itself (identity mapping) as the ticker (e.g., `"AMZN"` → `"AMZN"`).
- When rendering the Positions tab, for each `(symbol, position)` pair the system shall resolve the ticker once and reuse it for both formulas on that row.

**State-driven requirement**

- While rendering the Positions tab, the system shall maintain one row per distinct symbol, keyed by symbol identity, since the marks read-back keys on row identity (symbol).

**Unwanted-behavior requirement**

- If `render_positions` encounters a second row for a symbol already seen in the current render pass (violating the one-row-per-symbol invariant the read-back depends on), then the system shall not render it silently; it shall return `Err(ViewError::DuplicateSymbolRow(symbol))` immediately, aborting the render. (Structurally unreachable via the real `Snapshot.positions: Map<Symbol,_>` API — a defensive/loud-error guard for a future non-Map source, not a reachable runtime path today.)

**Constants pinned**

- Ticker is quoted with `\"` in both formulas.
- Quote Date attribute is `"tradetime"`; Price attribute is `"price"`.
- Quote Date epoch re-base is `DATE(1970,1,1)`, rendered via `TEXT(...,"0")`.
- No case normalization, whitespace trimming, or symbol-format validation is performed on either the input symbol or the resolved ticker before formula construction.