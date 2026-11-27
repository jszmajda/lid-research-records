SHEET-MARK-001 (Transient Price Cells: Prior Mark Carryover)
A symbol that reads as transient (`#N/A`, `Loading...`, or absent from the settle pass) after polling up to `max_polls` times SHALL carry forward its prior good cached mark (if one exists) rather than overwriting it. The carried mark retains its original GOOGLEFINANCE quote-date stamp.

SHEET-MARK-002 (Transient Price Cells: Degradation Tiebreak)
A transiently-unknown symbol SHALL NOT be recorded degraded when a prior good mark is injected. If the symbol has no prior cached mark, it SHALL degrade as `TimedOut` after the bounded poll window (`max_polls`) elapses without a numeric or terminal-error reading.

SHEET-MARK-003 (Terminal vs. Transient Errors)
A `Permanent` price error (terminal non-numeric like ticker-form mismatch) SHALL degrade the symbol immediately as `Permanent` and SHALL NOT carry the prior cached mark forward—terminal errors override prior history. Transient nulls (absent or `#N/A`/`Loading...`) differ: they keep prior if one exists.

SHEET-MARK-004 (Settle Pass Polling Window)
The settle pass polls `read_price_pass()` up to `max_polls` times. Each symbol settles when its latest reading is numeric or terminally errored (not transient/absent). The loop exits early if all requested symbols are settled, or after `max_polls` polls, whichever is first.

SHEET-MARK-005 (Numeric Price to Cents Conversion)
Each numeric USD price converts to `Cents` via `round_half_to_even(price × 100 × 1_000_000) / 1_000_000`, applying half-to-even rounding at the cent boundary. Non-positive prices (`≤ 0.0`) and prices rounding to zero cents (sub-cent anomaly) degrade as `SubCent`, never as a real zero mark. Non-finite prices (`NaN`, `±∞`) degrade as `Permanent`.

SHEET-MARK-006 (Per-Symbol Quote-Date Stamp)
Each settled mark is stamped with the GOOGLEFINANCE-supplied quote-date, not wall-clock read time. Transient carry-forward preserves the original quote-date from the prior cached mark.