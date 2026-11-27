**EARS requirements enforced (degraded-symbol marks: downstream effect + offline behavior)**

**Ubiquitous**
- The system shall classify each settle-pass price reading as exactly one of: `Numeric{price_usd, quote_date}`, `Transient`, or `Permanent`.
- The system shall classify every degraded symbol with exactly one `DegradeReason`: `TimedOut`, `Permanent`, or `SubCent`.
- The system shall convert a numeric USD price to `Cents` via `round_half_to_even(price_usd × 100 × 1_000_000, 1_000_000)` (half-to-even tie-break; e.g. 1.005→1.00, 1.015→1.02) — the sole rounding rule, no float-native rounding used.

**Event-driven**
- WHEN `price_to_cents` receives a non-finite value (NaN or ±∞), the system shall return `Err(DegradeReason::Permanent)`.
- WHEN `price_to_cents` receives a value ≤ 0 (including exact 0.0 and negative), the system shall return `Err(DegradeReason::SubCent)`.
- WHEN a positive price rounds to 0 `Cents`, the system shall return `Err(DegradeReason::SubCent)` — never a zero mark (a degraded anomaly is never conflated with a real zero value).
- WHEN a symbol's latest reading is `Permanent`, the system shall record it degraded (`Permanent`) immediately, without waiting for `max_polls` to elapse, and shall NOT carry forward any prior mark for that symbol.
- WHEN converting `MarksProduced` to `ledger_core::Marks` (`to_ledger_marks`), the system shall omit every degraded symbol from the map entirely (never map it to `Cents(0)`), so ledger-core applies per-symbol degradation (unrealized → `None`) rather than a false zero value.
- WHEN a numeric reading settles, the system shall stamp the resulting `Mark` with `GOOGLEFINANCE`'s own quote date, not wall-clock read time.

**State-driven**
- WHILE a symbol's reading stays `Transient` (or absent) across polls, the system shall keep polling `read_price_pass` up to `SettleConfig.max_polls` (default 8) before treating it as settled-degraded.
- WHILE a symbol is still `Transient` after `max_polls` is reached AND a prior mark exists for it, the system shall carry the prior mark forward unchanged (same `price_cents`/`quote_date`) and shall NOT record it as degraded.
- WHILE a symbol is still `Transient` after `max_polls` is reached AND no prior mark exists, the system shall record it degraded with reason `TimedOut` and produce no mark for it.

**Unwanted behavior**
- IF the underlying `read_price_pass` call errors (workbook unreachable/offline), THEN `read_marks` shall propagate that `Err` and shall produce no `MarksProduced` at all — it shall never substitute an empty/partial marks set (which would misread as "all symbols degraded" and wrongly null live positions).