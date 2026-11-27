## EARS Requirement: Marks Read-Back Transport Failure Semantics

**Pattern: Error-driven (boundary contract)**

When a transport failure occurs during the marks read-back settle pass (workbook unreachable, network offline, or batch-read API error), the following behaviors are enforced:

**SHEET-MARK-TRANSPORT-OFFLINE**: On transport failure, `read_marks` **propagates the error and produces no `MarksProduced`**. It does not emit an empty marks set, does not return a partial marks structure, and does not itself carry forward prior cached marks. This loud failure (not silent degradation) prevents data loss: an empty marks set would be misread as "all symbols degraded," wrongly nulling live position values in replay. The offline carry-forward (retaining prior good marks across the failure boundary) is `runtime`'s responsibility: runtime caches marks with their quote-date stamps and re-injects them into the next replay when `read_marks` errors.

**SHEET-MARK-SETTLE-BOUNDED**: The settle pass bounds polling by `SettleConfig.max_polls` (default: 8 polls). Each poll calls `read_price_pass()`. The loop exits early if every symbol is numeric-or-terminally-errored, or continues until `max_polls` is exhausted. If `read_price_pass()` errors on any poll, the error propagates immediately (no retry).

**SHEET-MARK-PRICE-ROUNDING**: Price USD→Cents conversion uses `round_half_to_even(price_usd × 100 × 1_000_000, 1_000_000)`, scaling via integer micro-cents arithmetic and rounding once. Non-finite prices (`NaN`, `±∞`) degrade `Permanent`. Non-positive prices (0.0, negative, or positive prices rounding to ≤0 Cents) degrade `SubCent`, never zero or negative marks.

**SHEET-MARK-QUOTE-DATE**: Settled marks carry `GOOGLEFINANCE`'s quote-date (not wall-clock read time). Per-symbol marks are stamped `Mark { price_cents: Cents, quote_date: Date }`.

**SHEET-MARK-PRIOR-CARRY-RULES**: (1) Numeric readings → mark produced, (2) Permanent error readings → `DegradeReason::Permanent`, no prior carry, (3) Transient readings still transient after max_polls → if a prior mark exists, carry it forward (don't degrade); if no prior, degrade `TimedOut`.

**SHEET-MARK-LEDGER-PROJECTION**: Degraded symbols are absent from `to_ledger_marks()`, so ledger-core applies per-symbol degradation (unrealized → None, not zero).