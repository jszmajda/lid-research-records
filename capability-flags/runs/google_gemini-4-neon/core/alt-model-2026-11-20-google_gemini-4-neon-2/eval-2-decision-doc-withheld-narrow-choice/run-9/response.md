Updated `docs/intent/previews/previews-design.md` with the 2Q eviction design and its Decisions & Alternatives entry, and removed the now-stale "Its eviction policy remains open." sentence from `docs/high-level-design.md`. `review-api` is unaffected, so no cross-segment cascade is needed.

### Updated LLD (`docs/intent/previews/previews-design.md`)

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The cache must protect reused sheets during sequential scans without keeping stale sheets indefinitely across project switches.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses 2Q replacement to separate one-use screening sheets from repeatedly viewed comparison sheets:

- **First-use queue (`A1in`)**: A FIFO queue holding newly rendered sheets on first admission, bounded by a configurable byte share of the 12 GiB cache budget.
- **Reused queue (`Am`)**: An LRU queue holding sheets that have been accessed more than once, occupying the remainder of the 12 GiB budget. A hit on an entry in `Am` moves it to the most-recently-used position.
- **Ghost history (`A1out`)**: A bounded FIFO list of recently evicted `A1in` keys (metadata only, no JPEG bytes). When a previously evicted key in `A1out` is requested and re-rendered, it is admitted directly into `Am` rather than `A1in`.

When space is needed to admit a completed sheet, the worker evicts from the tail of `A1in` while `A1in` is at or above its configured byte share (recording the evicted key in `A1out`), and otherwise evicts the least-recently-used entry from `Am`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Separates one-use screening sheets from reused comparison sheets so sequential scans do not evict active working sets, while adapting to project switches faster than aged frequency counters. Extra queue bookkeeping and size-split tuning remain private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Initial byte-share split between `A1in` and `Am` and capacity of `A1out`, to be tuned against pilot screening and comparison workloads.
```

### Phase 2 Edge-Case Probe (for triage)

A cold-read probe of `previews-design.md` surfaced these structural gaps. For each, please indicate whether to specify it in the LLD now or defer it as an open question:

1. **Cache hit in `A1in`**: When a request hits a sheet currently in `A1in`, does it stay in `A1in` (classic 2Q, only promoting via `A1out` after eviction and re-render) or promote immediately into `Am`?
2. **`A1out` lookup timing and cleanup**: Is `A1out` membership checked at request/enqueue time or at admission time (if evicted from `A1out` while rendering), and is the key removed from `A1out` upon admission to `Am`?
3. **Eviction fallback when `Am` is empty**: When space is needed, `A1in` is below its configured byte share, and `Am` is empty (or emptied before freeing enough bytes), does eviction fall back to evicting from `A1in` below its share?
4. **Oversized single sheet**: What happens if a rendered JPEG exceeds `A1in`'s byte share (or the 12 GiB total cap)—bypass caching or evict across queues?
5. **Eviction concurrent with serving**: What happens if a cached JPEG is selected for eviction while an in-flight `200` response is still reading/streaming it?
6. **Concurrent admissions**: When multiple of the up to four active renders finish simultaneously, are eviction, byte accounting, and 2Q queue updates serialized so admissions cannot overshoot 12 GiB?
7. **Deduplication-to-cache handoff**: How are cache insertion and deduplication-map removal ordered at render completion so concurrent requests neither read an uncommitted entry nor enqueue a duplicate render?
8. **Render failure retries**: When a render fails permanently (e.g., corrupt media) and is removed from the deduplication map, does the next poll silently re-enqueue a new render (risking a `202` loop) or surface an error?
9. **Render queue backpressure**: Is the FIFO render queue bounded (and what response is returned if full) or unbounded?
10. **Other error shapes**: What responses are returned for malformed `clip-id`/`revision`, transient source-resolution failures, or local disk I/O errors outside `200`/`202`/`404`?
11. **Restart and crash recovery**: Do the 2Q queues and cached JPEGs start cold or persist across worker restarts, and how are orphaned cache/temp files reconciled against the 12 GiB cap?
12. **Byte accounting & renderer-version turnover**: Is the 12 GiB cap measured in JPEG payload bytes or filesystem blocks (with or without a cap on temporary render outputs), and do previous-renderer-version sheets age out naturally via 2Q or get purged on upgrade?

Please reply with any edits to the LLD, your triage of the probe items above, and whether you approve moving to Phase 3 (updating `docs/intent/previews/previews-specs.md`).