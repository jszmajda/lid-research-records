**EARS requirements enforced by `price_to_cents` (and its `read_marks` call site) for the numeric-USD-price → integer-Cents mark conversion:**

1. **(Ubiquitous)** The system shall convert a settled numeric USD price reading to Cents by scaling to micro-cents with `SCALE = 1_000_000`: compute `numerator = round(price_usd × 100 × SCALE)` as an integer, then derive the final cent value via `round_half_to_even(numerator, SCALE)` — the project's single canonical rounding function — never any other rounding path.

2. **(Ubiquitous)** Tie-breaking at exactly a half-cent shall use round-half-to-even ("banker's rounding"): the scaled value rounds to whichever neighboring integer cent is even. Pinned by test: `1.005 → 100¢` (100 is even), `1.015 → 102¢` (102 is even). Exact-cent inputs pass through unchanged (`200.0 → 20000¢`, `150.25 → 15025¢`).

3. **(Ubiquitous)** The only floating-point arithmetic is the `price_usd × 100 × SCALE` multiplication (the float-to-integer boundary); the cent decision itself is made exactly once, in integer arithmetic.

4. **(Unwanted behavior)** If `price_usd` is non-finite (`NaN`, `+∞`, or `-∞`) — checked both before and after the `×100×SCALE` multiplication — the system shall NOT produce a mark and shall return `Err(DegradeReason::Permanent)`.

5. **(Unwanted behavior)** If the computed cents value is `≤ 0` — covering an exact `0.0` price, any negative price, or a positive price that rounds down to `0` Cents — the system shall NOT produce a zero or negative mark and shall instead return `Err(DegradeReason::SubCent)`, since a real value must never be silently understated as zero.

6. **(Event-driven)** When a settle-pass reading is `Numeric{price_usd, quote_date}` and `price_to_cents` returns `Ok(cents)`, `read_marks` shall record a fresh `Mark{price_cents: cents, quote_date}` for that symbol.

7. **(Event-driven)** When `price_to_cents` returns `Err` for a `Numeric` reading, `read_marks` shall record that symbol as degraded with the returned reason (`SubCent` or `Permanent`) and shall NOT substitute any prior cached mark — prior-mark carry-forward applies only to `Transient`/absent readings, never to a numeric value that failed conversion.

Files read: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs`, `{scratch}/audit-baseline/crates/sheets-view/tests/marks.rs`