# Reconstructed EARS Requirements: Marks Read-Back (Price Cell Settle Pass)

**Ubiquitous**
- The Price/Quote-Date read-back shall run as a settle pass strictly separate from the formula write — never inline with it.
- Positions data rows begin at row `DATA_START_ROW = 2`; within a row, `Price` is column index 4 and `Quote Date` is column index 12.
- Price→Cents conversion shall use `round_half_to_even` applied to `price_usd × 100`, computed via a ×1,000,000 integer micro-cent scale (the project's single rounding rule).
- A degraded symbol shall be absent from the projected `ledger_marks` map (`to_ledger_marks`) — never present as a zero mark.

**Event-driven**
- WHEN `republish_then_settle` runs, THE settle-pass read SHALL occur only after all view-tab `batchUpdate` writes in the cycle have returned (never before, never concurrently); the write lock guards only the write half.
- WHEN a Price cell is empty, `"Loading..."` (case-insensitive), or exactly `"#N/A"`, THE reading SHALL classify Transient.
- WHEN a Price cell starts with `#` and is not exactly `"#N/A"`, THE reading SHALL classify Permanent.
- WHEN a Price cell parses as f64, THE reading SHALL classify Numeric, pairing it with the Quote-Date cell parsed as i32 (defaulting to `0` if unparseable).
- WHEN a Price cell is non-empty, doesn't start with `#`, and fails f64 parsing, THE reading SHALL classify Permanent.
- WHEN a Numeric conversion's rounded result is ≤ 0 cents (sub-cent-positive, exact 0.0, or negative), conversion SHALL fail `DegradeReason::SubCent` — never a real zero/negative mark.
- WHEN the raw price is non-finite (NaN/±∞), conversion SHALL fail `DegradeReason::Permanent`.
- WHEN `read_price_pass` errors (offline), the settle pass SHALL propagate the `Err` and produce no `MarksProduced` — never an empty marks set.
- WHEN the Positions tab doesn't exist yet, THE read SHALL return an empty `PricePass` (cold start), not an error.

**State-driven**
- WHILE any requested symbol's latest reading is Transient/absent, THE loop SHALL keep polling, up to `SettleConfig.max_polls` (default 8), then stop.
- WHILE a symbol stays Transient/absent past that window: IF a prior good mark exists THEN carry it forward unchanged, not degraded; ELSE degrade `TimedOut`, no mark.
- A Permanent reading degrades immediately (counts settled without exhausting the window) and never carries a prior mark forward.