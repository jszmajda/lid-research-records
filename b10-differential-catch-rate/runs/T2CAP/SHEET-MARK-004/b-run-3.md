SHEET-MARK-QD (quote-date stamping of cached marks)

Ubiquitous
1. The system shall stamp every settled per-symbol mark with a `quote_date` (`Mark { price_cents: Cents, quote_date: Date }`) — a `Date` in days since 1970-01-01 — and shall never stamp a mark with wall-clock read time; the stamp is the per-symbol quote epoch carried into the marks cache.
2. The Positions tab shall publish, alongside the `Price` GOOGLEFINANCE formula (column E), a companion `Quote Date` formula cell as the last column (M) of `POSITIONS_HEADER`, of exact form `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`, where `<ticker>` is the alias-resolved ticker, double-quoted.
3. Both `Price` and `Quote Date` shall be `Cell::Formula` (live), never engine values.

Rationale pinned by the encoding: the settle pass reads back formatted values, so the raw locale-dependent `tradetime` is normalized by truncating to date serial (`INT`), re-basing to the kernel `Date` epoch (`- DATE(1970,1,1)`), and rendering digits-only (`TEXT(…,"0")`); `IFERROR` yields `""` while the quote is loading or errored.

Event-driven
4. When a settle-pass reading for a symbol is `Numeric { price_usd, quote_date }` and `price_to_cents(price_usd)` succeeds, the system shall record `marks[symbol] = Mark { price_cents, quote_date }`, carrying that reading's own `quote_date` verbatim (no substitution, no clamping, no per-pass shared timestamp) — e.g. reading `quote_date = Date(19_100)` yields a mark stamped `Date(19_100)`.
5. When a symbol's reading is `Transient` (or absent) after the bounded window and a `prior` mark exists, the system shall carry that prior mark forward **unchanged, including its original `quote_date`** (e.g. `Cents(180_00) @ Date(19_100)` stays `Date(19_100)`), and shall not record it degraded.

Unwanted behavior
6. If a numeric reading fails conversion (`SubCent` for ≤0/sub-cent, `Permanent` for non-finite), or a reading is `Permanent`, or is `Transient` past the window with no prior mark, the system shall record the symbol in `degraded` with no mark — so no `quote_date` stamp is emitted for a degraded symbol, and the symbol is absent from `to_ledger_marks()`.
7. If `read_price_pass` errors, `read_marks` shall propagate `Err(ViewError)` and emit no `MarksProduced` (no re-stamping of prior marks at this layer); offline carry-forward of stamped marks is `runtime`'s.

Boundary constants: `DATA_START_ROW = 2` (frozen header row 1); `SettleConfig::default().max_polls = 8`. `Mark` is `Copy`/`Eq`, so equality includes the `quote_date` stamp.