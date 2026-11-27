## Transient Non-Numeric Price-Cell Handling: Read-Back Spec

**SHEET-MARK-TRANSIENT**: During the settle pass, a transient (non-numeric, non-terminal) price cell (`#N/A`, `Loading...`) for an open position is held unchanged and retried until the bounded polling window expires or the symbol becomes numeric or terminally errored.

- **Settlement condition**: The pass completes when every requested symbol is numeric or permanently errored, or `max_polls` polls have been issued (exact count enforced; no infinite loop).
- **Transient with prior mark**: A symbol that stays transient past the polling window and has a cached prior-cycle mark keeps the prior mark **unchanged** (never overwrites with transient, never records the symbol degraded).
- **Transient without prior mark**: A symbol that stays transient with no cached prior mark is recorded `Degraded(TimedOut)` after the window expires; no mark is produced for it.
- **Terminal error (Permanent)**: A terminal non-numeric error (`#N/A` from ticker mismatch, etc.) is immediately classified `Degraded(Permanent)`, never carries forward from prior, and does not exhaust the polling window.
- **Per-symbol quote epoch**: A good mark is stamped with its GOOGLEFINANCE quote date (not wall-clock read time); the quote date survives through the reduction to trading-day key and into per-symbol freshness display.

**SHEET-MARK-PRICE-TO-CENTS**: A numeric price reading is converted to `Cents` via `price_usd × 100`, rounded by half-to-even (the project's canonical rounding site).

- **Rounding rule**: Exact cents (e.g., 200.0 → 200_00); half-cent ties broken to nearest even (1.005 → 1_00, 1.015 → 1_02).
- **Sub-cent degrade**: A positive price rounding to ≤ 0 Cents is a degraded anomaly (`SubCent`), never a real zero or negative mark. Exact 0.0 or negative readings degrade `SubCent`; non-finite (`NaN`, `±∞`) degrade `Permanent`.
- **No silent understatement**: Value is never silently understated by a rounded-away mark.

**SHEET-MARK-OFFLINE**: On a transport failure (workbook unreachable / offline during settle), `read_marks` propagates the error and produces no `MarksProduced` — it does not emit an empty marks set (which would falsely indicate all symbols degraded).

- **Carry-forward responsibility**: The caller (`runtime`) retains its prior cached marks on offline, re-injecting them into the next replay; the settle pass does not itself carry forward.

**SHEET-MARK-CLOSED-SYMBOL**: A fully closed position (qty = 0) is not requested or priced during the settle pass; it appears neither in the marks cache nor the degraded set nor per-symbol freshness.

**SHEET-MARK-INTEGRATION**: Within a single cycle, the republish-then-settle sequence (write formulas, then read marks) guarantees the settle pass reads only recalculated (not mid-formula-write) cells.