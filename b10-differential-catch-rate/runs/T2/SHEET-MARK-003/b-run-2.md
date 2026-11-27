**Reconstructed EARS requirements — SHEET-MARK (transient non-numeric price-cell handling during read-back)**

**SHEET-MARK-a (State-driven).** While a requested symbol's latest settle-pass reading is `Transient` or absent from the current poll, the system shall treat the symbol as *not yet settled* and continue polling `read_price_pass` rather than resolving it.

**SHEET-MARK-b (Ubiquitous).** The settle pass shall poll `read_price_pass` until every requested symbol's latest reading is numeric or terminally-errored (`Permanent`), or until exactly `SettleConfig.max_polls` polls have elapsed, whichever occurs first. When no symbol ever settles, the loop performs exactly `max_polls` reads — no more, no fewer (pinned by tests: `max_polls=3` → 3 reads; `max_polls=4` → 4 reads).

**SHEET-MARK-c (State-driven).** While a symbol is still `Transient`/absent when the bounded window elapses, and a prior cached `Mark` exists for that symbol, the system shall carry the prior mark forward **unchanged** — identical `price_cents` and identical `quote_date` (not the current read time, not a null/refreshed stamp) — into this cycle's produced marks, and shall NOT record the symbol as degraded.

**SHEET-MARK-d (Unwanted behavior).** If a symbol is still `Transient`/absent when the bounded window elapses and no prior cached mark exists for it, then the system shall record the symbol as degraded with reason `TimedOut` and shall produce no mark for it (the symbol is absent from `marks`, present only in `degraded`).

**SHEET-MARK-e (Ubiquitous, normalization).** A symbol absent from a given poll's `PricePass` (never reported this pass) is normalized identically to an explicit `Transient` reading for settlement and resolution purposes — both remain pollable and both resolve via carry-forward-or-`TimedOut` at window end.

**SHEET-MARK-f (Unwanted behavior, tie-break boundary).** A terminal `Permanent` reading is never eligible for prior-mark carry-forward, even when a prior mark exists — it always degrades immediately as `Permanent` (distinct from `TimedOut`), settling the loop without exhausting `max_polls`. This is the boundary that separates transient (retry-then-carry) from terminal (never-carry) non-numeric readings.

**SHEET-MARK-g (Ubiquitous).** A degraded symbol (whether `TimedOut` or `Permanent`) is never represented as a zero or otherwise fabricated mark — omission from the produced marks map is the sole representation of "no current price."