Reconstructed EARS requirements — sheets-view marks read-back: transport-failure concern (`read_marks`, `SheetsViewClient::read_price_pass`, `ViewError`)

**[Event-driven]** WHEN a poll of `read_price_pass` returns `Err` during the settle pass, `read_marks` SHALL immediately propagate that `Err(ViewError)` to its caller and SHALL terminate the pass without executing further polls.

**[Unwanted behavior]** `read_marks` SHALL NOT convert a transport failure into a successful `Ok(MarksProduced)` containing an empty or all-degraded map — such a result is indistinguishable from every symbol having genuinely degraded and would incorrectly null out live positions' unrealized figures.

**[Unwanted behavior]** On a transport failure, `read_marks` SHALL NOT itself copy its `prior` argument into an emitted `MarksProduced`. Carry-forward of the last good cached marks (with their quote-epoch stamps) across an offline cycle is exclusively the caller's (`runtime`'s) responsibility — achieved by the caller retaining its own existing cache and re-injecting it into the next replay — not something `read_marks` performs internally.

**[State-driven]** WHILE the poll loop has already accumulated per-symbol readings (numeric or degraded) from earlier successful polls in the same cycle, IF a later poll's `read_price_pass` call then fails, THEN the entire call SHALL still return `Err` — the abort is all-or-nothing for the cycle; no partial per-symbol results are returned.

**[Ubiquitous]** A transport failure is categorically distinct from a per-symbol `PriceReading::Transient` or `PriceReading::Permanent`: `Transient` is retried until `SettleConfig::max_polls` (default `8`) polls elapse, then degrades only that symbol as `TimedOut` (carrying forward the `prior` mark if present, else degrading with no mark); `Permanent` degrades only that symbol as `Permanent` immediately, with no `prior` carry, and settles the loop before exhausting `max_polls`. Neither aborts the whole pass or produces an `Err`; only a transport-level failure from `read_price_pass` does.

**[State-driven]** IF the Positions tab does not yet exist (fresh workbook), the read-back SHALL return `Ok` with an empty `PricePass`, not an error — absence of a tab is not a transport failure and must not be classified as one.

Files read: `crates/runtime/tests/cold_start.rs`, `crates/sheets-view/src/lib.rs`, `crates/sheets-view/tests/marks.rs` (paths under `{scratch}/audit-baseline/`).