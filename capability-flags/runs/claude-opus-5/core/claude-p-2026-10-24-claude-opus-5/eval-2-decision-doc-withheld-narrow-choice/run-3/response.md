Phase 1 done. Stopping for your review before I touch the previews LLD.

---

## Coherence pre-flight (previews segment)

- **Specs → LLD**: PREVIEW-001…005 all trace to the previews design (interface outcomes, dedup, the 12 GiB admission bound). No orphans.
- **LLD → HLD**: consistent — fixed HTTP contract, FIFO queue at 4 concurrent jobs, cache private to the worker.
- **Tests → specs**: no tests or code exist yet; the whole segment is unimplemented (`[ ]` across the board). Nothing to drift.

One piece of drift, caused by your decision: the HLD recorded the eviction policy as an open question.

## Phase 1 — HLD check

2Q does not alter the architecture. It changes only the preview worker's private replacement bookkeeping — the HTTP contract, the FIFO queue, the 4-job concurrency limit, and the 12 GiB budget are all untouched, and no other node reads cache files or policy state. So the HLD needs one stale-clause repair, not a redesign:

**`docs/high-level-design.md`**, Architecture:

> - Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache, ~~Its eviction policy remains open.~~ **including its replacement policy.**

I deliberately did **not** name 2Q in the HLD. Your tenet *"Keep cache paths and replacement bookkeeping private to the preview worker"* means the root doc should say who owns the policy, not which policy it is — otherwise every future tuning change cascades up to the HLD for no gain.

Nothing else in the HLD goes stale: the goal *"Return a ready preview or a pending response through the same interface for every eviction policy"* is still exactly right, and 2Q satisfies it.

## How I'm recording the decision

A Decisions & Alternatives row in the previews LLD — LRU and aged-frequency named as the rejected alternatives, with scan resistance during long screenings as the rationale and the extra bookkeeping as the accepted cost.

Not a standalone decision doc. I know three meetings and 180 messages went into this, but the test is how the choice reads once it lands, not how hard it was to settle: 2Q lives entirely inside one component, creates no contract any other node consumes, and no other design node gets sized around it. A cold reader hits one row, sees "scan-resistant, costs bookkeeping," and moves on. A `decisions/` doc here would memorialize the argument rather than the result — and you'd be the one maintaining it.

If you think a future reader would genuinely re-litigate this, say so and I'll write the doc instead.

## Phase 2 preview

Next I draft the 2Q design into the previews LLD. One thing I already know I cannot settle for you, and will bring back as a concrete proposal rather than a silent choice: **the A1in/A1out size split** — you named the tuning cost yourself when you picked 2Q. What fraction of the 12 GiB the first-use queue gets, and how many evicted keys the ghost queue remembers, determines whether comparison sheets actually survive a big screening. I'll propose defaults with reasoning from your 90,000-clip / ~6,000-weekly-views numbers, and you confirm or adjust.

**Approve the HLD edit and I'll proceed to Phase 2.**