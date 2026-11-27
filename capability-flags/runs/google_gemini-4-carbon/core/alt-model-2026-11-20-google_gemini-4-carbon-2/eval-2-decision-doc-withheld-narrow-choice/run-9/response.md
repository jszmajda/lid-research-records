`docs/intent/previews/previews-design.md` is updated with the 2Q cache design and its `Decisions & Alternatives` entry, and the stale `"Its eviction policy remains open."` note is removed from `docs/high-level-design.md` (keeping replacement details private to `previews`).

### Updated LLD (`docs/intent/previews/previews-design.md`)

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The preview worker renders one JPEG contact sheet per immutable clip revision and renderer version. Documentary editors alternate long sequential screenings—which stream many single-use sheets—with comparison sessions that repeatedly revisit a small working set. The preview worker absorbs both access patterns behind a fixed HTTP contract while keeping render deduplication, cache files, and replacement bookkeeping strictly private.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache state or eviction activity.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy state, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before enqueuing a render job, returning 404 immediately when the revision is unknown. The cache key combines clip ID, revision, and renderer version. Concurrent misses for one key share a single pending job ticket. Once rendering completes and the sheet is admitted to the cache, subsequent requests receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can enqueue a fresh render.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Temporary render output is kept separately and removed on completion or failure, so in-flight renders do not count against the cached JPEG budget. Eviction deletes only cached JPEG files and internal replacement metadata; it never deletes source footage or changes job-ticket semantics.

Replacement uses a 2Q policy within the 12 GiB budget to protect reused comparison sheets from sequential screening scans:

- **First-use queue (FIFO)**: Newly rendered contact sheets enter a probationary FIFO queue on initial cache admission. Sheets viewed once during a sequential screening age out in admission order without displacing reused entries.
- **Reused queue (LRU)**: A cached contact sheet that is requested again promotes from the first-use queue to the protected LRU queue. Subsequent hits in the reused queue refresh recency, keeping active comparison sheets warm during screenings while allowing older comparison sets to age out when editors switch projects.
- **Admission and eviction**: Before admitting a completed sheet that would push cached JPEG data past 12 GiB, the worker evicts existing entries until enough space is free—evicting the oldest entry from the first-use FIFO queue when that queue exceeds its configured byte share, and otherwise evicting the least-recently-used entry from the reused queue. The byte-share split between the two queues is an internal worker parameter.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Private cache eviction policy | 2Q (probationary first-use FIFO + protected reused LRU) | Single-queue LRU; frequency-based eviction with aging | Sequential screenings touch long runs of single-use clips that flush active comparison sheets under plain LRU. Aged frequency counts retain repeatedly viewed clips across scans, but add ongoing counter and decay maintenance and release stale favorites more slowly when editors switch projects. 2Q isolates one-off screening admissions in a FIFO probation queue while letting promoted comparison sheets age naturally by recency, keeping all extra queue bookkeeping and split tuning private to the preview worker. |
| Cache miss response | Asynchronous `202` with shared job ticket and two-second retry interval | Synchronous blocking render on `GET`; uncoordinated duplicate renders | At roughly 450 ms per render and at most four active jobs on the eight-core worker, blocking requests would hold caller HTTP connections open during screening bursts, while duplicate renders would waste worker cores when concurrent requests miss on the same clip revision. |

## Open Questions & Future Decisions

### Deferred

1. Byte-share split and tuning rules between the first-use FIFO queue and the reused LRU queue within the 12 GiB cache limit.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`previews-specs.md`), please review the LLD above and let me know which of these internal `previews` edge cases you want settled in the design now versus deferred under Open Questions:

1. **First `200` retrieval after `202` vs. 2Q promotion**: After a miss returns `202` and the completed sheet enters the first-use FIFO queue, the caller retries `GET` ~2 seconds later to fetch the JPEG for the first time. Should that initial post-render `200` delivery leave the entry in the first-use queue (so only a *subsequent* view promotes it—preventing every uncached screening clip from promoting on its retry poll), and how should multiple callers polling from the same shared `202` ticket be counted?
2. **Strictly two queues vs. evicted-key ghost history (`A1out`)**: When a sheet ages out of the first-use FIFO queue, should its replacement metadata be dropped completely (promotion requires a second hit while still resident in first-use), or should a bounded key-only ghost FIFO remember recently evicted keys so a revisited clip promotes on re-render?
3. **Queue-split boundary and empty-queue fallback**: What initial byte-share split (if any default should be named now) divides the 12 GiB cap, and if total bytes would exceed 12 GiB while one queue is empty or below its share, should eviction fall back to whichever queue has entries?
4. **Worker restart and renderer-version bumps**: On startup (or after `renderer_version` increments), should the worker start with a clean cache directory or rebuild 2Q state from on-disk JPEGs—and if rebuilt, into which queue do existing files go and how are prior renderer-version JPEGs reclaimed?
5. **Repeated render failures and queue pressure**: Given the `200` / `202` / `404` contract, what happens when a valid clip revision repeatedly fails to render (e.g., corrupt source media or a hung render timeout), or when a screening burst backs up the FIFO render queue behind the four active slots?
6. **Concurrent `200` reads and admission handoff**: What ordering/file-safety invariant holds when a `GET` arrives mid-admission as a render completes, or when an entry is selected for eviction while an active `200` response is streaming its JPEG bytes?

Let me know your feedback on the LLD and how you'd like to triage items 1–6 before we proceed to Phase 3 (EARS specs).