## Reconstructed EARS Requirements — Degraded Marks & Offline Behavior

**Price→Cents conversion (event-driven)**
When a settle-pass reading for a symbol is `Numeric{price_usd, quote_date}`, the system shall convert `price_usd` to `Cents` via `round_half_to_even(price_usd × 100)`, computed by scaling to an integer numerator over `SCALE = 1_000_000` before rounding once (banker's rounding: `1.005 → 1.00`, `1.015 → 1.02`), and shall stamp the resulting `Mark` with GOOGLEFINANCE's own `quote_date` (never wall-clock time).

**Sub-cent/non-positive degrade (unwanted behavior)**
If the numeric conversion yields ≤0 Cents — whether from a positive price rounding to 0, an exact `0.0`, or a negative price — the system shall degrade the symbol with `DegradeReason::SubCent` and record no mark; it shall never emit a real zero or negative mark.

**Non-finite degrade (unwanted behavior)**
If the numeric price reading is non-finite (`NaN` or `±Infinity`), the system shall degrade the symbol with `DegradeReason::Permanent`.

**Bounded settle polling (state-driven)**
While any requested symbol's latest reading is `Transient` or absent, the system shall keep polling `read_price_pass` (one call per poll) up to `SettleConfig.max_polls` (default `8`), stopping early once every requested symbol is numeric-or-terminally-errored.

**Timeout with/without prior (unwanted behavior)**
If a symbol is still `Transient`/absent once `max_polls` is reached, the system shall retain that symbol's prior cached `Mark` unchanged (not degraded) when a prior mark exists, and shall otherwise degrade it with `DegradeReason::TimedOut` and record no mark.

**Permanent error (event-driven)**
When a symbol's reading is `Permanent`, the system shall degrade it immediately with `DegradeReason::Permanent`, discarding any prior mark, without waiting out the poll window.

**Mutual exclusivity (ubiquitous)**
The system shall report each requested symbol in exactly one of `MarksProduced.marks` (fresh or carried-forward) or `.degraded` (reason, no mark), never both.

**Downstream projection (event-driven)**
When projecting to `ledger_core::Marks` (`to_ledger_marks`), the system shall include only non-degraded symbols; a degraded symbol's omission shall cause ledger-core to compute that symbol's unrealized figure as `None`, per-symbol — never a zero substitute.

**Offline/transport failure (unwanted behavior)**
If `read_price_pass` itself errors, `read_marks` shall propagate the `Err` and produce no `MarksProduced` value — it shall never emit an empty or all-degraded marks set in its place.