2Q is locked in. The preview design is updated — here's the Phase 2 stop for your review.

**What changed**

- `docs/intent/previews/previews-design.md` — new **Eviction Policy: 2Q** section: first-use queue (FIFO, 25% initial share ≈3 GiB) and reused queue (LRU, 75% ≈9 GiB); a hit on a first-use sheet promotes it; screening pressure can never evict a reused sheet; only served hits count as references. Added the template's **Decisions & Alternatives** table (2Q vs LRU vs aged-frequency, plus two supporting decisions) and **Open Questions** (budget-split tuning, ghost keys, restart behavior — currently drafted as deferred).
- `docs/high-level-design.md` — one-line fix: the previews node no longer says "eviction policy remains open"; it now names 2Q. Veto if you'd rather the HLD stay policy-silent.
- Review-api segment untouched: its design is deliberately policy-agnostic, so no cross-segment cascade.

**Edge-case probe — two genuine forks need your ruling**

1. **Promotion trigger after a 202.** When a client's retry lands on a just-completed sheet, is that serve the *second* reference (promotes the sheet), or part of the original miss (sheet stays in the first-use queue until a genuinely new request hits it)? My draft intent is the latter — a screening burst around one render shouldn't promote anything — but the doc doesn't pin it.
2. **Ghost keys.** My draft omits classic 2Q's ghost list, so a sheet that falls out of the first-use queue and is re-requested starts over (re-rendered, re-admitted to first-use). Adding ghosts would admit such a re-render straight to the reused queue, at the cost of a third structure beyond the two you signed up for. Default: omit.

**Gaps the probe surfaced — triage each as "fix in the LLD" or "defer"**

3. Promotion into a full reused queue evicts the reused LRU tail (and the byte accounting moves atomically, no double-count) — my position; confirm or adjust.
4. A sheet larger than its target queue's entire share — admit anyway in violation of the bound, or don't cache it? (Near-uniform 2 MiB makes this unlikely, but the invariant is unwritten.)
5. Eviction deleting a file mid-way through serving an in-flight 200 — needs a stated rule (e.g., don't delete a file with an active reader).
6. Re-request for a key whose first-use entry was evicted while a stale pending job exists — needs an explicit no-double-admission invariant.
7. What a poller sees when a job *fails* — the contract only defines 200/202/404 (pre-existing gap, not 2Q-caused).
8. Render-queue backpressure beyond four active jobs (pre-existing).
9. Unknown revision vs. transient failure to resolve the source revision — risk of reporting a temporary error as a permanent 404 (pre-existing).
10. Whether retuned shares take effect immediately or on next admission — I'd defer with the budget-split tuning item.

**One offer, then I'll drop it**: the 2Q choice has credible alternatives traded across multiple criteria and the queue-budget design is being sized around it, so it would earn a full decision doc at `docs/intent/previews/decisions/` if you want one — say the word. Otherwise the Decisions & Alternatives row stands as the record.

Answer the numbered items (even just "1: latter, 2: omit, 3–10: your call/defer") and I'll fold the rulings into the LLD and proceed to Phase 3 — the EARS specs for promotion, eviction order, and reference counting (the existing five PREVIEW specs are policy-neutral and unchanged).