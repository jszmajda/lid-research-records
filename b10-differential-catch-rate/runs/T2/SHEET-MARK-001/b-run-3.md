Reconstructed EARS requirements for the marks read-back concern (price-formula write → separate settle-pass read), as pinned by `sheets-view`'s `read_marks`/`price_to_cents`/`Publisher` and the runtime `ViewSheetsAdapter`:

**Ubiquitous**
- The settle-pass price read SHALL be a call distinct from the formula `batchUpdate` write; it is never issued inline with a write.
- The Positions data grid SHALL be read from column A onward with fixed column offsets: Symbol at column 0, `Price` at column 4, `Quote Date` at column 12 (0-indexed), rows starting at `DATA_START_ROW` (row 2, beneath the frozen header, which is never rewritten).
- A price→Cents conversion SHALL use `round_half_to_even(price_usd × 100)` (scaled via a 1e6 micro-factor) as the sole rounding rule.

**Event-driven**
- WHEN a republish cycle runs (`republish_then_settle`), the system SHALL perform the settle-pass read only after the preceding write returns (single serialized thread of control); the advisory write-lock guards only the write half, not the read.
- WHEN a `Price` cell's trimmed text is empty, case-insensitively equals `"Loading..."`, or exactly equals `"#N/A"`, the reading SHALL be classified Transient.
- WHEN a `Price` cell's trimmed text starts with `#` but is not exactly `"#N/A"`, OR fails to parse as f64, the reading SHALL be classified Permanent.
- WHEN a `Price` cell parses as a finite f64, the `Quote Date` cell (column 12) SHALL be parsed as i32, defaulting to `Date(0)` if unparseable, and a Numeric reading produced.
- WHEN the Positions tab does not exist, `read_price_pass` SHALL return an empty pass (not an error).

**State-driven**
- WHILE any requested symbol remains Transient or absent from the latest pass, the settle loop SHALL re-poll `read_price_pass`, bounded by `SettleConfig.max_polls` (default 8); a poll count exactly equal to `max_polls` is reached when settlement never occurs.

**Unwanted behavior**
- IF the poll window elapses with a symbol still Transient AND a prior mark exists, THEN the prior mark SHALL be carried forward unchanged and the symbol SHALL NOT be recorded degraded.
- IF the poll window elapses with a symbol still Transient AND no prior mark exists, THEN the symbol SHALL degrade as `TimedOut` with no mark.
- IF a reading is Permanent, THEN the symbol SHALL degrade immediately as `Permanent` with no prior-mark carry-forward, and the loop SHALL treat it as settled (need not exhaust `max_polls`).
- IF `price_to_cents` yields ≤0 cents from a finite positive-or-zero-or-negative price, THEN degrade as `SubCent` — never a zero/negative mark.
- IF the price is non-finite (NaN/±∞), THEN degrade as `Permanent`.
- IF the underlying read transport errors, THEN `read_marks` SHALL propagate `Err` and produce no `MarksProduced` — never silently emit an empty marks set.
- Degraded symbols SHALL be absent from the `to_ledger_marks()` projection (never a zero-value entry).