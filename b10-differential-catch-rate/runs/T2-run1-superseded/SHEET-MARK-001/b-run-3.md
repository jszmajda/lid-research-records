**EARS requirements — marks read-back (price cells read after formula write)**

*Ubiquitous*
- U1: The Positions `Price` cell (column 4) and companion `Quote Date` cell (column 12) shall be read back only via a dedicated settle-pass call (`read_price_pass`), never inline with or combined into the `batch_update_view` formula write.
- U2: A numeric USD price shall convert to `Cents` via `round_half_to_even(price_usd × 100)` (computed as an integer numerator scaled ×1_000_000), the project's one rounding rule.

*Event-driven*
- E1: WHEN a `republish_then_settle` cycle runs, THE settle-pass read shall occur only after that cycle's writes (`batch_update_view`, then `set_tab_order`) have returned — never before or concurrently.
- E2: WHEN a `read_price_pass` succeeds, each symbol's Price-cell text shall classify as: empty/blank, case-insensitive `"Loading..."`, or exactly `"#N/A"` → Transient; any other text starting with `#` → Permanent; text parseable as `f64` → Numeric (quote_date parsed as `i32` from column 12, defaulting to `0` if missing/unparseable); any other non-`#`, non-parseable text → Permanent.
- E3: WHEN a Numeric reading's conversion yields `Cents ≤ 0`, THE symbol shall be recorded degraded(`SubCent`) with no mark — never a zero/negative mark.
- E4: WHEN `price_usd` is non-finite (NaN/±∞), THE conversion shall fail as degraded(`Permanent`).

*State-driven*
- S1: WHILE any requested symbol's latest reading is Transient or absent, THE settle loop shall re-poll, up to `SettleConfig.max_polls` (default 8) total polls, then stop.
- S2: WHILE a symbol stays Transient/absent through the bounded window AND a prior good `Mark` exists for it, THE prior mark shall be carried forward unchanged (not degraded).
- S3: WHILE a symbol stays Transient/absent through the window with no prior mark, THE symbol shall be recorded degraded(`TimedOut`).
- S4: A Permanent reading settles that symbol's loop immediately (does not consume remaining poll budget) and records degraded(`Permanent`) — never carrying a prior mark forward.

*Unwanted-behavior*
- N1: IF `read_price_pass` returns `Err` (offline/unreachable), THEN the settle read shall propagate the error and produce no `MarksProduced` — it shall not synthesize an empty marks set.
- N2: IF the Positions tab does not yet exist, THEN the read shall return an empty `PricePass`, not an error.
- N3: Degraded symbols shall be absent from `MarksProduced::to_ledger_marks`'s output, never present with a stale or zero value.

Sources: `crates/sheets-view/src/lib.rs` (`read_marks`, `price_to_cents`, `SettleConfig`), `crates/runtime/src/adapters.rs` (`price_reading_from_cells`, `read_price_pass`), tests in `crates/sheets-view/tests/marks.rs` and `crates/sheets-view/tests/republish.rs`.