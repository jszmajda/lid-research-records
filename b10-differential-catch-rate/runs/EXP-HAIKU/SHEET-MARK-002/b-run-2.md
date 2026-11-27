**SHEET-MARK-001: USD Price to Integer Cents Conversion**

Convert a numeric USD price reading (f64) to integer `Cents` using half-up rounding over a scaled-integer fold, never float-precision rounding. Input boundary is the float; the cent is decided by integer arithmetic.

- **Scaling & folding:** Multiply input by 100 × 10^6 to a scaled integer numerator; fold to cents via `floor(numerator / 10^6 + 0.5)`, rounding half-cent ties up (not to-even).
- **Non-finite rejection:** `NaN` or `±∞` → `Err(DegradeReason::Permanent)`.
- **Non-positive rejection:** Price ≤ 0.0 (including exact 0.0) → `Err(DegradeReason::SubCent)`.
- **Positive underflow rejection:** Positive price that rounds to 0 `Cents` → `Err(DegradeReason::SubCent)` (anomaly, never a valid zero mark).
- **Success:** Positive price rounding to positive `Cents(n)` where n > 0.

**SHEET-MARK-002: Mark Structure & Quote-Date Binding**

A settled per-symbol `Mark` is an immutable pair: `{price_cents: Cents, quote_date: Date}`. The quote date is **always** the GOOGLEFINANCE-returned trade-date epoch (days since 1970-01-01), never the wall-clock settle-pass read time. The date is stamped atomically with the price on success.

**SHEET-MARK-003: Settle Pass Polling & Bounded Retry**

Read marks on a separate settle pass (never inline with formula write). Poll `read_price_pass()` bounded by `SettleConfig.max_polls` (default 8). Settle when all requested symbols are numeric-or-terminal; if a symbol remains transient after max_polls, degrade it.

**SHEET-MARK-004: Transient Symbol Carry-Forward**

A symbol that reads transient (`#N/A`, `Loading...`) is **not overwritten** — if a prior good `Mark` exists, keep it forward (retain both `price_cents` and prior `quote_date`); if no prior exists and symbol stays transient past the bounded window, record degraded `TimedOut` (no mark). Prior-mark carry-forward applies **only** to transient; a permanent error always overwrites.

**SHEET-MARK-005: Degradation Semantics**

Degraded symbols are **absent** from the per-symbol ledger-marks map injected into replay, enabling per-symbol unrealized degradation in ledger-core. No partial carry-forward: Permanent errors never use prior; transport failures (`read_price_pass` I/O error) propagate `Err` and produce no marks (runtime retains its cache offline).

{scratch}/audit-H-MARK-002/crates/sheets-view/src/lib.rs:362–385 (price_to_cents function), :391–399 (round_half_up), :831–901 (read_marks settle pass)