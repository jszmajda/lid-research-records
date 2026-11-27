Updated `docs/intent/previews/previews-design.md` with 2Q cache replacement and a `Decisions & Alternatives` entry, and removed the stale "eviction policy remains open" note from `docs/high-level-design.md`. `docs/intent/previews/previews-specs.md` is not updated yet — stopping here for Phase 2 review.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses **2Q** replacement to protect repeatedly compared sheets from being flushed by long sequential screenings:

- **Probation queue (`A1in`, FIFO)**: Newly rendered sheets enter here when their key is not present in the ghost queue. One-off screening sheets age out in FIFO order without displacing reused comparison sheets. A cache hit in `A1in` serves the sheet without promoting it to `Am`, preventing short sequential bursts from polluting the main queue.
- **Main queue (`Am`, LRU)**: Reused sheets live here, ordered by recency of access. A cache hit in `Am` moves the entry to the most-recently-used position.
- **Ghost queue (`A1out`, FIFO)**: Retains only preview keys (no JPEG bytes) recently evicted from `A1in`, bounded by a fixed entry count. When a cache miss renders a key present in `A1out`, the completed sheet is admitted directly to `Am` and removed from `A1out`.

When space is needed to admit a completed sheet within the 12 GiB byte limit, the cache evicts from `A1in` while `A1in` exceeds its target share of the cache budget (recording evicted keys in `A1out`), and from `Am` otherwise. The `A1in`/`Am` byte-budget split (initial target: 25% `A1in`, 75% `Am`) and the `A1out` entry-count cap are private worker parameters tuned against production workloads.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Separates one-off screening sheets from reused comparison sheets so long sequential screenings do not flush the comparison working set, while avoiding the counter-aging overhead and slow adaptation to project switches of frequency-based schemes. Accepts extra queue bookkeeping and a tunable queue-size split, all private to the preview worker. |
```

### Phase 2 Edge-Case Probe (for triage)

Which of these should we resolve in `previews-design.md` now vs. defer as open questions?

1. **2Q eviction fallback & oversized sheets**: When `A1in` is at or below its 25% target share but `Am` is empty or too small to free enough bytes (e.g., cold start or after a project switch), should eviction fall back to `A1in`? And what if a single rendered JPEG exceeds `A1in`'s 25% share (or 12 GiB)?
2. **Ghost queue (`A1out`) check timing**: If a key is in `A1out` when the miss arrives and is enqueued, but gets evicted from `A1out` before rendering finishes, is `A1out` membership checked at miss time or at admission time?
3. **Concurrent reads vs. eviction & concurrent admissions**: When an entry is evicted while a `200` response is mid-read, do in-flight reads stay valid (e.g., unlink-while-open / refcounting) and do those bytes count against the 12 GiB limit? How are concurrent admissions across the four render slots serialized?
4. **Admission vs. deduplication-map ordering**: Are cache admission and deduplication-map removal atomic so a concurrent request cannot see neither a cached entry nor an active job ticket? What if moving the temporary output into the cache fails?
5. **Render queue bounds**: Is the FIFO render queue unbounded under a burst of misses, or capped with a backpressure response (e.g., `503`/`429`)?
6. **Hung or persistently failing renders**: Is there a per-job render timeout so a hung render cannot hold a worker slot and dedup entry indefinitely, and how should a valid revision that persistently fails to render behave (keep returning `202` on retry vs. error)?
7. **Restart/crash recovery & renderer upgrades**: On worker restart, are the 12 GiB cache and 2Q queues (`A1in`/`Am`/`A1out`) cold/rebuilt or persisted, how are orphaned temp files cleaned up, and how are prior-renderer-version files cleared if the cache persists?

Let me know any edits to the LLD and how you'd like to triage items 1–7, or approve Phase 2 to move on to Phase 3 (`previews-specs.md`).