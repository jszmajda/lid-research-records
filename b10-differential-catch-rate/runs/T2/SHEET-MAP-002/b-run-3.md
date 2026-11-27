**EARS reconstruction — mark read-back keying / duplicate-symbol handling (sheets-view)**

**Ubiquitous**
- U1: THE Positions-tab renderer SHALL emit exactly one row per ledger `Symbol`, keyed by that `Symbol`'s identity — the key the marks settle pass read-back correlates a settled `GOOGLEFINANCE` price back to its position row.
- U2: THE marks settle pass SHALL represent per-symbol data (`PricePass`, `MarksProduced.marks`, `MarksProduced.degraded`) as `Symbol`-keyed maps (`BTreeMap<Symbol, _>`), which structurally forbids more than one entry per symbol.
- U3: `read_marks` SHALL NOT itself validate uniqueness of its `symbols: &[Symbol]` input; it relies on the upstream invariant (established by `Snapshot.positions` being a `Map<Symbol,_>` and enforced by `render_positions`) that no symbol appears twice.

**Event-driven**
- E1: WHEN `render_positions` iterates `Snapshot.positions` and is about to emit a row for a symbol, THE system SHALL first check that symbol against the set of symbols already emitted this call; IF the symbol was already seen, THE system SHALL immediately return `Err(ViewError::DuplicateSymbolRow(symbol))` (carrying the offending symbol's exact value) instead of emitting the row.
- E2: WHEN no duplicate is detected for a symbol, THE system SHALL insert it into the seen-set and append its row, continuing to the next symbol.

**State-driven**
- S1: WHILE `Snapshot.positions` is backed by a `Map<Symbol,_>` (its actual runtime type), the one-row-per-symbol condition holds by construction, making the `DuplicateSymbolRow` branch structurally unreachable via the real API — the check exists as a defensive guard against a hypothetical future non-map data source, not as a reachable production path.

**Unwanted behavior**
- UB1: IF the duplicate-symbol invariant is ever violated, THEN `render_positions` SHALL NOT render both/all conflicting rows, SHALL NOT silently drop or last-write-win the duplicate, and SHALL NOT continue rendering remaining symbols — it fails the whole call immediately via `Err`.
- UB2: `ViewError::DuplicateSymbolRow`'s `Display` SHALL format via Rust `Debug` (`{self:?}`), producing exactly the string `DuplicateSymbolRow("<symbol>")` for a given symbol (pinned verbatim by test: `DuplicateSymbolRow("AMZN")`).

No symbol normalization (case-folding, trimming, alias resolution) is applied before the uniqueness check or the row key — comparison is on the raw `Symbol` string as stored in `Snapshot.positions`; ticker aliasing (`resolve_ticker`) is applied only for the formula text, not for row identity/keying.