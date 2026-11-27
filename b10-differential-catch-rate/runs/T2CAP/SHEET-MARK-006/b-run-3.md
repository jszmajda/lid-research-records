SHEET-MARK-TRANSPORT — marks read-back under transport failure

**Unwanted behavior**
- If, during the marks settle pass, a poll of the price read-back (`SheetsViewClient::read_price_pass`) returns an error (workbook unreachable / offline), then the settle pass shall abort immediately at that poll and propagate that `ViewError` unchanged to its caller.
- If the settle pass aborts on a transport error, then it shall produce no `MarksProduced` value at all — in particular it shall not return an empty or partial marks set, and shall not return the symbols as degraded. (Rationale pinned in code/tests: an empty set would read as "all symbols degraded" and would wrongly null live positions.)
- If the settle pass aborts on a transport error, then it shall not itself carry the caller-supplied `prior` marks forward into any result; prior marks are not echoed back. Carry-forward is the caller's (`runtime`) responsibility: on `Err`, `runtime` retains its existing cached marks with their quote-date stamps and re-injects them into the next replay.
- If the very first poll errors, then the abort occurs before any symbol is classified, regardless of `SettleConfig.max_polls` and regardless of whether `prior` contains marks for the requested symbols.
- If a republish-then-settle cycle's settle half errors, then the whole cycle shall return that `ViewError` and no `(RepublishOutcome, MarksProduced)` pair — the republish outcome computed before the settle read is discarded, and republish's own per-tab stale flags remain as republish left them.

**Distinguishing transport failure from other read-back conditions (each is not a transport failure)**
- A missing/absent Positions tab on a fresh workbook shall be reported by the real client as an empty `PricePass` (`Ok`), never as an error ("no tab yet ⇒ no marks, not an outage").
- A per-cell `#N/A`/`Loading…` reading shall be `PriceReading::Transient` — polled again up to `max_polls` (default 8), then resolved per-symbol: carry the `prior` mark if one exists (not marked degraded), else degrade `TimedOut` with no mark. A symbol absent from the pass is treated identically to `Transient`.
- A terminal non-numeric cell error shall be `PriceReading::Permanent` — degraded `Permanent` with no mark, no `prior` carry, and it settles the loop without exhausting the poll window.
- A numeric reading that is non-finite (`NaN`, `±∞`) degrades `Permanent`; one that is ≤ 0 after `round_half_to_even(price × 100)` (including exactly `0.0`, negatives, and positive sub-cent prices such as `0.0001`) degrades `SubCent`. Neither is a transport failure.
- Degraded symbols are omitted from `to_ledger_marks()` so replay degrades them per-symbol (unrealized `None`, not zero).
- Transport failure is classified as `StoreError::Unreachable` and shall never be misread as a missing tab (`StoreError::TabMissing`, the 400 `Unable to parse range` cold start).

Files: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs` (`read_marks`, `republish_then_settle`), `.../crates/sheets-view/tests/marks.rs`, `.../crates/runtime/tests/cold_start.rs`