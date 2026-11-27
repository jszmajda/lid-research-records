I have updated `docs/intent/previews/previews-design.md` to specify the 2Q eviction policy for the preview cache and updated `docs/high-level-design.md` to reflect that the eviction policy is settled.

### Updated Previews LLD (`docs/intent/previews/previews-design.md`)

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

### Eviction Policy (2Q)

The cache uses the 2Q eviction algorithm to resist sequential screening scans while retaining repeatedly accessed comparison sheets.

The cache maintains two distinct queues for resident entries:
- **A1in (FIFO queue)**: Newly rendered previews enter here on first admission. If an entry reaches the tail of A1in without receiving a second access, it is evicted when space is needed.
- **Am (LRU queue)**: When an entry in A1in receives a second access, it is promoted to Am. Subsequent accesses to entries in Am refresh their position to the head of the LRU queue.

When eviction is required to stay within the 12 GiB limit:
- If A1in exceeds its target capacity threshold (e.g. 25% of total cache capacity), entries are evicted from the tail of A1in.
- Otherwise, entries are evicted from the tail (least recently used) of Am.

All queue pointers, access tracking, and replacement bookkeeping remain strictly internal to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache Eviction Policy | 2Q (Two-Queue) | LRU, Frequency-based eviction with aging | Protects frequently reused comparison sheets from being flushed out during long sequential screening scans by requiring a second access before promoting entries to the main LRU queue (Am), while keeping bookkeeping overhead lower than continuous frequency counting and aging. |

## Open Questions & Future Decisions

### Resolved
1. Cache eviction policy: 2Q selected to protect comparison sheets during sequential screenings without affecting the external preview API or render queue.

### Deferred
1. Exact tuning and ratio split between A1in and Am capacities under production screening workloads.
```

---

### Phase 2 LLD Edge-Case Probe

1. **Full-2Q vs Simple 2Q (`A1out` ghost cache)**: Does the preview cache track evicted keys in an `A1out` ghost list to catch items re-referenced shortly after falling off `A1in`, or is a two-resident-queue (FIFO + LRU) model sufficient?
2. **Concurrent promotion race**: If multiple concurrent requests hit an item resident in `A1in` simultaneously, how is promotion to `Am` coordinated?
3. **Large admission eviction edge**: If a single newly admitted contact sheet is larger than remaining capacity in `A1in`, does eviction drain `Am` once `A1in` falls below threshold?
4. **Decision documentation**: Would you like to record this decision in a dedicated decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`), or does the Decisions & Alternatives table row suffice?

Please let me know if you would like any adjustments to the design or wish to resolve any of the probe items before we proceed to Phase 3 (EARS specs).