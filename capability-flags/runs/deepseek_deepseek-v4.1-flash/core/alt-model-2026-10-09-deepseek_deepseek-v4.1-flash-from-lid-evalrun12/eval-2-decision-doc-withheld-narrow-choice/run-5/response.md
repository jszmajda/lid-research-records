Coherence pre-flight is clean otherwise (HLD ↔ LLD ↔ specs otherwise trace; the review-api segment is unaffected since 2Q is node-private). One stale HLD line needed a fix before drafting around the choice.

**Phase 1 — HLD coherence fix** (`docs/high-level-design.md`)
- Previews bullet no longer says "Its eviction policy remains open"; now names the private 12 GiB cache with a 2Q eviction policy.
- Goal reworded to "Return a ready preview or a pending response through the same interface regardless of whether a sheet is cached" (the "for every eviction policy" phrasing assumed the open choice).

**Phase 2 — LLD updated** (`docs/intent/previews/previews-design.md`)

The eviction candidates paragraph is gone. `Private Cache` now specifies 2Q concretely, and the rejected options moved into a Decisions & Alternatives table (their sanctioned home):

> Entries occupy exactly one queue:
> - **Probationary queue (FIFO).** A sheet enters here when its render completes. It leaves on eviction, oldest first, when the queue is over its share of the budget.
> - **Protected queue (LRU).** A sheet in the probationary queue moves here when a later request is served from cache. Each cache hit refreshes its recency position.
>
> A request that joins a pending render job is a cache miss, not a hit: it neither promotes nor refreshes an entry. Only serving a cached JPEG counts as reuse.
>
> The 12 GiB budget is shared between the queues by a tunable split. On admission the worker holds the cache within 12 GiB by evicting the oldest probationary sheet first; it evicts the least-recently-used protected sheet only when the probationary queue cannot meet the bound or the protected queue is over its share.

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q: FIFO probationary + LRU protected, hit promotes from probation and refreshes recency | Plain LRU; frequency-based eviction with aging | 2Q lets a screening cycle its one-use sheets through probation while the reused comparison set stays protected; cost is one more queue and a size split, private to the worker. LRU: least bookkeeping, fastest project-switch adaptation, but a scan can evict the comparison set. Aged frequency: retains popular clips but adds counter maintenance/aging, adapts slowly, can hold stale favorites. |
| Probationary/protected budget split | 25% / 75% | 50% / 50% | Minority probationary share absorbs a scan while most of the budget holds the reused set. Pilot-tuning constant. |

Deferred open question: the split value (ship 25/75, tune against pilot hit rates). No decision doc — the choice affects only this node.

**Edge-case probe findings — please triage each (fix in LLD vs. defer):**
1. No ghost history: a probationary sheet evicted during a scan and later re-requested restarts in probation and must be hit again before it is protected. Acceptable, or do we want a recently-evicted marker to fast-promote?
2. Split enforcement: should a promotion that pushes the protected queue over its share evict LRU immediately, or should the split be enforced only at admission? I wrote "immediately"; confirm.
3. Concurrency: the LLD never states the locking/consistency model for queue mutation when render completions and cache hits overlap.
4. Degenerate split: if the configured probationary share is smaller than one 2 MiB sheet, reject the config at startup or clamp?

Please review the LLD above with numbered feedback, triage the four gaps, and approve (or correct) before I proceed to Phase 3 (EARS specs). I have not touched the spec file yet.