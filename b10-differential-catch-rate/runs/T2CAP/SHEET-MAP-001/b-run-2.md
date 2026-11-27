**SHEET-TICK-001 (ubiquitous).** The `sheets-view` crate shall resolve every ledger `Symbol` to a GOOGLEFINANCE ticker by normalizing the symbol — trimming leading and trailing whitespace, then upper-casing — and using the normalized string as the lookup key into `config`'s `AliasMap`.

**SHEET-TICK-002 (ubiquitous).** Where the normalized symbol has an entry in the alias map, the resolved ticker shall be that entry's value, used verbatim (including exchange-qualified forms `NASDAQ:AAPL` and dotted class forms `BRK.B`); the alias value is not itself normalized.

**SHEET-TICK-003 (ubiquitous).** Where the normalized symbol has no alias entry, the resolved ticker shall be the normalized symbol itself (identity fallback) — i.e. trimmed and upper-cased, not the raw input (`" amzn "` → `"AMZN"`).

**SHEET-TICK-004 (ubiquitous).** The Positions tab's `Price` cell (column E, index 4) shall be the live formula `=GOOGLEFINANCE("<ticker>","price")`, where `<ticker>` is the resolved ticker enclosed in double quotes, and shall never be an engine value.

**SHEET-TICK-005 (ubiquitous).** The Positions tab's `Quote Date` cell (column M, index 12) shall be the live formula `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, built from the **same** resolved ticker as that row's `Price` cell — truncating trade time to a date serial, re-basing to days since 1970-01-01, rendering digits-only via `TEXT(…,"0")`, and yielding the empty string while loading or errored (never an error string).

**SHEET-TICK-006 (unwanted behavior).** The rendered `Price` formula shall not contain the raw pre-resolution symbol as its quoted ticker argument when an alias exists (e.g. never `"BRK"` where `BRK → BRK.B` is aliased).

**SHEET-TICK-007 (unwanted behavior).** If `Snapshot.positions` yields more than one row for the same `Symbol`, `render_positions` shall abort and return `ViewError::DuplicateSymbolRow(symbol)` rather than emit two ticker rows — the symbol being the row-identity key the marks read-back joins on. The error's `Display` renders as `DuplicateSymbolRow("AMZN")`. (Defensive: unreachable through the `Map<Symbol,_>`-backed API.)

**SHEET-TICK-008 (ubiquitous).** Ticker resolution shall be a pure per-row function of the alias map and the symbol; it shall perform no validation of ticker well-formedness. A ticker GOOGLEFINANCE cannot price surfaces only downstream, as a terminal non-numeric `Price` reading classified `DegradeReason::Permanent` on the settle pass (no mark, no prior carry-forward).