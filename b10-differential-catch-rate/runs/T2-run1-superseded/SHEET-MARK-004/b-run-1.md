**Reconstructed EARS requirements — cached-mark timestamping (SHEET-MARK-\*)**

**Ubiquitous:**
1. The system shall stamp every settled numeric mark's timestamp with GOOGLEFINANCE's own per-symbol quote date, never the wall-clock time at which the read-back poll occurred.
2. The quote-date companion value shall be represented as the kernel `Date` type: an integer count of days since epoch 1970-01-01, identical to the ledger's date representation — not a formatted/locale-dependent date string.
3. `read_marks` shall never itself generate, read, or inject a wall-clock timestamp; the sole source of a Mark's `quote_date` is the value carried on a `PriceReading::Numeric` reading, copied verbatim.

**Event-driven:**
4. When rendering the Quote Date formula for a symbol's ticker, the system shall compute `INT(GOOGLEFINANCE(ticker,"tradetime")) − DATE(1970,1,1)` and render it via `TEXT(…,"0")`, producing a digits-only integer string invariant across locales (GOOGLEFINANCE's raw `tradetime` is locale-formatted and unparseable without locale rules).
5. When a settle-pass poll yields `PriceReading::Numeric{price_usd, quote_date}` for a symbol whose price also converts successfully to `Cents`, the system shall stamp the produced `Mark.quote_date` with exactly that reading's `quote_date` — no truncation, adjustment, or substitution.
6. When a symbol is still `Transient` (or absent from every poll) after the bounded settle window (`SettleConfig.max_polls`, default 8) elapses, and a prior cached `Mark` exists for that symbol, the system shall carry the prior `Mark` forward unchanged — including its previously-stamped `quote_date` — rather than manufacturing a new stamp or clearing the old one.

**Unwanted behavior:**
7. If the Quote Date formula's underlying GOOGLEFINANCE call is loading or errored, then the formula shall evaluate (via `IFERROR`) to the empty string `""`, never propagating the sheet error or a partial value.
8. If a symbol's reading is `Permanent` (terminal non-numeric error), then the system shall record it degraded (`DegradeReason::Permanent`) with no `Mark` and no `quote_date` — the prior stamp is NOT carried forward (unlike the transient case).
9. If a symbol stays `Transient`/absent past the bounded window and no prior `Mark` exists, then the system shall record it degraded (`DegradeReason::TimedOut`) with no `Mark` and no `quote_date`.
10. If a numeric price converts to ≤0 `Cents` (sub-cent or non-positive), then the system shall record the symbol degraded (`SubCent`) with no `Mark` — even though a valid `quote_date` was read, it is discarded rather than stamped without a price.
11. If the underlying settle read transport itself fails, then `read_marks` shall propagate `Err` and produce no `MarksProduced`/timestamps at all, rather than emitting empty/degraded stamps for every symbol.