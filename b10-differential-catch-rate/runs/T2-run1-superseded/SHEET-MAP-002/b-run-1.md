**Reconstructed EARS requirements — Positions row keying & duplicate-symbol handling (sheets-view)**

**SHEET-POS-KEY-1 (Ubiquitous)**
The Positions view tab shall render exactly one row per distinct `Symbol` in `Snapshot.positions`, with the `Symbol` value in column A ("Symbol"); this per-row symbol is the row-identity key the marks settle pass (`read_marks`/`read_price_pass`) reads back against.

**SHEET-POS-KEY-2 (Unwanted Behavior)**
While rendering the Positions tab, if a `Symbol` already recorded for a row in the current render is encountered again for another row, `render_positions` shall NOT emit the duplicate row and shall NOT return the partially-built tab; it shall immediately return `Err(ViewError::DuplicateSymbolRow(symbol))` carrying the offending symbol, discarding rows already accumulated in that call.

**SHEET-POS-KEY-3 (State-driven / defensive invariant)**
Because `Snapshot.positions` is a `Map<Symbol, _>`, symbol uniqueness holds by construction and the `DuplicateSymbolRow` branch is structurally unreachable via the real API. The guard shall remain in code regardless (defensive assertion) so that a future non-`Map` position source cannot silently double-render a symbol and corrupt the read-back key; happy-path tests must confirm one-row-per-symbol via the real API (not a fabricated duplicate), and the guard's existence/error-text must be verified separately.

**SHEET-VIEWERR-1 (Ubiquitous)**
`ViewError::DuplicateSymbolRow` shall carry the offending `Symbol`. Its `Display` shall equal the derived `Debug` rendering exactly, e.g. for symbol `"AMZN"`: `DuplicateSymbolRow("AMZN")`.

**SHEET-MARK-KEY-1 (Ubiquitous)**
The marks settle pass shall key every price reading, prior mark, produced mark, and degraded entry by `Symbol` (`BTreeMap<Symbol, _>` for `PricePass`, `MarksProduced.marks`, `MarksProduced.degraded`, and the `prior` input), one-to-one against the Positions tab's per-row symbol — never combining, splitting, or re-keying readings across symbols.

**SHEET-MARK-KEY-2 (Ubiquitous)**
`MarksProduced::to_ledger_marks` shall project `marks` to symbol→`Cents` unchanged in key structure; a symbol present only in `degraded` shall be absent from the projected map (no key emitted for a degraded symbol — never a placeholder/zero entry under that symbol).

No numeric constants, ordering, or normalization rule beyond `Symbol` string identity governs this keying concern in these two files — matching is by exact `Symbol` value equality, no case-folding or trimming is shown or tested.