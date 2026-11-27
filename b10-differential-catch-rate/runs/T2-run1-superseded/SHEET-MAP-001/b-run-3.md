## EARS-style requirements — Symbol → GOOGLEFINANCE ticker resolution

**Ubiquitous**
- U1: The system shall resolve a ledger `Symbol` to its `GOOGLEFINANCE` ticker by delegating to the configured `AliasMap`'s resolution (`resolve_ticker(aliases, symbol) == aliases.resolve(symbol)`).
- U2: When a symbol has no configured alias entry, resolution shall yield the symbol string itself unchanged (identity fallback) — never an error, never an empty string.

**Event-driven**
- E1: When constructing a position row's `Price` cell, the system shall build the formula `=GOOGLEFINANCE("<ticker>","price")` where `<ticker>` is the ALIAS-RESOLVED ticker, double-quoted inside the formula. The raw/unresolved ledger symbol shall never appear as the formula's ticker argument when an alias exists — only the resolved form is used (pinned by test: with `BRK`→`BRK.B` aliased, the Price formula text must contain `BRK.B` and must NOT contain the literal `"BRK"`).
- E2: When constructing a position row's `Quote Date` companion cell, the system shall build `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, using the identical resolved ticker used for that same row's `Price` formula (pinned by test: an `AMZN`→`NASDAQ:AMZN` aliased row's Quote Date formula text contains `NASDAQ:AMZN`). The attribute name is literally `"tradetime"`, re-based by subtracting `DATE(1970,1,1)` (the kernel `Date` epoch, day 0 = 1970-01-01), rendered via `TEXT(…,"0")` for a locale-invariant digits-only string, and the whole expression is wrapped in `IFERROR(...,"")` so a loading/errored quote renders as an empty string, never an error string.
- E3: `Price` and `Quote Date` formulas for a given row shall each be built from that row's own resolved ticker — no cross-row ticker leakage.

**State-driven**
- S1: While `Snapshot.positions` holds at most one entry per symbol, `render_positions` shall emit exactly one output row per symbol, with the `Symbol` column value used as the read-back join key for the marks settle pass.

**Unwanted behavior**
- UB1: If two rendered rows ever carry the same symbol (the one-row-per-symbol invariant is violated — structurally unreachable through the real `Map<Symbol,_>`-typed `Snapshot` API, kept as a defensive guard), `render_positions` shall immediately return `Err(ViewError::DuplicateSymbolRow(symbol))` rather than rendering both rows or silently overwriting one.
- UB2: `ViewError::DuplicateSymbolRow(symbol)`'s `Display` output shall equal its `Debug` output, e.g. `DuplicateSymbolRow("AMZN")`.

No case-folding/whitespace normalization of the symbol or ticker is present or tested; resolution is a bare map lookup with identity fallback.