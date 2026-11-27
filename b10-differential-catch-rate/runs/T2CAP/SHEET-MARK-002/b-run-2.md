SHEET-MARK-CONV — Price-to-cents conversion (`price_to_cents`)

**[Ubiquitous]** The system SHALL convert a numeric USD price reading into an integer `Cents` mark by scaling `price_usd × 100 × 1_000_000` in f64, rounding that product to the nearest integer numerator, then folding the numerator down to cents over the denominator `1_000_000` as a single integer decision, so the scaled-integer fold — not the float's own rounding — decides the cent.

**[Ubiquitous]** The fold SHALL round half **up**: for numerator `n` and denominator `d`, the result is `n.div_euclid(d)` when `2 × n.rem_euclid(d) < d`, otherwise `n.div_euclid(d) + 1`. Euclidean division/remainder SHALL be used, so a tie rounds toward `+∞` for negatives too (never "away from zero").

**[Ubiquitous]** Conversion SHALL be the single rounding site for price→`Cents` and SHALL return `Result<Cents, DegradeReason>`; a `Cents` value is produced only for a strictly positive result.

**[Event-driven]** WHEN a numeric reading yields a fold result `> 0`, the system SHALL return `Ok(Cents(result))` — e.g. `200.0 → Cents(20000)`, `150.25 → Cents(15025)`, `1.005 → Cents(101)`, `1.015 → Cents(102)`.

**[Unwanted]** IF the reading is non-finite (`NaN`, `+∞`, `−∞`), OR the scaled product `price_usd × 100 × 1e6` is non-finite (overflow of a finite input), THEN the system SHALL return `Err(DegradeReason::Permanent)` and SHALL NOT produce a mark.

**[Unwanted]** IF the fold result is `<= 0` — a strictly positive price that rounds to 0 cents (e.g. `0.0001`), an exact `0.0`, or a negative price (e.g. `-5.0`) — THEN the system SHALL return `Err(DegradeReason::SubCent)`; a sub-cent positive price SHALL be treated as a degraded anomaly, never a real zero mark, and no zero or negative mark SHALL ever be produced (value is never silently understated).

**[Event-driven]** WHEN the settle pass converts a `PriceReading::Numeric` for a symbol, THEN on `Ok` the system SHALL record `Mark { price_cents, quote_date }` in `marks` using the reading's own `GOOGLEFINANCE` quote date (not wall-clock read time), and on `Err(reason)` SHALL record the symbol in `degraded` with that `reason` and SHALL NOT insert any mark for it — a numeric-but-degraded reading SHALL NOT fall back to the prior cached mark.

**[Ubiquitous]** A symbol present in `degraded` SHALL be ABSENT from the projected `ledger_core::Marks` map, so downstream replay degrades that symbol per-symbol (unrealized `None`, not zero).