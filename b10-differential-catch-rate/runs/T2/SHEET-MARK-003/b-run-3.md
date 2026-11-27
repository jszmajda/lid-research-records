**EARS requirements enforced (transient non-numeric price-cell handling during marks read-back — `sheets_view::read_marks`):**

1. **[Event-driven]** WHEN a settle-pass poll (`client.read_price_pass()`) returns `PriceReading::Transient` for a requested symbol, or the symbol is absent from that pass's response, THE system SHALL treat the symbol as not-yet-settled and continue polling.

2. **[State-driven]** WHILE polling, THE system SHALL retain only the latest reading received per symbol; a poll that omits a symbol SHALL NOT clear that symbol's previously recorded reading, and a later Numeric or Permanent reading SHALL supersede an earlier Transient one for the same symbol.

3. **[Ubiquitous]** THE settle loop SHALL stop as soon as every requested symbol's latest reading is neither Transient nor absent, and SHALL otherwise stop unconditionally once the poll count reaches `SettleConfig.max_polls` (default 8) — never polling unboundedly. (Pinned by tests: exact poll counts of 2, 3, and 4 when a symbol never settles equal `max_polls` exactly.)

4. **[Event-driven]** WHEN, after the loop ends, a requested symbol's latest reading is still Transient or absent, AND a prior cached `Mark` exists for that symbol, THE system SHALL carry the prior `Mark` forward unchanged — identical `price_cents` and `quote_date` — into this cycle's produced marks, and SHALL NOT record the symbol as degraded.

5. **[Unwanted behavior]** IF such a still-Transient/absent symbol has no prior cached `Mark`, THEN THE system SHALL record it in the degraded set with reason `DegradeReason::TimedOut` and SHALL emit no mark for it — never a fabricated or zero price.

6. **[Unwanted behavior, contrast]** A `PriceReading::Permanent` reading is NEVER treated as transient: WHEN a symbol's reading is Permanent, THE system SHALL settle that symbol immediately (without exhausting `max_polls`) and record it degraded with reason `DegradeReason::Permanent`, discarding any prior cached mark for that symbol — no carry-forward, unlike the Transient-timeout case.

7. **[Ubiquitous]** The per-symbol Transient/timeout path is distinct from a transport failure: an `Err` from `read_price_pass` itself aborts the whole `read_marks` call (propagated `Err`, no `MarksProduced`, no per-symbol degrade recorded), and MUST NOT be conflated with a per-symbol Transient cell reading.

Files: `crates/sheets-view/src/lib.rs` (`read_marks`, `PriceReading`, `DegradeReason`, `SettleConfig`), `crates/sheets-view/tests/marks.rs`, `crates/runtime/tests/cycle.rs`.