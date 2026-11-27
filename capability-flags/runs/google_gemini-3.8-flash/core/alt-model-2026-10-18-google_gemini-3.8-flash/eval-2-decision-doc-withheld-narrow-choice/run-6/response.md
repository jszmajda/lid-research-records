### Phase 2 — Low-Level Design (LLD) Update

I have updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md` to specify the 2Q (Two Queue) cache eviction policy, defining the roles and transitions across `A1in`, `Am`, and `A1out` (ghost queue), admission and promotion dynamics, and eviction criteria under the 12 GiB limit.

#### Updated `docs/intent/previews/previews-design.md`:

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

### Cache Eviction and Queue Management (2Q)

The preview cache uses the 2Q (Two Queue) replacement algorithm to protect repeatedly accessed sheets during long sequential screenings:

- **Structure**:
  - `A1in` (FIFO queue): Holds newly admitted sheets upon initial render completion. Sized to a target fraction of cache capacity (e.g., 25% of total cache size).
  - `Am` (LRU queue): Holds frequently accessed sheets. When a sheet currently in `A1in` is accessed again, or when a hit occurs on an entry tracked in the ghost queue (`A1out`), it is promoted to `Am`. Within `Am`, cache hits promote entries to the most recently used (MRU) position.
  - `A1out` (Ghost FIFO queue): Tracks metadata (keys only, without payload data) for entries recently evicted from `A1in`. Sized to track up to the key capacity of `Am`.
- **Admission & Hit Dynamics**:
  - When a newly rendered preview completes and is admitted: if its key is present in `A1out`, it is admitted directly into `Am` (MRU position) and removed from `A1out`. Otherwise, it is admitted into `A1in`.
  - When a cache hit occurs: if the entry is in `Am`, it moves to the MRU position of `Am`. If the entry is in `A1in`, it is promoted to the MRU position of `Am`.
- **Eviction Selection**:
  - When admitting a completed sheet requires freeing space to remain within the 12 GiB limit:
    - If `A1in` exceeds its target capacity threshold (e.g., 25% of 12 GiB), the oldest sheet at the tail of `A1in` is evicted from disk; its key is appended to `A1out` (evicting the oldest key from `A1out` if `A1out` exceeds its capacity).
    - Otherwise, the least recently used sheet at the tail of `Am` is evicted from disk.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache replacement policy | 2Q (Two Queue) | LRU, Frequency-based eviction with aging | 2Q separates first-use screening sheets from reused comparison sheets via `A1in` and `Am` queues, preventing long sequential scans from wiping out the comparison working set, while avoiding the stale counter lag and continuous aging overhead of frequency tracking. |

## Open Questions & Future Decisions

### Deferred
1. Initial target size ratio between `A1in` and `Am` (proposed 25% / 75%) and ghost queue capacity tuning under production screening workloads.
```

---

### Phase 2 Edge-Case Probe Findings

An edge-case probe targeting internal structural gaps in this LLD identified the following questions:

1. **Eviction fallback**: If `A1in` is below its target threshold but the cache exceeds 12 GiB (or vice versa, `Am` is empty), does eviction fall through to evict from whichever queue currently holds entries?
2. **Ghost queue sizing bound**: How is the capacity of `A1out` bounded (e.g., maximum count of keys computed assuming typical 2 MiB sheets, ~4,500 keys for 75% of 12 GiB)?
3. **Active streaming during eviction**: Are cache files locked/referenced until in-flight HTTP transmission completes before physical removal?
4. **Temporary render storage vs. budget**: Does the temporary storage for up to 4 concurrent rendering jobs count toward the 12 GiB limit, or is the 12 GiB ceiling strictly for committed cache entries?

---

### Questions for User Review

1. Do you approve the 2Q LLD design as drafted, or would you like to incorporate answers to any of the edge-case probe questions directly into the LLD before proceeding to Phase 3 (EARS specs)?
2. Would you like to record this decision as a standalone decision doc (`docs/intent/previews/decisions/cache-replacement-policy.md`), or is the Decisions & Alternatives table row sufficient?