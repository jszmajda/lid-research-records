**EARS-style requirements for transport failure during marks read-back pass:**

**SHEET-MARK-OFFLINE-001: Transport Failure Error Propagation**
On transport failure (workbook unreachable/offline), `read_marks()` propagates the error immediately via the `?` operator in the polling loop (`let pass = client.read_price_pass()?;`). Returns `Err(ViewError)`, produces no `MarksProduced`. Does NOT emit an empty marks set (which would masquerade as "all symbols degraded" and null live positions).

**SHEET-MARK-OFFLINE-002: Carry-Forward Responsibility**
Transport failure carry-forward is `runtime`'s responsibility, not `sheets-view`'s. On error, `runtime` retains its existing cached marks (with their GOOGLEFINANCE quote-epoch stamps) and re-injects them into the next replay, keeping kernels using last-known marks rather than experiencing a gap with all symbols degraded.

**SHEET-MARK-SETTLE-003: Bounded Polling Window**
Settle pass polls `read_price_pass()` in a loop (default `SettleConfig.max_polls = 8`) until either: (a) every requested symbol is numeric-or-terminally-errored (settled), or (b) poll count reaches `max_polls`. No infinite polling.

**SHEET-MARK-SETTLE-004: Per-Symbol Price Classification**
Each symbol reading is one of: `Numeric { price_usd, quote_date }` (settled), `Transient` (temporary #N/A/Loading—retry), or `Permanent` (terminal ticker-form mismatch—no retry). Quote dates are GOOGLEFINANCE quote epochs (not wall-clock).

**SHEET-MARK-SETTLE-005: Price-to-Cents Conversion (Half-to-Even, Sub-Cent Anomaly)**
USD price (float boundary) → `price_usd × 100` via integer scaling to micro-cents (`×1e6`), rounded via `round_half_to_even`. Non-finite prices (NaN, ±∞) degrade `Permanent`. Non-positive prices (≤ 0.0) and positive prices rounding to 0 Cents both degrade `SubCent`—never a zero mark (value never silently understated).

**SHEET-MARK-SETTLE-006: Transient Retry with Prior Carry**
Symbol reading `Transient` after bounded window: if prior good mark exists, carry it forward (no degrade). If no prior mark, degrade `TimedOut`, no mark produced.

**SHEET-MARK-SETTLE-007: Permanent Error, No Prior Carry**
Symbol reading `Permanent`: degrade immediately to `Permanent`, do NOT carry prior mark (terminal error, not transient retry scenario).

**SHEET-MARK-SETTLE-008: Degraded Symbol Omission**
Degraded symbols absent from ledger marks map injected into replay (enabling per-symbol degradation in ledger-core). Good marks present, degraded omitted.