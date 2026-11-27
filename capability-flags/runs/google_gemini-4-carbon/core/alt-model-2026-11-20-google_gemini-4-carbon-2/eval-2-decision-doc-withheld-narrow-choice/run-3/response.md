I updated `docs/intent/previews/previews-design.md` to settle on 2Q and record the decision and rejected alternatives in `## Decisions & Alternatives` (since replacement tracking is private to `previews` and affects no other node, it stays as an LLD table row rather than rising to the HLD). I also removed the stale `"Its eviction policy remains open."` sentence from `docs/high-level-design.md` so the two docs stay coherent.

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

Replacement uses a worker-private 2Q policy that partitions the 12 GiB budget between two queues:

- **First-use queue (FIFO)**: Newly rendered sheets enter at the tail on cache admission. One-off sheets from long sequential screenings advance to the head and are evicted in arrival order without displacing reused comparison sheets.
- **Reused queue (LRU)**: Sheets requested again promote into the reused queue, where subsequent hits refresh recency and eviction removes the least-recently-used entry. When editors switch projects, inactive comparison sets age out in LRU order.

All queue membership, byte accounting, and split configuration stay internal to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (FIFO first-use queue + LRU reused queue) | LRU; frequency-based eviction with aging | Protects repeatedly revisited comparison sheets from sequential screening scans while letting inactive comparison sets age out by recency when editors switch projects, with all extra bookkeeping contained inside the preview cache. LRU has minimal bookkeeping and adapts quickly on project switches, but sequential screenings evict active comparison sheets. Frequency-based eviction with aging retains repeatedly popular clips, but adds counter and aging maintenance and holds prior favorites too long after a project switch. |

## Open Questions & Future Decisions

### Open
1. **Queue budget split**: How the 12 GiB byte limit is partitioned between the first-use FIFO queue and the reused LRU queue (and whether an under-capacity queue yields slack bytes to the other until total cached data reaches 12 GiB).
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`previews-specs.md`), please review the updated LLD above and triage which of these component-internal gaps and ambiguities to resolve in the LLD now vs. defer under Open Questions:

1. **First-delivery poll vs. 2Q promotion (`202` -> `200` interaction)**: Because a cache miss returns `202` and admits the rendered sheet asynchronously, the requesting client's two-second retry `GET` is a cache hit. If *every* hit on the first-use queue promotes to the reused queue, one-off screening sheets will promote on their initial retrieval. Should the first `200` delivery (or all initial retries associated with that render wave/job ticket) leave the sheet in the first-use FIFO queue, promoting only on a subsequent request?
2. **Two resident queues vs. ghost eviction history (`A1out`)**: Does promotion happen only when a hit finds the sheet *still resident* in the first-use FIFO queue, or should evicting from the first-use queue retain a bounded ghost-key FIFO (no JPEG bytes) so a clip revisited after a screening larger than the first-use partition promotes to the reused LRU queue on re-render?
3. **Queue budget split & promotion eviction**: What initial split of the 12 GiB budget should separate the first-use FIFO queue from the reused LRU queue (e.g., 25% / 75%), can either queue use slack bytes while total cached data is under 12 GiB, and when a promotion finds the reused queue full, does the `GET` path synchronously evict LRU entries from the reused queue?
4. **Concurrent admissions & in-flight `200` reads**: Up to four renders can complete at once while `GET` handlers stream cached JPEGs. Should cache byte accounting/eviction be serialized across admissions, and how are files being streamed for an active `200` response protected if simultaneously chosen for eviction (e.g., open-file-descriptor unlink semantics or reference counting)?
5. **Worker restart & renderer-version rollover**: On worker restart, does the cache start cold (clearing prior cache and orphaned temp files) or rebuild state from disk (and if rebuilt, into which queue)? When `renderer version` increments, do older-version entries simply age out through normal 2Q eviction?
6. **Render queue bounds, failure loops, and `202` wire format**: Should the LLD specify the `202` response payload/headers (job ticket shape + `Retry-After: 2`), whether the FIFO render queue has a maximum depth or per-job timeout, and what happens when a valid clip revision has corrupt/undecodable media (so retries don't loop `202` forever)?

How would you like to resolve or defer items 1–6, and do you approve the `previews-design.md` update once those adjustments are folded in?