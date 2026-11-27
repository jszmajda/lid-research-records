**EARS requirements — Marks read-back after formula write (sheets-view / runtime adapter)**

**Ubiquitous:**
- The system shall read the `Price`/`Quote Date` cells only via a settle pass that is a distinct operation from the formula-writing `batch_update_view`/republish call; a settle read shall never occur inline with, or before, the write it follows.
- The system shall interpret Positions data-row column 4 (0-indexed) as `Price` and column 12 as `Quote Date` (locale-proof integer days-since-1970).
- The price→Cents conversion shall be `round_half_to_even(price_usd × 100)` via a ×1,000,000 integer scale (banker's rounding at exact ties: 1.005→$1.00, 1.015→$1.02).

**Event-driven:**
- WHEN `republish_then_settle` runs, the system shall complete ALL tab writes before issuing ANY settle read (every recorded read must occur strictly after every recorded write).
- WHEN a Price cell is empty, "Loading..." (case-insensitive), or exactly "#N/A", the system shall classify the reading Transient.
- WHEN a Price cell starts with '#' and is not exactly "#N/A", the system shall classify Permanent.
- WHEN a Price cell parses as f64, the system shall classify Numeric, parsing Quote Date as i32 (defaulting to Date(0) if unparseable); a non-parsing, non-transient, non-'#' cell classifies Permanent.
- WHEN the bounded window elapses with a symbol still Transient/absent and a prior mark exists, the system shall carry the prior mark forward unchanged and shall not record it degraded.
- WHEN a symbol reads Permanent, the system shall record it degraded immediately (reason Permanent), without waiting out the poll window and without carrying any prior mark.
- WHEN a Positions data row's Symbol cell is empty, the system shall omit that row from the pass entirely.

**State-driven:**
- WHILE polling, the system shall repeat `read_price_pass` up to `SettleConfig.max_polls` (default 8) times, stopping early once every requested symbol is Numeric-or-Permanent (never Transient/absent).
- WHILE the Positions tab does not yet exist, the system shall treat `read_price_pass` as yielding an empty pass, not an error.

**Unwanted behavior:**
- IF `read_price_pass` returns an error (offline/unreachable), THEN the system shall propagate that error and shall NOT emit an empty/partial `MarksProduced`.
- IF a numeric price rounds to ≤0 cents (positive-sub-cent, exact zero, or negative), THEN the system shall classify it degraded SubCent, never a zero/negative mark.
- IF a price is non-finite (NaN/±∞), THEN the system shall classify it degraded Permanent.
- IF a symbol is degraded (any reason), THEN it shall be absent — never present as 0/null — from the resulting ledger-marks map.