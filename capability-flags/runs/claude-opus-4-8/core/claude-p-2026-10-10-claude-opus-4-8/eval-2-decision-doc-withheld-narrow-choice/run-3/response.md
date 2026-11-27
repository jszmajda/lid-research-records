Phase 2 (LLD) is drafted. Here's where it landed, for your review before I touch specs.

## What changed
- **`previews-design.md`** — new **Cache Eviction** section specifying 2Q: a FIFO *probation* queue and an LRU *main* queue sharing the one 12 GiB budget; first admission → probation; a cache hit in probation → promote to main; reclamation evicts the probation tail while probation is at/above its share (or main is empty), else the main LRU tail. Added a **probation share** parameter (default 25% of budget, measured in bytes). Added a Decisions & Alternatives table (2Q over LRU / frequency-with-aging) and Open Questions. Context now motivates scan-resistance rather than deferring the choice.
- **`high-level-design.md`** — deleted the now-stale "Its eviction policy remains open." The HLD deliberately does **not** name 2Q: the policy's substance is leaf-local to previews, and the HLD's policy-agnostic goal/tenet lines stay true as written.

## LLD edge-case probe — please triage (fix in LLD now, or defer)
1. **Cold start / pure screening** — probation below its share but main empty: eviction still pulls from probation. I encoded this ("…or the main queue is empty"); confirm that's the intent.
2. **Re-request after eviction** — a sheet evicted from probation and requested again is a fresh first-use admission (no ghost list). Tied to Open Question 2.
3. **What counts as a promoting hit** — the first render that populates the cache is the first-use *admission*, not a hit; promotion needs a later request that hits the already-completed sheet. Confirm.
4. **Byte vs. entry accounting** — probation share is bytes (recorded as a Decisions row).
5. **Worker restart** — queue state is in-memory, so a restart starts cold. This was unstated in the prior design too; want it pinned or left deferred?

## Two things for your judgment
- **Full vs. simplified 2Q.** You said "two queues and a size split," so I designed the two-queue form (probation FIFO + main LRU). Full 2Q adds a *ghost list* of evicted keys so a quick re-request promotes straight to main. I've left that out and flagged it as Open Question 2 rather than silently deciding — tell me if you want it in.
- **Decision doc?** This choice stays live for a cold reader — three credible policies traded against bookkeeping cost, scan-resistance, and tuning, and the specs are about to be sized around it. I can expand the Decisions row into a short `docs/intent/previews/decisions/eviction-policy.md` (options + criteria + selection) so the "why 2Q not LRU" is reconstructable. The Decisions row is the lighter alternative if you'd rather not. Your call.

If this looks right, I'll proceed to **Phase 3 (EARS specs)** — adding spec lines for the probation/main split and promotion behavior, revising PREVIEW-004's eviction wording — then the Phase 4 cross-spec edge audit, each with its own stop.