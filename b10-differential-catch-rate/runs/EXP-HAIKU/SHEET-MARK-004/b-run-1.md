# SHEET-MARK-TIMESTAMP Requirements

Cached marks are timestamped with `GOOGLEFINANCE`'s per-symbol quote date (tradetime), not the wall-clock moment of the settle-pass read.

## Timestamp Source (event-driven)

Each settled numeric price is paired with its `GOOGLEFINANCE`-computed quote date (`tradetime`). The settle pass reads back the companion `Quote Date` formula cell, which isolates the date component from the raw tradetime string via:

```
=IFERROR(TEXT(INT(GOOGLEFINANCE("TICKER","tradetime"))-DATE(1970,1,1),"0"),"")
```

The formula computes days elapsed since 1970-01-01 (the kernel `Date` epoch) as an integer, then renders it as a digits-only text string (every locale parses identically). This value becomes the `Mark.quote_date` field — an epoch-relative day count, type `Date`.

## Timestamp Immutability (state-driven)

Once a mark is produced with its quote date (numeric settlement), that date travels with the mark:

- **Numeric reading on settle pass**: The mark is created with its GOOGLEFINANCE quote_date exactly as read back from the sheet. This date is immutable and specific to that symbol's quote.
- **Transient retry (prior mark carry-forward)**: If a symbol stays `Transient` (Loading/transient #N/A) past the bounded poll window (`SettleConfig.max_polls`), the prior good cached mark is carried forward unchanged — including its original quote_date. The new read attempt does not overwrite the timestamp.
- **Permanent error (no carry)**: A terminal price error (`Permanent` #N/A) degrades the symbol and produces no mark; no prior mark is carried, hence no prior quote_date survives.

## Polling Window and Timestamp Semantics (state-driven)

The settle pass polls up to `cfg.max_polls` times (default 8), accumulating the latest reading per symbol. Settlement occurs when:

- Every requested symbol has a numeric or permanent error reading, OR
- Poll count reaches `cfg.max_polls` (bounded window)

Any symbol still `Transient` or absent after the window is degraded (`DegradeReason::TimedOut`) only if no prior mark exists; otherwise the prior mark (with its original quote_date) is retained. A `Permanent` error always degrades, never carries prior.

## Timestamp Absence (unwanted-behavior)

- A degraded symbol has no mark and no quote_date in `MarksProduced`.
- A zero or non-positive price, despite a numeric reading, degrades (`DegradeReason::SubCent`) and produces no mark, hence no quote_date.
- Non-finite prices (NaN, ±∞) degrade (`DegradeReason::Permanent`) and produce no mark.

The absence of a mark/timestamp is semantically distinct from a zero timestamp — degradation never silently understates value.

<end>