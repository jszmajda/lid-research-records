**Concern: ledger Symbol → GOOGLEFINANCE ticker resolution (lib.rs `resolve_ticker`, `price_formula`, `quote_date_formula`; pinned by mapping.rs, formula.rs)**

1. **(Ubiquitous)** The system shall resolve a ledger `Symbol` to its `GOOGLEFINANCE` ticker by looking it up in the configured `AliasMap` (`resolve_ticker(aliases, symbol) = aliases.resolve(symbol)`).

2. **(Ubiquitous — normalization/fallback)** When a symbol has no entry in the `AliasMap`, the resolved ticker shall equal the symbol string unchanged (identity fallback) — never an error and never a blank/placeholder value.

3. **(Event-driven)** When rendering a position row's `Price` cell, the system shall emit the cell as the live formula, using that row's resolved ticker, quoted, in exactly this form: `=GOOGLEFINANCE("<ticker>","price")`.

4. **(Event-driven)** When rendering a position row's `Quote Date` companion cell, the system shall use the identical resolved ticker used for that row's `Price` cell (one resolution per symbol/row, shared across both formulas), producing exactly: `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`.

5. **(Unwanted behavior)** If a symbol has an alias mapping, the rendered `Price` and `Quote Date` formulas shall NOT contain the raw, unaliased symbol text — only the resolved ticker may appear (explicitly pinned: `assert!(!price.contains("\"BRK\""))`).

6. **(State-driven / unwanted behavior — row-identity invariant)** While rendering the Positions tab, each symbol shall produce at most one row, since ticker resolution and the marks read-back are keyed by symbol identity (one row per symbol). If this invariant is ever violated (structurally unreachable via the real `Map<Symbol,_>` input, but guarded defensively), `render_positions` shall return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than silently rendering a duplicate or overwriting a row; `ViewError`'s `Display` renders this variant as `DuplicateSymbolRow("<symbol>")`.

Not enforced by this code (out of scope for these three files): no normalization/case-folding of the symbol or ticker beyond the alias lookup itself; no escaping behavior is tested for tickers containing `"` or other formula-breaking characters; no validation that a resolved ticker is a well-formed `GOOGLEFINANCE` ticker string.