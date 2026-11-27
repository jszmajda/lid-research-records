SHEET-MARK-KEY — Mark read-back keying and duplicate-symbol handling

**SHEET-MARK-KEY-001 (ubiquitous).** The system shall key mark read-back rows by row identity — the `Symbol` value in the Positions tab's first column (`POSITIONS_HEADER[0] == "Symbol"`) — with exactly one Positions data row per symbol; data rows begin at the fixed anchored row `DATA_START_ROW = 2`, beneath the frozen header at row 1, and row *n*'s 1-based sheet row is `n + DATA_START_ROW`.

**SHEET-MARK-KEY-002 (ubiquitous).** Each Positions row's live-price cells shall be row-anchored to that row's own cells: `Price` = `=GOOGLEFINANCE("<ticker>","price")` (column E) and `Quote Date` = `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")` (column M), so the read-back of row *r* yields the mark for the symbol in `A<r>` and never another row's.

**SHEET-MARK-KEY-003 (ubiquitous).** The ticker embedded in a row's price/quote-date formulas shall be the alias-resolved ticker for that symbol (`AliasMap::resolve`), resolving to the symbol itself (identity) when unaliased; the raw symbol shall not appear as the quoted formula argument when an alias exists.

**SHEET-MARK-KEY-004 (unwanted behavior).** If, while rendering the Positions tab, a symbol is encountered that has already been rendered as a row in this tab, then the system shall abort rendering and return `ViewError::DuplicateSymbolRow(<symbol>)` — no partial tab and no second row for that symbol shall be produced. The error's `Display` rendering shall be its `Debug` form, exactly `DuplicateSymbolRow("AMZN")` for symbol `AMZN`.

**SHEET-MARK-KEY-005 (ubiquitous).** The duplicate-symbol check of SHEET-MARK-KEY-004 shall be a defensive assertion: because `Snapshot.positions` is keyed by `Symbol`, the invariant holds by construction and the error branch is unreachable through the real API. Rendering any valid snapshot shall yield rows whose symbols are all distinct (row count equals distinct-symbol count).

**SHEET-MARK-KEY-006 (ubiquitous).** The settle-pass read-back shall be driven by the caller-supplied symbol list and shall produce a per-symbol map (`PricePass`/`MarksProduced.marks`/`.degraded`, all `BTreeMap<Symbol, _>` — symbol-ordered, at most one entry per symbol); a repeated reading for a symbol within a poll shall overwrite, never accumulate, the latest reading for that key.

**SHEET-MARK-KEY-007 (state-driven).** While a symbol is absent from the read-back pass, the system shall treat it identically to a `Transient` reading for that symbol (carry the prior mark if one exists; otherwise degrade `TimedOut`).