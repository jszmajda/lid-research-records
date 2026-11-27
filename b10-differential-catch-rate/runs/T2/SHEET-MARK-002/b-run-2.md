**Price → Cents conversion — reconstructed EARS requirements (concern: `price_to_cents`, `sheets-view/src/lib.rs`)**

**Ubiquitous:**
1. The system shall treat every settled numeric price reading as denominated in USD and convert it to `Cents` via `round_half_to_even(price_usd × 100)` — the project's single canonical rounding rule, applied nowhere else for this conversion.
2. The conversion shall cross the float boundary by scaling `price_usd × 100` by a fixed integer `SCALE = 1_000_000` (micro-cents), rounding that scaled `f64` to an integer numerator, then deciding the final cent value by applying `round_half_to_even(numerator, SCALE)` — so the half-to-even tie-break is decided by the integer helper, never by `f64`'s own rounding.
3. On success the system shall return the result as `Ok(Cents)`, a signed `i64`.

**State-driven (tie-break, pinned by test):**
4. While the scaled price lands exactly on a half-cent boundary, the system shall round to the nearest *even* cent: `1.005` → `1.00` (100, even) and `1.015` → `1.02` (102, even).

**Unwanted behavior:**
5. If the numeric price is non-finite (`NaN`, `+∞`, or `-∞`), the system shall reject the conversion, returning `Err(DegradeReason::Permanent)`, and shall produce no mark.
6. If the numeric price is zero or negative, the system shall reject the conversion, returning `Err(DegradeReason::SubCent)`, and shall produce no mark — never a real zero or negative mark.
7. If a strictly positive price rounds to exactly 0 `Cents`, the system shall reject the conversion, returning `Err(DegradeReason::SubCent)`, rather than treating it as a genuine zero mark (value must never be silently understated).

**Downstream propagation (from `read_marks`, exercised by the same test file against this concern):**
8. When `price_to_cents` returns `Err`, the system shall record the symbol as degraded with that `DegradeReason` and shall not insert any entry into the produced marks for that symbol (no fallback/prior-carry on a `SubCent` or `Permanent` result from a *numeric* reading — prior-carry applies only to `Transient` readings, a distinct code path).

Constants pinned: `SCALE = 1_000_000`; rounding site = `pt_core::round_half_to_even`; multiplier = `100` (USD dollars → cents). No currency-code check or non-USD handling exists — USD is assumed, not verified.