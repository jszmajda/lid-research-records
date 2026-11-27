**EARS requirements — price-reading non-positive/non-finite classification (`price_to_cents`, `sheets-view`)**

**Ubiquitous**
- SHEET-MARK-A: The system shall classify every price reading fed to `price_to_cents` into either a positive `Cents` mark or exactly one `DegradeReason` (`Permanent` or `SubCent`); it shall never produce a zero or negative `Cents` mark.

**Event-driven**
- SHEET-MARK-B: WHEN `price_to_cents` is called with a `price_usd` that is not finite (`NaN`, `+∞`, or `-∞`), the system shall return `Err(DegradeReason::Permanent)` immediately, without computing a cents value.
- SHEET-MARK-C: WHEN the intermediate scaled value `price_usd × 100.0 × 1_000_000` (computed for a finite `price_usd`) is itself not finite (float overflow), the system shall return `Err(DegradeReason::Permanent)`.
- SHEET-MARK-D: WHEN `price_to_cents` is called with a finite `price_usd`, the system shall compute `numerator = round(price_usd × 100 × 1_000_000)` and `cents = round_half_to_even(numerator, 1_000_000)`; IF `cents ≤ 0`, the system shall return `Err(DegradeReason::SubCent)`; otherwise it shall return `Ok(Cents(cents))`.
- SHEET-MARK-E: WHEN `read_marks` receives a `PriceReading::Numeric` for a symbol and `price_to_cents` returns `Err(reason)`, the system shall insert that symbol into `degraded` with `reason` and shall NOT insert any entry — fresh or prior-carried — into `marks` for that symbol on this pass.

**Unwanted behavior**
- SHEET-MARK-F: IF a positive `price_usd` rounds to 0 cents (e.g. `0.0001`), THEN the system shall NOT record it as a real zero mark; it shall degrade as `SubCent`, so value is never silently understated.
- SHEET-MARK-G: IF `price_usd` is exactly `0.0` or negative (e.g. `-5.0`), THEN the system shall NOT produce a zero or negative mark; it shall degrade as `SubCent` (not `Permanent` — non-positive numeric values are distinct from non-finite values).

**Tie-break / boundary (pinned by tests)**
- SHEET-MARK-H: The cents conversion shall break exact half-cent ties by round-half-to-even, not round-half-up: `1.005` → `Cents(1_00)`; `1.015` → `Cents(1_02)`.
- SHEET-MARK-I: Ordinary exact-cent prices convert without rounding drift: `200.0` → `Cents(200_00)`; `150.25` → `Cents(150_25)`.

**Classification summary (state boundary)**
- Non-finite input (`NaN`, `±∞`) or non-finite intermediate → `DegradeReason::Permanent`.
- Finite input yielding `cents ≤ 0` (zero, negative, or positive-rounds-to-zero) → `DegradeReason::SubCent`.
- Finite input yielding `cents > 0` → `Ok(Cents(cents))`.

Files: `crates/sheets-view/src/lib.rs` (`price_to_cents`, lines ~349–385; `read_marks`, lines ~847–869), `crates/sheets-view/tests/marks.rs` (lines 62–129).