**EARS-style requirements enforced (republish timing & serialization with mark refresh):**

**Event-driven — republish triggers.** WHEN the headless `summary` command runs, WHEN the interactive TUI connects, WHEN the user presses the manual refresh key, WHEN the ambient auto-refresh clock's hourly threshold (`shell::AUTOREFRESH_INTERVAL`) elapses with no entry composer open, or WHEN a ledger/tax submit is confirmed durable and its composer closes, the system SHALL run one publishing cycle that replays, renders the five view bands (Positions, Open Lots, Realized, Tax-accruals, Tax-reserve-summary), republishes them, and reads marks back.

**Ubiquitous — serialization.** The system SHALL run republish-then-settle as ONE serialized loop per cycle: the mark settle-read SHALL begin only after every tab's write attempt has returned, and SHALL NEVER run concurrently with or before a tab write.

**Ubiquitous — lock scope.** The system SHALL acquire the advisory write-lock immediately before republish's tab writes and release it immediately after; the lock SHALL guard only the write half — the settle read SHALL proceed regardless of whether the lock was acquired.

**Unwanted-behavior — held lock.** IF the advisory lock is Held or acquisition errors WHEN republish is invoked, THEN the system SHALL write nothing, SHALL leave the stale-tab set unchanged, and SHALL report `published=false` (non-destructive; retried next cycle).

**Event-driven — per-tab failure.** WHEN a tab's `batch_update_view` fails, the system SHALL flag that tab stale, attempt a best-effort in-tab `"STALE — last sync {ts}"` banner (its own failure ignored), and leave other tabs' outcomes independent; on success the stale flag clears and, after all tabs, the fixed tab order is reasserted.

**State-driven — settle polling.** WHILE settling, the system SHALL poll `read_price_pass`, keyed only on open-position symbols (qty ≠ 0; closed symbols never requested), until every symbol is Numeric or Permanent, up to `SettleConfig::max_polls` (default 8) polls.

**Unwanted-behavior — degrade rules.** IF a symbol stays Transient/absent through max_polls, THEN it degrades TimedOut, carrying forward its prior cached mark if any (else degraded, no mark). IF Permanent, THEN it degrades Permanent with no prior carry. IF a positive price rounds to 0 cents (`round_half_to_even(price×100)`), THEN it degrades SubCent.

**Unwanted-behavior — offline propagation.** IF `read_price_pass` itself errors, THEN `read_marks` SHALL propagate the error, produce no `MarksProduced`, and the caller SHALL retain its previously cached marks rather than substitute an empty set.

Files read: tui_app.rs, wiring.rs, cycle.rs, publish_cycle.rs, sheets-view/src/lib.rs, sheets-view/tests/republish.rs (all under `{scratch}/audit-baseline/`).