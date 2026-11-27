Done with Phase 1 (HLD cascade edit) and Phase 2 (LLD draft) for the previews segment — stopping here per LID's phase-boundary rule before touching specs.

**HLD** (`docs/high-level-design.md`): updated the previews line from "its eviction policy remains open" to "evicted by a 2Q policy" — no architectural change, since none of the three options altered the review API/render-queue boundary.

**LLD** (`docs/intent/previews/previews-design.md`): replaced the open-question paragraph with the 2Q design — probationary queue A1 (one-time sheets) and main queue Am (reused sheets); admit new sheets at A1-MRU; a hit on A1 promotes to Am-MRU, a hit on Am refreshes its MRU position; evict from A1-LRU first, Am-LRU only once A1 is empty. Added a Decisions & Alternatives row recording why 2Q beat LRU and aged-frequency. Left the A1/Am size split as an explicit Deferred open question, since you flagged it as something to tune rather than fix now.

Two things need your judgment before I continue:

1. **Decision doc?** This one cleared three meetings and a 180-message thread, traded multiple real criteria against each other, and the size-split parameter still has to be sized around whatever we record here — by the earns-its-place test, that's a candidate for a full decision doc (not just the table row I added). Want one at `docs/intent/previews/decisions/eviction-policy.md`, or is the table row enough?

2. **LLD-level edge-case probe** — two gaps worth your ruling before specs get written:
   - **No ghost queue**: your three-option sketch described two queues, not three, so I didn't add an A1-out ghost list. That means a sheet evicted from Am (e.g., during a huge screening that also pressures Am) loses its "reused" status entirely — re-requesting it starts over in A1 as if it had never been promoted. Is that acceptable, or do you want ghost-tracking after all?
   - **Concurrent-miss promotion**: when several requests miss on the *same* key and share one job ticket (per PREVIEW-003), does that completion count as a single admission (one entry enters A1, as today), or could simultaneous waiters count as multiple "hits" and spuriously promote a sheet straight to Am on its very first render?

Once you rule on those (and the decision-doc question), I'll move to Phase 3 (EARS spec updates for PREVIEW-004 and any new 2Q-specific specs).