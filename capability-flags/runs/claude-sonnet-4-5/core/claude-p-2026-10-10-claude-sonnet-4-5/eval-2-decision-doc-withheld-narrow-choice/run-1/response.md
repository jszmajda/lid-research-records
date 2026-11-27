**Phase 2 Complete: Previews LLD Updated**

I've incorporated the 2Q eviction policy decision into `docs/intent/previews/previews-design.md`:

## Eviction Policy: 2Q

The cache uses a two-queue (2Q) eviction strategy to protect comparison sheets during long sequential screenings. Two queues partition the cache:

**A1 (first-use queue)**: Newly cached sheets enter here, managed as FIFO. Target size is 3 GiB (25% of total capacity). When a sheet in A1 is accessed again, it is promoted to Am and removed from A1.

**Am (multi-use queue)**: Holds sheets that were accessed at least twice, managed as LRU. Takes the remaining 9 GiB. Repeated access keeps an entry warm via LRU recency updates.

When admitting a new sheet that would exceed the 12 GiB limit:

1. If A1 exceeds its 3 GiB target size, evict the oldest A1 entry (FIFO).
2. If A1 is within target but total cache exceeds 12 GiB, evict the least-recently-used Am entry.

This separation protects frequently reused comparison sheets in Am from being evicted by one-pass sequential scans that fill and cycle through A1. The 25% A1 allocation balances scan tolerance (a 3 GiB A1 holds ~1500 typical sheets before cycling) against comparison-set protection (9 GiB for Am holds ~4500 sheets).

Promotion from A1 to Am happens immediately on the second access, before the response is served. The queues are private to the preview worker; no external interface exposes queue membership or replacement metadata.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue) with 25% A1 / 75% Am split | LRU: simple, low bookkeeping, adapts quickly to project switches. Frequency-based with aging: protects popular clips but adds counter maintenance and can retain stale favorites. | 2Q protects comparison sheets (reused clips in Am) from eviction during long sequential screenings that would cycle through A1. The extra bookkeeping (tracking two queues and handling promotion) is acceptable to prevent comparison-set thrashing. The 25% A1 size accommodates ~1500 one-pass sheets before cycling while reserving 75% for the multi-use working set. |

The design is now complete and context-free. Does this capture the 2Q design correctly? Any changes needed before I proceed to Phase 3 (EARS specs)?