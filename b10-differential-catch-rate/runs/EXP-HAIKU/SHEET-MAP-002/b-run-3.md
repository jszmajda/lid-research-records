**MARK-READBACK: Row Keying by Symbol Identity**

The mark read-back and settle pass enforce the following invariants and behaviors:

**MARK-READBACK-001 [x]:** One row per symbol in the Positions tab. The `render_positions` function maintains a defensive `seen` set (BTreeSet) of symbols already rendered; if any symbol appears twice, the function errors immediately with `ViewError::DuplicateSymbolRow(symbol)`. This is a **loud, structural guard** — while `Snapshot.positions` is a Map<Symbol,_> making this unreachable through the real API, the guard remains as a contract for any future non-Map data source, ensuring the read-back's row-identity keying (one symbol per row) is never silently violated.

**MARK-READBACK-002 [x]:** Settle pass polls until every requested symbol is numeric-or-terminal. The `read_marks` function polls `client.read_price_pass()` in a loop, tracking the latest reading per symbol across polls. Settlement is reached when no requested symbol has `PriceReading::Transient` or remains absent; the loop terminates early if `polls >= cfg.max_polls` (default 8), bounding the retry window.

**MARK-READBACK-003 [x]:** Transient symbols retain prior mark, else degrade with TimedOut. If a symbol's latest reading is `Transient` or absent after the settle window elapses: if `prior.get(symbol)` succeeds, the prior mark is inserted into `out.marks` (no mark degradation); otherwise the symbol is recorded in `out.degraded` with `DegradeReason::TimedOut` (no mark produced).

**MARK-READBACK-004 [x]:** Permanent errors degrade with no prior carry. A `PriceReading::Permanent` reading is immediately recorded in `out.degraded` with `DegradeReason::Permanent`, with no check for prior marks.

**MARK-READBACK-005 [x]:** Price-to-cents conversion: round half-to-even, reject non-positive and non-finite. The `price_to_cents(price_usd: f64)` function scales the float price by 100 × 1,000,000 to an integer numerator, then calls `pt_core::round_half_to_even(numerator, 1_000_000)` to compute cents. A non-finite input (NaN, ±Infinity) returns `Err(DegradeReason::Permanent)` before scaling. Any result ≤ 0 cents (including positive prices that round to 0 cents) returns `Err(DegradeReason::SubCent)`. Only positive cents produce marks.

**MARK-READBACK-006 [x]:** No mark produced for offline (transport failure). If `read_price_pass()` returns `Err`, the function propagates the error with no `MarksProduced` output. `runtime` handles carry-forward of prior marks; `sheets-view` does not silently emit an empty set on offline.

{scratch}/audit-baseline/crates/sheets-view/src/lib.rs:532–544 (duplicate guard), 817–887 (settle pass loop and mark production), 362–385 (price conversion)
{scratch}/audit-baseline/crates/sheets-view/tests/mapping.rs:65–91, 93–125 (row-identity keying tests)