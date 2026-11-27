I updated `docs/intent/previews/previews-design.md` to specify the 2Q cache replacement policy and recorded the selection in its `Decisions & Alternatives` table, with queue-split tuning tracked under `Open Questions & Future Decisions`. As a coherence pre-flight cleanup, I also removed `"Its eviction policy remains open."` from `docs/high-level-design.md` (line 14); `review-api` is unaffected because replacement bookkeeping stays private to the preview worker.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set and shift focus when editors switch projects.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB, managed with a private 2Q replacement policy that separates first-use sheets from reused sheets across two queues:

- **First-use queue (FIFO)**: Newly rendered contact sheets enter the first-use queue on cache admission. One-use sheets from sequential screenings age out in arrival order without displacing reused comparison sheets.
- **Reused queue (LRU)**: Once a cached sheet has been served once, a subsequent hit in the first-use queue promotes it to the most-recently-used position of the reused queue, and hits in the reused queue refresh its recency. Active comparison sheets stay protected during screenings and age out naturally when editors switch projects.
- **Capacity and eviction**: A worker-private size-split parameter partitions the 12 GiB budget between the first-use queue and the reused queue. Before admitting a completed sheet that would exceed 12 GiB of cached JPEG data, the worker evicts enough existing entries—from the first-use FIFO tail while the first-use queue exceeds its target share (or if the reused queue is empty), otherwise from the reused LRU tail—to remain within 12 GiB.

Temporary render output is kept separately outside the cache budget and removed on completion or failure. Eviction deletes only cached JPEG data and updates internal queue bookkeeping; it never deletes source footage or changes job-ticket semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (first-use FIFO and reused LRU queues) | Single-queue LRU; frequency-based eviction with aging | Protects repeatedly compared contact sheets from sequential screening scans without retaining stale historical favorites across project switches, while keeping all replacement bookkeeping private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Queue-size split tuning between the first-use FIFO queue and the reused LRU queue within the 12 GiB cache bound.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`previews-specs.md`), please review the draft above and triage which of these internal gaps and unsettled choices to resolve in `previews-design.md` now versus defer under `Open Questions & Future Decisions`:

1. **Post-`202` retry poll vs. 2Q promotion**: When a miss triggers a background render and admits the sheet into the first-use queue, the caller's follow-up poll two seconds later is technically a cache hit. The draft currently treats the first `200` delivery as the initial use and promotes only on a subsequent hit—should promotion work that way, and what happens when two editors shared the same `202` ticket and both poll for the completed sheet?
2. **Two resident queues vs. ghost history (`A1out`)**: The draft specifies two resident queues (first-use FIFO + reused LRU) with no evicted-key ghost list, so a sheet evicted from the first-use queue re-enters as first-use if requested again later. Should we keep this resident-only two-queue model, or retain bounded ghost keys (`A1out`) after first-use eviction so re-rendered comparison clips promote directly to the reused queue?
3. **Soft (work-conserving) vs. hard queue split, and promotion overflow**: The draft treats the queue split as a soft target enforced only when total cached bytes would exceed 12 GiB (allowing either queue to use idle space below 12 GiB, and allowing promotion from first-use to reused without immediate eviction). Is that intended, or should each queue enforce a hard byte cap?
4. **Render failure outcome on follow-up poll**: The HTTP contract lists only `200`, `202`, and `404`, and failed jobs leave the deduplication map so a later request can retry. What happens when a client polls after a render fails on a corrupt or unreadable source clip—does it enqueue a fresh `202` job indefinitely, or is there a worker error status (`5xx`)?
5. **Synchronous vs. queued revision resolution**: Is an unknown clip revision checked synchronously before returning `202`/`404`, and on a cache hit can the worker serve directly from the immutable key without re-resolving the source catalog?
6. **Concurrent `200` streaming during eviction**: What happens if an entry at the eviction tail is concurrently being streamed in an active `200` response (e.g., reference-counted/unlinked file handle vs. skipping in-flight entries during victim selection)?
7. **Worker restart and `renderer version` bumps**: On worker startup or a `renderer version` increment, is the on-disk cache wiped cleanly, or are existing JPEGs and/or 2Q queue metadata reloaded (and stale renderer-version files swept so they do not leak into the 12 GiB budget)?

Let me know how you'd like to handle numbered items 1–7 (fix in the LLD now vs. defer) and whether you approve `previews-design.md` to proceed to Phase 3 (EARS specs).