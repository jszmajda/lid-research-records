**Requirements enforced — cached-mark timestamping (sheets-view)**

1. **[Ubiquitous]** The system shall stamp every cached per-symbol `Mark` with a `quote_date: Date` field representing `GOOGLEFINANCE`'s own quote date — never the wall-clock time the settle pass ran.

2. **[Ubiquitous]** The system shall render each symbol's Quote Date cell as the formula `=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")`: truncate `tradetime` to its date serial via `INT()`, re-base to days-since-1970-01-01 (the kernel `Date` epoch) by subtracting `DATE(1970,1,1)`, and render via `TEXT(…,"0")` as a digits-only string parseable identically in every locale.

3. **[Unwanted behavior]** If the `GOOGLEFINANCE` tradetime read is loading or errored, then the Quote Date formula shall evaluate to the empty string `""` (via `IFERROR`), not a wall-clock fallback, an error literal, or any other placeholder.

4. **[Event-driven]** When the settle pass's latest reading for a symbol is `PriceReading::Numeric { price_usd, quote_date }`, the system shall stamp the resulting `Mark.quote_date` with that reading's own `quote_date` value (not the current pass's clock time), paired with the converted `price_cents`.

5. **[State-driven]** While a symbol's reading is `Transient` or absent from the latest pass (within the bounded `max_polls` window), the system shall carry forward the prior cached `Mark` — both `price_cents` and `quote_date` unchanged — rather than refreshing the timestamp or price for that cycle.

6. **[Unwanted behavior]** If a symbol stays `Transient`/absent through every poll until `max_polls` elapses and no prior `Mark` exists for it, then the system shall record it degraded with reason `TimedOut`, producing no `Mark` and no timestamp (never a synthesized/wall-clock stamp).

7. **[Unwanted behavior]** If a symbol's reading is `Permanent` (terminal non-numeric error), then the system shall record it degraded with reason `Permanent`, producing no `Mark` — regardless of any prior cached mark/timestamp, which is discarded, not carried forward (terminal errors never carry, only transients do).

8. **[Unwanted behavior]** If the underlying `read_price_pass` call itself errors (transport/offline failure), then `read_marks` shall propagate `Err` and produce no `MarksProduced` at all — it shall not itself carry `prior` forward or emit an empty marks set for any symbol's timestamp.

9. **[Ubiquitous]** The settle pass shall be a distinct read performed strictly after the tab write returns (never inline with formula publish), so no quote-date reading is taken mid-recalculation.