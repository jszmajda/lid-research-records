## Phase 2: Preview LLD Review

I updated the HLD to record 2Q as the preview cache policy and drafted the preview LLD around a byte-bounded 2Q cache.

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

Use a byte-bounded 2Q policy with a 3 GiB probationary queue and a 9 GiB protected queue. A newly rendered preview enters the probationary queue at its newest end. The probationary queue is FIFO: a cache hit does not reorder an entry. A subsequent cache hit promotes the preview to the newest end of the protected queue. The protected queue is LRU: each protected hit moves its entry to the newest end.

The worker tracks each resident preview's key, JPEG byte size, and queue membership. Before admitting a completed preview, it evicts the oldest probationary entries until the admission fits both the 12 GiB cache limit and the 3 GiB probationary limit. If no probationary entry remains, it evicts the least-recently-used protected entries until the admission fits the 12 GiB cache limit. Promotion from probationary to protected first makes room in the protected queue by evicting its least-recently-used entries as needed; it then removes the promoted entry from the probationary queue. A preview is in exactly one queue while cached.

This policy keeps one-time screening sheets in the limited probationary queue while retaining previews that editors revisit for comparisons. Replacement metadata is process-private and discarded with the cache; it does not affect the preview HTTP interface, render queue concurrency, cache key, or job-ticket behavior.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache replacement policy | Byte-bounded 2Q with a 3 GiB FIFO probationary queue and a 9 GiB LRU protected queue | LRU; frequency-based eviction with aging | 2Q prevents a long run of one-use screening previews from displacing repeatedly accessed comparison sheets. LRU provides less protection from scans, and aged frequency counters add maintenance while retaining prior-project popularity longer than needed. The 25% probationary allocation preserves room for scan traffic without making first-use entries dominate the 12 GiB cache. |

## Open Questions & Future Decisions

### Resolved

1. The preview cache uses 2Q replacement with separate probationary and protected queues.

### Deferred

1. Reassess the 3 GiB probationary allocation with pilot cache telemetry if observed workloads show persistent protected-queue churn or low promotion rates.
```

The LLD-level edge-case probe found these gaps to triage before I draft EARS specs:

1. What should happen when a rendered JPEG exceeds the 3 GiB probationary limit or the 12 GiB total cache limit: serve it without caching, reject it, or another outcome?
2. What HTTP outcome should a requester receive when rendering or cache admission fails, and what should existing holders of that job ticket observe?
3. Should worker restart discard all in-flight jobs, tickets, temporary output, and replacement metadata, or recover any of them?
4. Should an unreadable, missing, or size-mismatched cache file be removed from queue metadata and treated as a cache miss?
5. What serialization rule should govern concurrent hits, promotions, admissions, and evictions so a preview cannot be read while being evicted or exist in both queues?
6. When the renderer version changes while a job is queued, should the version be fixed when the job is created or re-resolved before rendering?

Please approve or revise the LLD, and answer or explicitly defer the probe items.