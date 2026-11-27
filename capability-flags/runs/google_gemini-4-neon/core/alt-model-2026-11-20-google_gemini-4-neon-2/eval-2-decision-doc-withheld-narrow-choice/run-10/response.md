Updated the preview design to adopt **2Q** eviction and recorded the choice in the LLD's **Decisions & Alternatives** table (since the policy is private to the preview worker and does not affect other nodes). I also removed the now-stale *"Its eviction policy remains open."* note from `docs/high-level-design.md` so the HLD stays coherent.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses a **2Q** replacement policy, kept entirely private to the preview worker:

- **Probation queue (FIFO)**: holds newly admitted sheets on first use. One-off sequential screening scans cycle through this queue without displacing reused sheets.
- **Protected queue (LRU)**: holds sheets that have demonstrated reuse. Hits in this queue refresh recency.
- **Ghost history (FIFO, keys only)**: tracks keys recently evicted from the probation queue without retaining JPEG bytes. When a key present in the ghost history is rendered again, it is admitted directly to the protected queue instead of probation.

The 12 GiB byte budget is partitioned between the probation and protected queues via a configurable size split (defaulting to a smaller probation share and larger protected share, tunable for the pilot workload). When admitting a sheet requires space, the worker evicts from the probation queue while it exceeds its target share, and otherwise evicts the least-recently-used entry from the protected queue.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Protects repeatedly accessed comparison sheets from being evicted by long sequential screening scans, without the counter-aging lag of frequency-based eviction when editors switch projects. Accepts extra queue bookkeeping and a tunable queue-size split, all isolated inside the preview worker's private cache. |

## Open Questions & Future Decisions

### Deferred
1. Tune the probation/protected queue-size split and ghost history bound using pilot workload hit-rate observations.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please triage these internal gaps — let me know which to specify in the LLD now vs. defer as open questions:

1. **Cache hit in the probation queue:** When a `GET` hits a sheet currently in the probation queue, does it stay in probation (classic 2Q, promoting only via ghost-history re-admission) or promote immediately to the protected queue?
2. **Ghost history bound and entry lifecycle:** Is the ghost history bounded by key count or remembered byte size, and is a key removed from the ghost history once re-rendered and admitted to the protected queue?
3. **Eviction fallback and oversized sheets:** If admission needs space while the probation queue is at or below its target share and the protected queue cannot free enough bytes, does eviction fall back to draining probation below its target share? And what happens if a single rendered JPEG exceeds its target queue share or the 12 GiB cap?
4. **Concurrent admission, eviction, and in-flight reads:** With up to four render jobs completing alongside `GET` traffic, how are concurrent eviction/admission calculations serialized against the 12 GiB budget, and what happens if an evicted JPEG is currently being streamed for a `200` response?
5. **Admission failure and completion ordering:** If moving/writing a completed render into the cache fails after evictions have already run, how is that handled, and in what order do cache admission, deduplication-map removal, and temporary-file cleanup happen so concurrent requests don't see a partial file or a gap between cache and dedup map?
6. **Render queue saturation:** When distinct cache misses arrive faster than the four active render slots can drain the FIFO queue, is the waiting queue unbounded or capped (and if capped, what happens to excess misses)?
7. **Worker restart and crash recovery:** On restart or crash, are cached JPEGs and 2Q metadata persisted, reconstructed from disk (into which queue), or wiped cold, and are orphaned temporary render files cleaned up on startup?

---

Let me know any edits to the LLD and how you'd like to triage items 1–7, and confirm when you're ready to proceed to **Phase 3 (EARS specs)**.