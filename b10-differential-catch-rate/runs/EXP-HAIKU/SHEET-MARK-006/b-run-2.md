Looking at these three files, I can identify the EARS-style requirements enforced for transport failure during the marks read-back pass.

The key constraint is documented at lines 806–815 of `lib.rs` and enforced by the test at line 132–159 of `marks.rs`:

**Transport-Failure Boundary (Marks Settle Pass)**

When `SheetsViewClient::read_price_pass()` fails (workbook unreachable / offline), the `read_marks` function (lines 817–887) **SHALL propagate the error without producing a `MarksProduced` result**, and **SHALL NOT carry `prior` marks forward**. Rationale: emitting an empty or degraded marks set would nullify live positions incorrectly; the offline carry-forward is `runtime`'s responsibility — on `Err`, `runtime` retains its existing cached marks (with quote-epoch stamps) and re-injects them into the next replay.

**Settle-Pass Polling Semantics**

The settle pass SHALL poll `read_price_pass()` up to `cfg.max_polls` (default 8, constant at line 788) times. A symbol is settled when it is not `Transient` and not absent. If the loop exhausts `max_polls` before all symbols are settled, polling stops; still-transient symbols degrade to `TimedOut` (if no prior mark) or carry prior (if prior exists).

**Per-Symbol Mark Production**

- **Numeric reading**: convert `price_usd` to `Cents` via `round_half_to_even` (lines 362–385): scale to integer micro-cents (SCALE = 1_000_000), round once, divide by SCALE. A positive price rounding to ≤0 Cents is degraded `SubCent`. Non-finite (`NaN`, `±∞`) is degraded `Permanent`.
- **Transient reading**: if prior good mark exists, carry it (do not degrade); if no prior, degrade to `TimedOut`.
- **Permanent reading**: degrade immediately to `Permanent`, no prior carry.

**Mark Stamping**

Each `Mark` carries `quote_date` from `GOOGLEFINANCE` quote epoch (the `tradetime` of the price cell), not wall-clock read time.

**Degraded-Symbol Semantics**

A degraded symbol is absent from the `to_ledger_marks()` projection (line 341–346), causing ledger-core to degrade that symbol's unrealized value per-symbol, not zero it.

<output>
SHEET-MARK-TRANSPORT-FAILURE: When SheetsViewClient::read_price_pass() errors during the settle pass (workbook unreachable/offline), read_marks SHALL propagate Err and produce no MarksProduced — NOT an empty marks set (which would wrongly nullify positions). Runtime owns offline carry-forward: on Err, runtime retains its cached marks (with quote-epoch stamps) and re-injects them into next replay.

SHEET-MARK-POLL-BOUNDED: Settle pass polls up to cfg.max_polls (default 8) times. Symbol settled when not Transient and not absent. Exhausting max_polls stops polling; still-transient symbols degrade TimedOut (or carry prior if exists).

SHEET-MARK-NUMERIC-CONVERSION: Numeric price_usd → Cents via round_half_to_even: scale to integer micro-cents (SCALE 1M), round once, divide by SCALE. Positive price → ≤0 Cents = SubCent degrade. Non-finite (NaN/±∞) = Permanent degrade.

SHEET-MARK-TRANSIENT-CARRY: Transient reading + prior mark exists → carry prior (not degraded). Transient + no prior → degrade TimedOut.

SHEET-MARK-PERMANENT-NO-CARRY: Permanent reading → degrade Permanent immediately, no prior carry.

SHEET-MARK-QUOTE-EPOCH: Mark stamped with GOOGLEFINANCE quote_date (quote epoch), not wall-clock read time.

SHEET-MARK-DEGRADED-ABSENT: Degraded symbol absent from to_ledger_marks(), causing ledger-core per-symbol degradation.
</output>