Phase 2 (previews LLD) is drafted. Here is what changed and what still needs your read.

**`docs/intent/previews/previews-design.md` — Private Cache → Replacement Policy**

> Eviction uses 2Q. The cache holds a cold queue of sheets seen once and a hot queue of sheets that have been reused. Both queues are ordered by the time an entry entered the queue, and each queue is bounded by its byte share of the 12 GiB cache.
>
> - A completed sheet is admitted to the tail of the cold queue. If the cold queue exceeds its share, its head entries are evicted until it is within the share.
> - A request that hits a cold sheet promotes it to the tail of the hot queue. If the hot queue exceeds its share, its head entries are evicted until it is within the share.
> - A request that hits a hot sheet leaves its queue position unchanged.
>
> This keeps a one-pass screening from displacing the smaller set of sheets that editors compare repeatedly: screening sheets arrive in the cold queue and leave from its head, while reused sheets move to the hot queue and are protected by the hot share.

The Decisions & Alternatives row records 2Q against LRU and aged frequency eviction, with the rationale that all three stay private to the worker. The hot-queue share is recorded as a deferred tuning decision. I also removed the now-stale "eviction policy remains open" sentence from the HLD's Previews architecture line. I did **not** create a decision doc — the choice affects only this node, so it belongs as a table row.

**Edge-probe gaps for your triage:**

1. A sheet larger than its queue's byte share cannot be held without breaching the share. Suggested rule: admit it anyway, allow the queue to exceed its share for that one entry, and evict it on the next ordinary admission. Confirm or defer.
2. This is the FIFO variant of 2Q: repeated hits on a hot sheet do not refresh its position, so an old-but-still-active comparison sheet can be evicted when the hot queue fills. That is a consequence of choosing 2Q over LRU; I can state it explicitly in the LLD if you want it on the page.
3. A promoted cold entry occupies hot-queue bytes, not both queues; cold removes it on promotion. I assumed no duplicate placement — confirm.

Approve this LLD (or give numbered changes) and I'll move to Phase 3, drafting the EARS updates for the 2Q behavior.