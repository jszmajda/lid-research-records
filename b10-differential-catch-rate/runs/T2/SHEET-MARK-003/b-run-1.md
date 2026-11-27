**Requirements enforced — Transient price-cell handling during marks read-back (SHEET-MARK-*)**

**Ubiquitous:**
- The settle pass shall poll `SheetsViewClient::read_price_pass` on a pass separate from the tab write, tracking each requested symbol's latest reading across polls, bounded by `SettleConfig.max_polls` (default `8`).
- Settlement is reached when no requested symbol's latest reading is `Transient` or absent (`None`); the loop then stops without exhausting the poll budget (e.g., a `Permanent` reading settles the loop immediately, at fewer than `max_polls` calls).

**State-driven:**
- WHILE any requested symbol's latest reading is `Transient` or absent, the settle pass shall keep polling, incrementing the poll count each pass, until either all symbols settle or the poll count reaches `max_polls` exactly (never more).

**Event-driven — resolving a still-transient symbol at window close:**
- WHEN the bounded window elapses (poll count == `max_polls`) WHILE a symbol's latest reading is still `Transient`/absent AND a prior `Mark` exists for that symbol, the system shall carry that prior mark's `price_cents` and `quote_date` forward unchanged as this pass's mark, and shall NOT record the symbol as degraded.
- WHEN the bounded window elapses WHILE a symbol's latest reading is still `Transient`/absent AND no prior mark exists, the system shall record the symbol `Degraded(TimedOut)` and emit no mark for it.

**Unwanted behavior:**
- A carried-forward prior mark shall never be overwritten, nulled, or re-stamped with a new quote date — its original `quote_date` (from the cycle that produced it) persists across subsequent transient passes, including across cycle boundaries.
- A `Transient` reading shall never be treated as, or converted to, a zero/absent valuation when a prior mark exists.
- A terminal `Permanent` reading shall degrade the symbol immediately as `Degraded(Permanent)` with no mark and NO prior-mark carry-forward, even if a prior mark exists for that symbol (distinct from the transient-timeout carry rule).
- WHEN the underlying `read_price_pass` transport call itself errors (offline/unreachable), `read_marks` shall propagate the `Err` immediately and produce no `MarksProduced` at all (never an empty-but-Ok marks set); it shall not itself carry prior marks forward — retention of prior cached marks for re-injection is the caller's (runtime's) responsibility, not `read_marks`'s.

Files: `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs` (`read_marks`, lines 792–887), `{scratch}/.../sheets-view/tests/marks.rs`, `{scratch}/.../runtime/tests/cycle.rs`.