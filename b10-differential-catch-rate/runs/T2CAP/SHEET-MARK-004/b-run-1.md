SHEET-MARK-QD (quote-date stamping of cached marks)

**U (ubiquitous):** The system shall stamp every settled per-symbol mark with a `quote_date` of type `Date` (kernel epoch = days since 1970-01-01) taken from GOOGLEFINANCE's own quote date, never from wall-clock read time. A `Mark` is exactly `(price_cents: Cents, quote_date: Date)`.

**U:** The system shall publish, for each Positions row, a `Quote Date` formula column (column M, last column of `POSITIONS_HEADER`) alongside the `Price` GOOGLEFINANCE column (column E), as the locale-proof companion the read-back parses.

**U:** The `Quote Date` cell shall be the live formula, exactly:
`=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")`
where TICKER is the alias-resolved ticker, quoted. Normalization is pinned: `INT(...)` truncates trade time to its date serial; subtracting `DATE(1970,1,1)` re-bases the sheet serial to the kernel `Date` epoch; `TEXT(...,"0")` renders digits-only so every locale formats identically (the settle pass reads through the plain values API, and raw `tradetime` would be a locale-dependent datetime).

**Ev (event-driven / unwanted-behavior):** When the quote is loading or errored, the `Quote Date` formula shall evaluate to the empty string (`IFERROR(...,"")`), never a spilled error value.

**Ev:** When a settle-pass reading for a symbol is `Numeric { price_usd, quote_date }` and `price_to_cents(price_usd)` succeeds, the system shall emit `Mark { price_cents, quote_date }` carrying that reading's `quote_date` verbatim — no substitution, no re-stamping (test pins `Date(19_100)` surviving unchanged into the produced mark).

**Ev:** When a symbol is still `Transient` after the bounded window (`SettleConfig.max_polls`, default 8) and a prior mark exists, the system shall carry the prior mark forward **unmodified, including its original `quote_date`** — the stamp is not refreshed to the current pass (test: prior `Mark { Cents(180_00), Date(19_100) }` returned identically).

**Unw:** The system shall never produce a mark stamped with the current pass's time for a symbol whose price was not settled this pass; a carried-forward mark keeps its stale quote epoch so downstream consumers can see the mark's true age.

**Unw:** The system shall never stamp a degraded symbol: `SubCent`, `Permanent`, and `TimedOut`-with-no-prior symbols enter `degraded` with no `Mark`, hence no quote_date, and are absent from `to_ledger_marks()`.

**Unw:** On transport failure the system shall propagate `Err(ViewError)` and produce no `MarksProduced`, so no stamps are fabricated; offline carry-forward of stamped marks is `runtime`'s responsibility.

Files: `{scratch}/audit-U-MARK-004/crates/sheets-view/src/lib.rs` (`quote_date_formula`, `Mark`, `read_marks`), `.../tests/marks.rs` (`mark_stamped_with_googlefinance_quote_date_not_wall_clock`, `transient_keeps_prior_mark_and_retries_degrades_only_after_window`).