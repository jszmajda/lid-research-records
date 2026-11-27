SHEET-MARK-KEY-001 (ubiquitous) — The Positions view tab SHALL be rendered with exactly one row per position symbol, the symbol string in column A ("Symbol", index 0 of POSITIONS_HEADER), written as an engine value; symbol row identity SHALL be the sole key by which the marks read-back associates a `Price` cell reading with a symbol.

SHEET-MARK-KEY-002 (ubiquitous) — Data rows SHALL be written from the fixed anchored start row `DATA_START_ROW = 2` beneath a frozen header at row 1; the row-anchored formulas of row N SHALL reference only that row's own cells (row number = row index + DATA_START_ROW), so each symbol's `Price` (col E) and `Quote Date` (col M) cells are unambiguously that row's.

SHEET-MARK-KEY-003 (unwanted behavior) — IF, while rendering Positions, a symbol is encountered that has already been rendered in an earlier row, THEN `render_positions` SHALL render no tab and SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` carrying the offending symbol, rather than emitting two rows for one symbol.

SHEET-MARK-KEY-004 (ubiquitous) — The duplicate-symbol check SHALL be a defensive assertion: since `Snapshot.positions` is a map keyed by `Symbol`, the duplicate branch is unreachable through the real API, and rendering a multi-symbol snapshot SHALL succeed with every rendered row carrying a distinct symbol (count of distinct symbols == row count).

SHEET-MARK-KEY-005 (ubiquitous) — `ViewError` SHALL implement `Display` and `std::error::Error`; the `Display` rendering SHALL be the `Debug` form, so `ViewError::DuplicateSymbolRow("AMZN")` displays exactly as `DuplicateSymbolRow("AMZN")` (loud, symbol-identifying).

SHEET-MARK-KEY-006 (ubiquitous) — Mark read-back SHALL key by ledger `Symbol`, not by resolved ticker: `PricePass` and the produced `marks`/`degraded` maps SHALL be `BTreeMap<Symbol, _>` (deterministic symbol order, at most one entry per symbol). The `Price`/`Quote Date` formulas SHALL be built from the alias-resolved ticker (`AliasMap::resolve`, identity when unaliased), while the row and the read-back entry remain keyed by the raw symbol.

SHEET-MARK-KEY-007 (event-driven) — WHEN `read_marks` runs a settle pass, it SHALL iterate the caller-supplied `symbols` list and, per poll, record only the latest reading for each requested symbol (`latest.insert` overwrites), producing exactly one outcome (mark, carried-forward prior mark, or degrade entry) per requested symbol; symbols present in the read pass but not in `symbols` SHALL be ignored.

SHEET-MARK-KEY-008 (state-driven) — WHILE a requested symbol has no entry in the read pass (absent), it SHALL be treated identically to a `Transient` reading: prior mark carried forward if present, otherwise degraded `TimedOut`; absence SHALL never settle the poll loop.