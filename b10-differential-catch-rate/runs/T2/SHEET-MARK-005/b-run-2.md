**Reconstructed EARS requirements — sheets-view degraded-mark / offline behavior (SHEET-MARK-*)**

**Ubiquitous**
- U1: The system shall convert a settled numeric price reading to Cents via `round_half_to_even(price_usd × 100)` (scaled through a ×1,000,000 integer numerator), the project's single canonical rounding site — e.g. 1.005→1.00, 1.015→1.02 (banker's rounding at exact half-cent ties).
- U2: A positive price that rounds to 0 Cents shall be treated as a degraded anomaly (`DegradeReason::SubCent`), never emitted as a real zero mark.
- U3: A non-positive numeric reading (0.0 or negative) shall also degrade as `SubCent`.
- U4: A non-finite numeric reading (NaN, +∞, −∞) shall degrade as `DegradeReason::Permanent`.
- U5: Each settled `Mark` shall be stamped with GOOGLEFINANCE's own quote date (from the reading), never wall-clock read time.
- U6: A symbol recorded degraded (in `MarksProduced.degraded`) shall be absent from the projected `ledger_core::Marks` map (`to_ledger_marks`) — never present with a zero or sentinel value.

**State-driven**
- S1: WHILE any requested symbol's latest reading is `Transient` or unread, the system shall continue polling `read_price_pass`, up to `SettleConfig.max_polls` times (default 8), tracking only the latest reading per symbol.

**Event-driven**
- E1: WHEN the poll bound (`max_polls`) elapses with a symbol still `Transient`/unread AND a prior cached mark exists for it, the system shall carry the prior mark forward unchanged into `marks` and shall NOT record it degraded.
- E2: WHEN the poll bound elapses with a symbol still `Transient`/unread AND no prior mark exists, the system shall degrade the symbol with reason `TimedOut`.
- E3: WHEN a symbol's reading is `Permanent`, the system shall degrade it immediately with reason `Permanent`, without consulting or carrying forward any prior mark, and this settles the loop for that symbol without necessarily exhausting the poll window.

**Unwanted-behavior**
- N1: IF the underlying `read_price_pass` call itself errors (transport failure / workbook offline), THEN `read_marks` shall propagate the `Err` and produce no `MarksProduced` — it shall NOT silently emit an empty/all-degraded marks set, and shall NOT itself substitute `prior` as output (offline carry-forward is the caller's/runtime's responsibility, out of this function's contract).