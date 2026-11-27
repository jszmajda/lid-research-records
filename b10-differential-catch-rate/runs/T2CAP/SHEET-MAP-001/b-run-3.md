SHEET-MAP-001 (ubiquitous) — The system shall resolve every ledger `Symbol` to a GOOGLEFINANCE ticker via `config`'s `AliasMap` before any live-price formula is built, using `resolve_ticker(aliases, symbol)`.

SHEET-MAP-002 (ubiquitous) — The system shall normalize the lookup key before consulting the alias table: trim leading and trailing whitespace, then upper-case the remainder. Examples pinned: `"brk"`, `"  BRK  "`, `" brk"` all resolve to the alias for `"BRK"`.

SHEET-MAP-003 (event-driven) — When the normalized key has an entry in the alias table, the system shall use the mapped value verbatim as the ticker (e.g. `BRK`→`BRK.B`, `AAPL`→`NASDAQ:AAPL`, `AMZN`→`NASDAQ:AMZN`), including exchange-qualified `EXCHANGE:TICKER` forms.

SHEET-MAP-004 (event-driven) — When the normalized key has no alias entry, the system shall fall back to identity: the ticker is the normalized symbol itself (`"AMZN"`→`"AMZN"`, `" amzn "`→`"AMZN"`). The fallback is the normalized form, not the raw input.

SHEET-MAP-005 (ubiquitous) — The system shall build the Positions `Price` cell as a live formula with the resolved ticker double-quoted: `=GOOGLEFINANCE("<ticker>","price")`, with the literal attribute `"price"`.

SHEET-MAP-006 (ubiquitous) — The system shall build the companion `Quote Date` cell from the same resolved ticker as a live formula: `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")` — trade time truncated to a date serial, re-based to days since 1970-01-01 (the kernel `Date` epoch), rendered digits-only via `TEXT(…,"0")` so it is locale-proof, and empty (never an error string) while loading/errored. `Quote Date` is column index 12 of `POSITIONS_HEADER`.

SHEET-MAP-007 (unwanted behavior) — The `Price` and `Quote Date` formulas shall never carry the raw ledger symbol when an alias exists; a row for symbol `BRK` aliased to `BRK.B` must not contain `"BRK"` as the quoted ticker.

SHEET-MAP-008 (ubiquitous) — Both ticker-bearing cells shall be `Cell::Formula` (live), never engine values, on every rendered Positions row.

SHEET-MAP-009 (state-driven) — While rendering Positions, the system shall enforce one row per symbol (the key the mark read-back uses); on encountering a second row for an already-seen symbol it shall return `Err(ViewError::DuplicateSymbolRow(symbol))`, whose `Display` is `DuplicateSymbolRow("AMZN")`. Because `Snapshot.positions` is a `Map<Symbol,_>`, this guard is defensive/structurally unreachable via the real API.

SHEET-MAP-010 (ubiquitous) — Ticker resolution shall perform no other transformation: no alias-chain re-resolution, no exchange inference, no validation of ticker form. A bad ticker surfaces later as a permanent `#N/A` price reading (`DegradeReason::Permanent`), not as a resolution-time error. Resolution is total — it never fails and never returns empty for a non-empty symbol.