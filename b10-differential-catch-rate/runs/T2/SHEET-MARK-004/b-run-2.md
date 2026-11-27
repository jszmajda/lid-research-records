**EARS requirements — cached-mark timestamping (sheets-view)**

**Ubiquitous**
1. The system shall stamp every settled per-symbol `Mark` with GOOGLEFINANCE's own quote date (`quote_date`), never the wall-clock time the settle pass ran.
2. The Quote Date companion formula for a resolved ticker shall be exactly `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`.
3. The Quote Date value shall be expressed as an integer count of days since 1970-01-01 — matching the kernel `Date` epoch — by truncating `tradetime` to its date serial (`INT(...)`) and subtracting `DATE(1970,1,1)`, rendered through `TEXT(...,"0")` as a digits-only string so it parses identically under any sheet locale.
4. While the price quote is loading or in a terminal error state, the Quote Date formula shall evaluate to the empty string `""` (via `IFERROR`).

**Event-driven**
5. When a settle-pass reading for a symbol is `Numeric`, the read-back shall stamp that symbol's produced `Mark.quote_date` with the reading's own `quote_date` field (never derived from read time).
6. When a symbol's reading is `Transient` or absent from the pass at the point the bounded poll window elapses (`SettleConfig.max_polls`, default 8) AND a prior `Mark` exists for that symbol, the read-back shall carry the prior `Mark` forward unchanged — including its original `quote_date` — rather than assigning any new timestamp, and shall NOT record the symbol as degraded.
7. When a symbol's reading is `Transient`/absent at window elapse AND no prior `Mark` exists, the read-back shall record the symbol degraded (`TimedOut`) with no `Mark` and therefore no `quote_date`.
8. When a symbol's reading is `Permanent` (terminal, e.g. ticker-form mismatch), the read-back shall record the symbol degraded (`Permanent`) with no `Mark`/`quote_date`, regardless of any prior mark — permanent errors never carry a prior timestamp forward.
9. When the settle loop reaches a state where every requested symbol is numeric-or-terminally-errored before `max_polls` is reached, polling shall stop early (no further reads, no stamp changes).

**Unwanted behavior**
10. If the numeric price fails cents conversion (non-positive → `SubCent`, non-finite → `Permanent`), the read-back shall not produce a `Mark` for that symbol on this pass — no timestamp is assigned even though a `Numeric` reading with a `quote_date` was received.