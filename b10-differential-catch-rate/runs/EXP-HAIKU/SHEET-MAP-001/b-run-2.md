Based on reading the three files, here are the EARS-style requirements that the code enforces for symbol-to-ticker resolution:

---

## Symbol → Ticker Resolution (SHEET-SYMBOL-RESOLVE)

**[x] SHEET-SYMBOL-RESOLVE-001 — Normalize symbol before alias lookup**
Ubiquitous: Every ledger symbol is normalized to uppercase and trimmed of surrounding whitespace before alias-table lookup. Symbols with incidental case variation or whitespace (e.g., `"brk"`, `" BRK "`) find their alias entry despite the variation. Normalization applies regardless of alias presence.

**[x] SHEET-SYMBOL-RESOLVE-002 — Alias map overrides raw symbol**
State-driven: If the normalized symbol exists in the `AliasMap`, the mapped value (the GOOGLEFINANCE ticker form) is resolved. Example: normalized `"BRK"` with entry `{"BRK": "BRK.B"}` resolves to `"BRK.B"`.

**[x] SHEET-SYMBOL-RESOLVE-003 — Identity fallback for unaliased symbols**
Ubiquitous: If the normalized symbol is not in the alias map, the normalized uppercase symbol itself is the resolved ticker. Example: unaliased `" amzn "` normalizes to `"AMZN"` and resolves to `"AMZN"` (identity).

**[x] SHEET-SYMBOL-RESOLVE-004 — Resolved ticker is the GOOGLEFINANCE formula argument**
Ubiquitous: The price formula `=GOOGLEFINANCE("TICKER","price")` uses the resolved ticker, not the raw symbol. Quote-escaping is applied during formula assembly. Formulas built from aliased and identity symbols both use their resolved forms.

**[x] SHEET-SYMBOL-RESOLVE-005 — Quote date formula rides the resolved ticker**
Ubiquitous: The companion `Quote Date` formula reads `GOOGLEFINANCE`'s tradetime for the same resolved ticker, rebase the date serial to days since 1970-01-01 via `INT(…) - DATE(1970,1,1)`, and renders digits-only via `TEXT(…,"0")` for locale-proof parsing on settle-back. Empty on load/error via `IFERROR`.

**[x] SHEET-SYMBOL-RESOLVE-006 — One row per symbol; duplicate symbols error loudly**
Unwanted-behavior: Positions tab rendering asserts one row per distinct symbol. If a symbol appears twice in the rendered output, `Err(ViewError::DuplicateSymbolRow(symbol))` halts render immediately. (This guard is defensive — `Snapshot.positions` is a `Map<Symbol,_>`, so the invariant is structurally unreachable through the real API but guards against future non-Map sources.)

**[x] SHEET-SYMBOL-RESOLVE-007 — Read-back keyed by row identity (symbol)**
State-driven: Mark settle-pass reads the Positions tab by row order, keying each price reading to the symbol in column A (row identity). One row per symbol is the prerequisite; the design assumes row count and symbol count match.

---

**400 words (fits under limit)**