**EARS requirements — marks read-back after formula write (sheets-view / runtime adapter)**

1. (Event-driven) WHEN a republish-then-settle cycle runs, the system SHALL read Price/Quote-Date cells only after the full-tab `batchUpdate` write returns, as a separate settle-pass call — never inline with the write. Call-log ordering pins every read strictly after every write in the cycle.

2. (Ubiquitous) The settle pass SHALL read the Positions data range from row `DATA_START_ROW` (=2, beneath the frozen header at row 1) through column Z; Price is column index 4, Quote Date is column index 12.

3. (Ubiquitous) A Price cell SHALL be classified: empty string, case-insensitive "Loading...", or exact "#N/A" → Transient; any other string starting with '#' → Permanent; a string parseable as f64 → Numeric(price_usd, quote_date), where quote_date parses column 12 as an integer day count, defaulting to `Date(0)` if absent/unparseable; any other non-"#" unparseable string → Permanent.

4. (Ubiquitous) Numeric→Cents conversion: `round_half_to_even(price_usd × 100)`, computed via integer scaling by 1,000,000. Non-finite input (NaN/±Infinity) → degrade Permanent. Any price ≤ 0 (exact 0.0, negative) or a positive price rounding to 0 cents → degrade SubCent, never a zero/negative mark.

5. (State-driven) WHILE any requested symbol's latest reading is Transient or absent, the system SHALL re-poll `read_price_pass`, bounded by `SettleConfig.max_polls` (default 8); it SHALL stop polling once every requested symbol is numeric-or-terminally-errored, or the bound is reached, whichever first.

6. (Event-driven) WHEN the poll bound is reached with a symbol still Transient/absent AND a prior mark exists for it, the system SHALL carry the prior mark forward unchanged and SHALL NOT mark it degraded.

7. (Unwanted behavior) IF a symbol is still Transient/absent at the poll bound AND no prior mark exists, THEN the system SHALL record it degraded (TimedOut) with no mark.

8. (Event-driven) WHEN a reading is Permanent, the system SHALL degrade it (Permanent) immediately, without further polling and without carrying forward any prior mark.

9. (Unwanted behavior) IF the settle-pass read call itself errors (offline/unreachable), THEN the system SHALL propagate the error and produce no `MarksProduced` — never a silently-empty marks set.

10. (State-driven) WHILE the Positions tab does not yet exist, a settle-pass read SHALL return an empty price pass, not an error.

11. (Ubiquitous) Degraded symbols SHALL be absent from the ledger-facing marks map; only successfully-priced symbols project through.