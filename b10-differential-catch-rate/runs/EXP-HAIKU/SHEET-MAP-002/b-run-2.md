**Mark Read-Back Keying & Duplicate Symbol Handling Requirements**

**SHEET-MARK-001**: The Positions tab rendering enforces exactly one row per symbol. The implementation includes a defensive `DuplicateSymbolRow(Symbol)` error guard checked via `BTreeSet` insertion; violation returns `ViewError::DuplicateSymbolRow` with the duplicate symbol. The guard is structurally unreachable through the real Map-keyed API but asserts the one-row-per-symbol invariant required by the read-back keying design.

**SHEET-MARK-002**: Mark read-back is keyed by symbol row identity, not row index or tab position. The settle pass tracks readings per symbol in a `BTreeMap<Symbol, PriceReading>` indexed by symbol; symbols may be absent or transient across polls as sheets recalculates, and keying by symbol ensures consistent tracking across retries.

**SHEET-MARK-SETTLE-003**: The settle pass polls `read_price_pass()` in a bounded-retry loop until one condition: every requested symbol reaches a terminal state (numeric reading or Permanent error) OR `polls >= max_polls`. Default `max_polls = 8`. Transient readings (`#N/A`, `Loading...`) and symbol absences trigger retries; settlement succeeds immediately if all symbols become terminal or the window elapses.

**SHEET-MARK-PRICE-TO-CENTS-004**: Numeric prices convert to `Cents` via `price_to_cents(price_usd)` using two-stage rounding: scale price to micro-cents (`price_usd × 100 × 1_000_000` as f64), round via `pt_core::round_half_to_even(numerator, SCALE: 1_000_000)`, then cast to `Cents`. Non-finite prices (NaN, ±∞) degrade `DegradeReason::Permanent`. Non-positive prices (≤0.0) or prices rounding to ≤0 Cents degrade `DegradeReason::SubCent`. Only `cents > 0` yields a valid `Mark`.

**SHEET-MARK-TRANSIENT-CARRY-005**: A Transient or absent symbol carries the prior good cached mark forward, preserving live positions across a transient `#N/A` window. Only if no prior mark exists does a still-transient symbol degrade to `DegradeReason::TimedOut` after `max_polls` elapsed.

**SHEET-MARK-PERMANENT-NO-CARRY-006**: A Permanent reading (invalid ticker, syntax error) degrades `DegradeReason::Permanent` with no prior-mark carry-forward. Permanent errors override cached values; they are not retried.

**SHEET-QUOTE-DATE-FORMULA-007**: The Quote Date formula encodes the `GOOGLEFINANCE` trade date as days since 1970-01-01 kernel epoch: `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")`. The `INT()` truncates trade time to date serial; subtraction re-bases to epoch days; `TEXT(...,"0")` renders as digits-only (locale-invariant). A transient or errored quote renders empty string.

**SHEET-MARK-OFFLINE-PROPAGATE-008**: On transport failure (`read_price_pass()` error), the settle function propagates `Err(ViewError)` and produces no `MarksProduced`; it does NOT silently emit an empty marks set or auto-carry prior. The offline carry-forward is `runtime`'s responsibility: on `Err`, runtime retains its cached marks (with quote-epoch stamps) and re-injects into the next replay.