**EARS requirements enforced (price-reading classification in `price_to_cents` / `read_marks`, sheets-view):**

**Ubiquitous**
- The system shall classify every price-to-Cents conversion into exactly one of: a valid positive `Cents` mark, `Err(DegradeReason::SubCent)`, or `Err(DegradeReason::Permanent)` — never a silent pass-through.
- The system shall never produce a real zero or negative `Cents` mark; such a reading is always a degrade, never a value.

**Event-driven**
- WHEN `price_to_cents` receives a price reading, IF the raw `f64` is non-finite (`NaN`, `+∞`, or `−∞`), THEN the system shall return `Err(DegradeReason::Permanent)` immediately, without rounding.
- WHEN the raw price is finite, THE system shall scale it to an integer numerator via `price_usd × 100 × SCALE` (`SCALE = 1_000_000`) before rounding; IF this scaled intermediate is itself non-finite, THEN the system shall also return `Err(DegradeReason::Permanent)` (a second finiteness check after scaling).
- WHEN the scaled numerator is finite, THEN the system shall round it to whole cents exactly once via `round_half_to_even(numerator, SCALE)` — the project's single canonical rounding rule — with half-cent ties resolved to the nearest even cent (e.g., 1.005 → 1.00; 1.015 → 1.02).
- WHEN the rounded result is ≤ 0 (covers an exact `0.0` price, any negative price, and a positive sub-cent price that rounds down to 0), THEN the system shall return `Err(DegradeReason::SubCent)` rather than `Ok(Cents(0))` or a negative `Cents`.
- WHEN the rounded result is > 0, THEN the system shall return `Ok(Cents(value))`.

**State-driven (within `read_marks`, per symbol whose latest reading is `Numeric`)**
- WHILE the latest reading for a symbol is `Numeric`, IF `price_to_cents` returns `Err(SubCent)` or `Err(Permanent)`, THEN `read_marks` shall record that symbol in `degraded` with the returned reason, insert no entry in `marks`, and NOT carry forward any prior cached mark for it.

**Unwanted behavior**
- IF a symbol's numeric reading degrades (SubCent or Permanent), THEN the system shall not treat it like a `Transient` reading — no prior-mark carry-forward applies; the symbol is simply absent from produced marks (and thus from `to_ledger_marks`), degrading downstream per-symbol rather than substituting a fabricated zero/negative/stale value.