**Preview design is finished for the 2Q decision.** The policy is settled inside the preview worker; nothing about it crosses the worker boundary, so the review-api node is untouched (no cross-segment cascade).

**Files changed**
- `docs/high-level-design.md` — the previews node no longer says its eviction policy is open.
- `docs/intent/previews/previews-design.md` — new "Cache Replacement Policy" section, Decisions & Alternatives table, Open Questions.
- `docs/intent/previews/previews-specs.md` — PREVIEW-006…020 covering the two queues, promotion, eviction, budgets, plus three behaviours that were prose-only (render-queue concurrency, temp-output handling, eviction deleting only cache bytes).

**What the design now says**
Two queues inside the 12 GiB limit: a first-use queue (2.5 GiB, ~1,280 sheets) ordered by admission, and a reused queue (9.5 GiB, ~4,860 sheets) ordered by least-recently-served. A rendered sheet enters the first-use queue; a later independent request for it moves it to the reused queue. A screening scan's evictions land only in the first-use queue, so revisited sheets stay warm. Two judgment calls I made and recorded in the table: the reused queue's evicted sheet is **dropped**, not demoted back (demoting frees no bytes under a byte budget), and a sheet larger than its queue's budget is served but not cached. The docs are written to be read cold — LRU and aged-frequency live in the Decisions table, not as debate residue.

**Two things only you can settle**
1. **The split.** Currently 2.5 / 9.5 GiB (pinned in PREVIEW-014). Alternatives: 1.5 / 10.5 GiB (stronger protection for revisited sheets, less room for an active screening) or 4 / 8 GiB (more screening headroom, revisited sheets survive shorter).
2. **What counts as a second request.** Currently: the request that causes the render counts once — including the ticket-bearing poll that collects the finished sheet — so only a later, independent request promotes a sheet into the reused queue. The alternative is counting that delivery as a second request, which would promote every clip an editor screens the moment it is delivered and fill the reused queue with one-off sheets — the opposite of what 2Q is buying here.

**Phase 5–6 are blocked, not done.** This repo contains no implementation at all — no worker code, no language or test runner — so there is nothing to write failing tests against or to implement. That means scaffolding the whole preview worker and picking a stack, which is larger than "finish the design". Tell me whether to scaffold it (and in what stack) or keep this design-only for now.

Also uncovered but left alone, since they predate the policy change: where the renderer version comes from (it's in the cache key but not in the endpoint), the job ticket's shape and lifetime, what a client sees when a render fails, and cache/dedup state after a worker restart. Say the word if you want those closed next.