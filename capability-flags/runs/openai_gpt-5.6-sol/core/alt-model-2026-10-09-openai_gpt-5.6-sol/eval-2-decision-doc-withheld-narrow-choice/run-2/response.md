**Phase 2: Preview Design Draft**
The selected 2Q design is recorded in `docs/intent/previews/previews-design.md`:

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

Use 2Q replacement with three worker-private structures:

- An incoming FIFO contains newly rendered sheets that have been requested once. Its initial target is 3 GiB of resident JPEG data.
- A main LRU contains sheets requested at least twice. A hit in the incoming FIFO promotes the sheet to the most-recent end of the main LRU; a hit in the main LRU refreshes its recency.
- An outgoing FIFO retains only the keys and former sizes of sheets evicted from the incoming FIFO. It retains at most 6 GiB of represented former JPEG data; trimming it deletes the oldest metadata only. A request whose key is in this history is admitted to the main LRU after rendering completes.

The incoming target is enforced only while making room. When admission would exceed the 12 GiB resident-data limit, evict the oldest incoming sheet if incoming data exceeds 3 GiB or the main LRU is empty; otherwise evict the least-recent main sheet. Repeat until the completed sheet fits. Ghost metadata and temporary render output do not count toward the resident-data limit.

The incoming and outgoing thresholds are private tuning parameters. They may change with observed screening workloads without changing cache keys, the HTTP interface, render concurrency, or the 12 GiB resident-data limit.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache replacement policy | 2Q with a 3 GiB incoming target and 6 GiB outgoing history | LRU; frequency-based eviction with aging | Separating first-use sheets from reused sheets prevents long sequential screenings from displacing comparison sheets. The additional queues and tunable thresholds remain private to the preview worker. |

## Open Questions & Future Decisions

### Deferred

1. Tune the incoming and outgoing thresholds from pilot workload measurements if the initial 3 GiB and 6 GiB values do not preserve comparison working sets effectively.
```

The stale “eviction policy remains open” wording was also removed from `docs/high-level-design.md`; the architecture itself is unchanged.

The independent edge-case probe found these implementation-significant gaps:

1. A completed sheet larger than 12 GiB cannot be admitted even after evicting everything.
2. Ghost-history admission needs a fixed decision point if its record is trimmed while rendering.
3. A key should not simultaneously exist in resident and outgoing queues.
4. Concurrent requests sharing one render need a rule for whether they count as one or repeated access.
5. Incoming-target eviction must specify whether occupancy is measured before or after provisional admission.
6. Cache membership, byte accounting, promotions, and eviction need an atomicity rule, including active readers.
7. Restart recovery for resident files and replacement metadata is unspecified.
8. Admission-write failures, exact byte accounting, threshold retuning, and ghost-entry edge cases could be deferred.

My recommendation is to resolve items 1–7 in the LLD before drafting EARS specs and defer item 8. Please approve that disposition and the draft, or reply with numbered changes.