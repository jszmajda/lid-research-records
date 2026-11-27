Updated `docs/intent/previews/previews-design.md` (and removed the stale open-policy note in `docs/high-level-design.md`) to finalize 2Q as the preview worker's cache replacement policy.

Because the choice stays wholly inside the `previews` leaf—leaving the HTTP contract, render queue, and `review-api` untouched—I recorded it as a **Decisions & Alternatives** table row in `previews-design.md` rather than a separate decision doc.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so no eviction policy is best for every observed workload.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses a 2Q eviction policy to separate first-use entries from reused entries. Newly rendered sheets enter a probation queue (`A1in`), and evicted probation keys remain in a bounded ghost history (`A1out`). When a sheet is accessed again while in `A1in` or `A1out`, it promotes to the protected main queue (`Am`), which uses LRU replacement. This protects comparison sheets revisited across a session from being flushed by long sequential screening scans, while keeping all replacement state inside the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue replacement with probation and protected LRU queues) | Plain LRU; frequency-based eviction with aging | Long sequential screenings introduce many one-use sheets that flush a plain LRU cache and evict active comparison sets. Frequency-based eviction with aging retains popular clips but adds counter maintenance and lags when editors switch projects. 2Q isolates one-off screening scans in the probation queue while promoting revisited comparison sheets to the protected queue, keeping all replacement bookkeeping private to the preview worker without changing the HTTP contract, render queue concurrency, or 12 GiB disk budget. |

## Open Questions & Future Decisions

### Deferred
1. **2Q queue sizing and ghost-history capacity**: Partitioning the 12 GiB budget between `A1in` and `Am`, whether admission or promotion to `Am` happens on a second hit in `A1in` vs. only on a ghost hit in `A1out`, and the entry bound for `A1out` ghost metadata.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD and let me know which of these component-level edge cases we should settle in the LLD now versus defer:

1. **2Q budget split and ghost capacity (`A1in` / `Am` / `A1out`)**: What byte split of the 12 GiB limit should go to `A1in` (probation FIFO) vs. `Am` (protected LRU) — e.g., 25% (3 GiB) `A1in` / 75% (9 GiB) `Am` — and how many keys (or how much history) should `A1out` retain?
2. **Promotion rule (classic 2Q vs. simplified 2Q)**: Should a repeat hit while a sheet is still resident in `A1in` promote it immediately to `Am`, or does `A1in` act strictly as a FIFO filter where promotion to `Am` only happens when a request hits a key in `A1out` (requiring a re-render on the ghost hit)?
3. **Eviction source when admitting into a full queue**: Because contact sheets vary in byte size, when admitting a sheet requires freeing space, does eviction pull strictly from `A1in` until `A1in` is within its target share and otherwise from `Am`? What happens if `A1in` has entries smaller than the incoming sheet or is empty?
4. **Metadata persistence across worker restarts**: If the preview worker process restarts while cached JPEG files remain on disk, should it rebuild 2Q queue state from disk (e.g., seeding `A1in` or `Am` by mtime), persist queue metadata alongside the cache, or clear/re-index the cache directory on startup?
5. **Single sheet larger than queue partition**: Can a single contact sheet exceed `A1in`'s byte allocation (or the 12 GiB limit), and if so, is it rejected from caching or admitted by borrowing from `Am`?

Please share your feedback on the LLD draft and which of these points (1–5) to lock in now vs. defer before we proceed to Phase 3 (EARS specs).