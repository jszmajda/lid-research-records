## Mark Timestamping Requirements

**Mark.quote_date [ubiquitous]**: Each cached `Mark` is stamped with a `quote_date: Date` field representing the quote epoch (days since 1970-01-01) from GOOGLEFINANCE's `tradetime` field, not wall-clock read time. The formula `quote_date_formula()` encodes GOOGLEFINANCE's raw tradetime by subtracting `DATE(1970,1,1)` and rendering as TEXT digits-only for locale-proof parsing.

**Numeric settle read [ubiquitous]**: When `read_marks` processes a `PriceReading::Numeric { price_usd, quote_date }` reading during a settle pass, it converts the price to `Cents` via `price_to_cents()` (round-half-to-even × 100; sub-cent prices degrade to `SubCent`, non-finite to `Permanent`) and produces a new `Mark { price_cents, quote_date }` stamped exactly with the quote_date from that reading.

**Transient carry-forward preserves original timestamp [event-driven, state-driven]**: When a symbol reads as `PriceReading::Transient` or is absent in a settle pass, and a prior `Mark` exists in the `prior` map, `read_marks` carries the entire prior `Mark` forward unchanged—including its original `quote_date`. The quote_date is never refreshed; it reflects the GOOGLEFINANCE epoch when the prior price was last settled, not the current poll cycle.

**Transient degradation without prior [event-driven]**: When a symbol is `Transient` or absent across the entire bounded settle window (up to `max_polls` polls; default: 8 from `SettleConfig::default()`) and no prior `Mark` exists, the symbol is recorded in `degraded` with reason `TimedOut` and no `Mark` is produced—never a synthetic zero or empty-timestamp mark.

**Permanent error blocks carry-forward [event-driven, unwanted-behavior]**: A `PriceReading::Permanent` error (terminal, ticker-form mismatch) degrades immediately: the symbol is recorded in `degraded` with reason `Permanent` with NO `Mark` produced, even if a prior good `Mark` with a cached timestamp exists. Permanent errors do not carry forward.

**Settle loop settlement criterion [ubiquitous]**: The settle loop polls repeatedly, collecting the latest `PriceReading` per symbol, until (1) every requested symbol is `Numeric` or `Permanent` (settled), or (2) `polls >= max_polls` (bounded window elapsed), whichever occurs first. Transport failure (`read_price_pass` returns `Err`) propagates—no empty `MarksProduced` is emitted; the offline carry-forward (retaining all prior marks with their cached timestamps) is `runtime`'s responsibility.

---

**Word count: 382**

{scratch}/audit-U-MARK-004/crates/sheets-view/src/lib.rs, {scratch}/audit-U-MARK-004/crates/sheets-view/tests/marks.rs