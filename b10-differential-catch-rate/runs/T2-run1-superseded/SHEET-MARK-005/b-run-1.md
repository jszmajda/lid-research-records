**Requirements reconstructed for: degraded symbol marks → downstream consumers & offline behavior** (SHEET-MARK-*)

1. **[Ubiquitous]** `price_to_cents` shall convert a USD price to `Cents` via `round_half_to_even(price_usd × 100)` (computed as a micro-scaled integer, scale `1_000_000`), this being the project's sole rounding site for this conversion.

2. **[Unwanted behavior]** If the price reading is non-finite (`NaN` or `±∞`), then `price_to_cents` shall return `Err(DegradeReason::Permanent)`, never a `Cents` value.

3. **[Unwanted behavior]** If the numeric price is ≤ 0.0 (zero or negative), or a positive price rounds to 0 `Cents` under half-to-even rounding, then `price_to_cents` shall return `Err(DegradeReason::SubCent)` — never `Ok(Cents(0))` and never a negative mark; a degraded reading must never silently understate value as a real zero.

4. **[State-driven]** While a requested symbol's settle-pass reading is `Transient` (`#N/A`/`Loading...`), `read_marks` shall keep polling `read_price_pass` until every requested symbol is numeric-or-terminally-errored or `SettleConfig.max_polls` (default `8`) polls have elapsed, whichever comes first.

5. **[Event-driven]** When a symbol remains `Transient` through the bounded poll window and a prior `Mark` exists for it, `read_marks` shall carry that prior `Mark` (price and quote date unchanged) forward as this cycle's mark, and shall NOT record it degraded.

6. **[Event-driven]** When a symbol remains `Transient` through the bounded poll window and no prior mark exists, `read_marks` shall record it degraded with `DegradeReason::TimedOut` and emit no mark for it.

7. **[Event-driven]** When a symbol's reading is `Permanent` (terminal non-numeric error), `read_marks` shall record it degraded with `DegradeReason::Permanent` immediately — without waiting out the poll window — and shall discard any prior mark for that symbol (no carry-forward on a terminal error).

8. **[Ubiquitous]** `MarksProduced::to_ledger_marks()` shall include only symbols in `marks`, omitting every symbol in `degraded`; a degraded symbol yields no entry (absence, not a zero or stale value) in the `ledger_core::Marks` map, so `ledger-core` degrades that symbol's own unrealized figure to `None`.

9. **[Unwanted behavior]** If the underlying `read_price_pass` call itself errors (workbook unreachable/offline), then `read_marks` shall propagate that `Err` and produce no `MarksProduced` at all — it shall NOT emit an empty/partial marks set, which would misread as "all symbols degraded."

10. **[Ubiquitous]** A settled `Mark`'s `quote_date` shall be the `GOOGLEFINANCE`-supplied quote date from the `Numeric` reading, never wall-clock read time.