Agreed — and it's done. `docs/intent/previews/decisions/eviction-policy-2q.md` now records the decision: context, the two inherited gates plus the three weighted criteria (scan resistance major; bookkeeping and adaptation moderate), all three options with their strongest honest representation, and a selection section naming what 2Q forecloses and obligates — including the honest caveat that Am is not absolutely sealed. The previews LLD's Decisions row now links to it. I wrote it cold — no trace of the three meetings or the 180 messages.

Still open from last round — these need your ruling before tests get written:

1. **Scan-bleed boundary**: with A1 filled exactly to its split, each admission evicts one Am entry (standard 2Q; strong but not absolute scan protection — now also recorded in the decision doc). Acceptable, or do you want Am touched only when A1 can't supply a victim?
2. **Promotion trigger**: only requests answered with the JPEG (200) promote; a 202 ticket doesn't. Confirm?
3. **Failed renders**: eviction made for an admission is not rolled back if the render fails — the cache ends up under-filled, never over-budget. Confirm?

Once you rule on those, next stop is the Phase 4 cross-spec audit, then tests-first implementation.