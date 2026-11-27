I have updated `docs/intent/previews/previews-design.md` with the 2Q cache design and recorded the eviction policy choice in its `Decisions & Alternatives` table. I also removed the stale `"Its eviction policy remains open."` note from `docs/high-level-design.md` (`review-api` is unchanged since replacement tracking stays private to the preview worker).

### Updated LLD (`docs/intent/previews/previews-design.md`)

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set and editors periodically move between projects.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB under a private 2Q replacement policy with two queues:

- **Probation queue (FIFO)**: Newly rendered contact sheets enter the probation queue on admission. One-use sheets from sequential screenings pass through in arrival order without displacing reused comparison sheets.
- **Protected queue (LRU)**: A cached sheet requested again is promoted from the probation queue into the protected queue, and subsequent hits in the protected queue refresh its recency.

A configurable size split divides the 12 GiB byte budget between the probation queue and the protected queue. Before admitting a completed sheet, the worker evicts enough existing sheets to keep total cached JPEG data within 12 GiB, evicting from the front of the probation queue when probation usage exceeds its share and evicting least-recently-used sheets from the protected queue when protected usage exceeds its share or additional space is still required.

Temporary render output is kept separately and removed on completion or failure. Eviction removes the cached JPEG and its queue metadata without deleting source footage or changing job-ticket semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache eviction policy | 2Q (FIFO probation queue + LRU protected queue) | LRU; frequency-based eviction with aging | Long sequential screenings flush useful comparison sheets from a plain LRU cache, while aged frequency counters add per-access maintenance and can retain stale favorites after editors switch projects. 2Q isolates single-use screening sheets in a probation queue so reused comparison sheets stay protected, keeping all extra queue bookkeeping private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Byte-budget split between the probation queue and the protected queue within the 12 GiB cache limit, to be tuned against production screening and comparison workloads.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`previews-specs.md`), please triage which of these internal gaps to specify in `previews-design.md` now versus defer under `Open Questions & Future Decisions`:

1. **First `200` poll after `202` vs. probation promotion**: Because every cache miss returns `202` and requires at least one follow-up `GET` after rendering completes to deliver the JPEG, promoting on the very first `200` hit in probation would immediately promote every single-use screening sheet. Should a newly admitted probation entry treat its initial `200` delivery as the first use (promoting only on a *subsequent* `200` hit), and how should multiple callers that shared the same `202` job ticket be counted?
2. **Ghost history (`A1out`) vs. resident-only two-queue**: Should the cache maintain a bounded key-only ghost FIFO of entries evicted from probation (canonical 2Q, so a sheet evicted from probation and re-requested soon promotes to protected on re-render), or use two resident queues only (promoting only when hit while still in probation)?
3. **Queue shares — hard partition vs. work-conserving slack, and promotion overflow**:
   - When total cached data is under 12 GiB (e.g., protected is nearly empty), does probation still evict at its configured share, or do queue shares only govern victim selection once the 12 GiB total limit is reached?
   - What initial default split should the worker use prior to tuning (e.g., 25% probation / 75% protected)?
   - When promoting an entry from probation to protected pushes protected bytes past its share, should protected evict LRU entries immediately, demote them to probation, or trim lazily on the next admission?
4. **Oversized contact sheets**: What happens if a completed JPEG exceeds the probation queue's byte share (or 12 GiB)?
5. **Render failure vs. polling callers**: When a render job fails and leaves the deduplication map while callers are polling every two seconds, should the next poll re-enqueue and return `202`, or does the internal endpoint need an error status (e.g., `500`/`422`) for render failures?
6. **Concurrent `200` streaming during eviction**: When an entry is evicted while a `GET` response is actively streaming its JPEG, is the entry pinned until the stream finishes or unlinked while open (and how do those bytes count against the 12 GiB limit)?
7. **Worker restart and `renderer-version` upgrades**: On startup, does the worker clear the cache directory, rebuild probation state from disk, or persist 2Q queue metadata? When `renderer-version` increments, are prior-version entries purged on startup or left to age out via eviction?

How would you like to resolve or defer these items, and once settled, do you approve moving to Phase 3 (updating `previews-specs.md`)?