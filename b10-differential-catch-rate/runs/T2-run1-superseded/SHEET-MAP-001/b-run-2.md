**Concern: ledger Symbol → GOOGLEFINANCE ticker resolution (`resolve_ticker`, `price_formula`, `quote_date_formula`, and their use in `render_positions`)**

1. **Ubiquitous.** The system shall resolve a ledger `Symbol` to its GOOGLEFINANCE ticker by looking it up in the configured `AliasMap` (`resolve_ticker(aliases, symbol) = aliases.resolve(symbol)`). No other transformation (case-folding, trimming, etc.) is applied — `resolve_ticker` is a direct passthrough.

2. **Ubiquitous.** If the symbol has no alias entry, the resolved ticker shall equal the symbol itself (identity fallback) — pinned by test (`resolve_ticker(&aliases, "AMZN") == "AMZN"` with no alias registered).

3. **Event-driven.** When rendering a Positions row for a symbol, the system shall resolve that symbol's ticker exactly once per row and use the *resolved* ticker — never the raw ledger symbol — to build both that row's `Price` and `Quote Date` formulas. Test asserts the Price formula for symbol `"BRK"` (aliased to `"BRK.B"`) contains `"BRK.B"` and explicitly does NOT contain `"\"BRK\""` (the raw symbol quoted).

4. **Ubiquitous.** The `Price` formula for a resolved ticker shall be exactly `=GOOGLEFINANCE("<ticker>","price")`, ticker double-quoted, ticker embedded as a literal (not a cell reference), so the formula never depends on column A holding the raw symbol.

5. **Ubiquitous.** The `Quote Date` companion formula for the same resolved ticker shall be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`: truncate trade time to its date serial via `INT`, re-base to days-since-1970-01-01 by subtracting `DATE(1970,1,1)`, render as a digits-only string via `TEXT(…,"0")`, and wrap in `IFERROR` so a loading/errored quote renders as `""`, never an error string.

6. **State-driven.** While a Positions row is being rendered for a symbol, the `Price` and `Quote Date` formulas on that row shall reference the identical resolved ticker (both derived from one `resolve_ticker` call per row).

7. **Unwanted-behavior.** If `Snapshot.positions` ever yields more than one row for the same `Symbol` (violating the one-row-per-symbol invariant the mark read-back keys on), `render_positions` shall not render duplicate rows; it shall return `Err(ViewError::DuplicateSymbolRow(symbol))` instead, whose `Display` renders as `DuplicateSymbolRow("<symbol>")`. Test notes this path is structurally unreachable via the real `Map<Symbol,_>`-backed API but is still asserted as a defensive contract.

Sources: `crates/sheets-view/src/lib.rs` (`resolve_ticker`, `price_formula`, `quote_date_formula`, `render_positions`, `ViewError::DuplicateSymbolRow`); `tests/mapping.rs` (all four tests); `tests/formula.rs` (`positions_carries_a_locale_proof_quote_date_companion_column`).