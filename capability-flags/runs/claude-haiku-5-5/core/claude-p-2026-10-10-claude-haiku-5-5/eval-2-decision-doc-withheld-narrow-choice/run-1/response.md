**Phase 1 (HLD check) is done. I'm stopping here for your review, as the workflow requires before Phase 2.**

**The choice:** 2Q eviction for the preview worker's private 12 GiB cache. It stays inside the previews node. The review API still reaches the worker only through the fixed `GET /internal/previews/...` interface, and the render queue and disk budget don't change. I checked it against the four HLD tenets and none conflicts.

**Proposed HLD edit:** the Previews bullet in `docs/high-level-design.md` ends with "Its eviction policy remains open." That sentence goes stale once 2Q is chosen. I'd delete it, leaving "Owns rendering, pending jobs, and a private 12 GiB cache."

**Decision record:** I'm not offering a decision doc. The choice affects only the previews node, and the alternatives are already on the page. I'll record LRU, frequency-with-aging, and 2Q as a row in the previews LLD's Decisions & Alternatives table. The current `previews-design.md` doesn't have that table yet.

**Cascade:** nothing crosses a segment boundary. `review-api-design.md` and its specs need no change.

**Open questions for you before Phase 2.** 2Q settles the policy, but these details are still open:

1. **Queue split.** I recommend the standard 2Q values: the probationary queue gets 25% of the 12 GiB budget, and the ghost list holds keys for about 50% of cached entries. Should these be fixed constants, or worker configuration with these defaults that you tune during the pilot?
2. **Bytes or entries.** The budget is in bytes and sheets are about 2 MiB, so I'd size both queues by bytes, not entry count. Do you agree?
3. **Ghost history on restart.** I'd keep it in memory only, so it starts empty after a restart. Do you agree?

Once you answer, I'll draft the previews LLD, including the Decisions row and the LLD-level edge probe, and stop for your review. The EARS update comes after that, with another stop.