**EARS requirements enforced — marks read-back transport failure (sheets-view: `read_marks`, `read_price_pass`)**

1. **Ubiquitous.** A settle-pass "failure" is defined as the underlying `read_price_pass` transport call itself returning `Err` (workbook unreachable/offline) — distinct from a per-symbol `PriceReading::Transient` or `PriceReading::Permanent`, both of which are successful reads and are never treated as transport failure.

2. **Event-driven.** WHEN any poll of `read_price_pass` inside the settle loop returns `Err`, `read_marks` SHALL immediately propagate that `Err` as its own return value and SHALL NOT return a `MarksProduced`. This applies even if earlier polls in the same pass already returned good per-symbol readings — those readings (the in-progress `latest` map) are discarded, never returned as a partial result.

3. **Event-driven / no-retry.** WHEN a transport `Err` occurs on any single poll, `read_marks` SHALL fail on that first `Err` without retrying the transport call up to `cfg.max_polls`. The bounded retry window (default `max_polls = 8`) governs only per-symbol `Transient` readings, never a transport-level `Err`.

4. **Unwanted behavior.** IF the settle pass's transport call fails, THEN the system SHALL NOT substitute an empty/default `MarksProduced` (empty `marks` + `degraded` maps) — an empty result would be indistinguishable from "every symbol degraded" and would wrongly null live positions.

5. **Unwanted behavior.** IF the settle pass's transport call fails, THEN `read_marks` SHALL NOT itself carry `prior` marks forward into a result — it produces no result at all. Carrying the previously-cached per-symbol marks (with their original quote-date stamps) forward into the next replay is allocated to the caller (`runtime`), not to `read_marks`.

6. **State-driven, boundary case.** WHILE the Positions tab does not yet exist (fresh-workbook cold start), `read_price_pass` SHALL return `Ok(PricePass::new())` (empty), never `Err` — a missing tab is NOT a transport failure and must not be classified as one; `read_marks` then proceeds with zero readings rather than aborting.

7. **State-driven, boundary case (contrast).** WHILE the underlying transport is genuinely unreachable, the client SHALL return `Err`, and this SHALL be distinguishable from the missing-tab/cold-start case at the classification layer — the two conditions must never be conflated into the same outcome.

Constants pinned: `SettleConfig::max_polls` default `8` (not directly relevant to transport-failure itself, only to the non-failure transient path, included for boundary contrast).