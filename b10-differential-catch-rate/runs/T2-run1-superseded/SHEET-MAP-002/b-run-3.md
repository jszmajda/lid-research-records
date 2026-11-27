**Concern: Positions-tab row keying for the marks read-back, and duplicate-symbol handling**

**[Ubiquitous] SHEET-POS-KEY:** The Positions view tab SHALL contain exactly one row per symbol, with the row's `Symbol` column (`Cell::Value`, column A) serving as the row-identity key that the marks settle-pass read-back joins on.

**[Ubiquitous] SHEET-POS-SRC:** `render_positions` SHALL derive rows by iterating `Snapshot.positions` (a `Map<Symbol,_>`), one row per map entry, so uniqueness is guaranteed structurally by the source map's key.

**[Unwanted behavior] SHEET-POS-DUP:** IF, while rendering Positions rows, a symbol is encountered that has already produced a row THEN `render_positions` SHALL NOT render the second/duplicate row and SHALL immediately return `Err(ViewError::DuplicateSymbolRow(symbol))`, aborting the render (no partial `ViewTab` is returned — rows accumulated before the duplicate are discarded, not the Ok value).

**[State-driven] SHEET-POS-DEFENSIVE:** WHILE the real `Snapshot.positions` map type enforces unique symbol keys, this duplicate check is a defensive/loud-failure invariant guard: it is structurally unreachable via the current API but MUST remain so a future non-map position source cannot silently double-render a symbol and corrupt the read-back key.

**[Ubiquitous] SHEET-POS-ERR-FMT:** `ViewError::DuplicateSymbolRow(Symbol)`'s `Display` implementation SHALL render as the variant's `Debug` form, i.e. exactly `DuplicateSymbolRow("<symbol>")` (quoted symbol text), with no separate human-readable message.

**[Ubiquitous] SHEET-POS-NO-NORM:** Symbol matching for duplicate detection SHALL use exact equality/ordering on the `Symbol` value as given (via a `BTreeSet<&Symbol>` "seen" set) — no case-folding, trimming, or other normalization is applied before comparison.

**[Ubiquitous] SHEET-MARK-KEY:** The marks read-back (`read_marks`) SHALL key its polled `PricePass`/output `MarksProduced` maps by the same `Symbol` values as the Positions rows (`BTreeMap<Symbol, _>`), relying on the Positions tab's one-row-per-symbol invariant to make each symbol's `Price`/`Quote Date` cell reading unambiguous per settle-pass poll.

Tests pin: (a) happy-path multi-symbol render (AMZN, GOOG) yields as many rows as distinct symbols (sort+dedup length equality) — confirms one-row-per-symbol holds through the real API; (b) the `Err` variant's `Display` output is asserted verbatim as `DuplicateSymbolRow("AMZN")`, pinning the Debug-derived format as contract, not incidental; (c) tests explicitly frame the duplicate-guard branch as unreachable/defensive rather than exercising it through a real duplicate snapshot (none is constructible).

Files read: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs`, `.../tests/mapping.rs`.