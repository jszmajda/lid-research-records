I've updated `docs/intent/previews/previews-design.md` (and removed the stale open-policy note in `docs/high-level-design.md`) to lock in 2Q eviction and record the choice in the LLD's `Decisions & Alternatives` table (no standalone decision doc needed, since the choice is bounded to `previews` and doesn't size sibling nodes).

### Updated LLD (`docs/intent/previews/previews-design.md`)

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

The cache uses 2Q eviction to separate first-use sheets from reused sheets: newly rendered previews enter a FIFO probation queue (`A1`), and a hit on a probation entry promotes it into a main LRU queue (`Am`). This protects comparison working sets from being flushed by long sequential screening scans, while keeping all replacement tracking internal to the preview worker without changing the HTTP contract, queue concurrency, or 12 GiB budget.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (FIFO probation queue + main LRU queue) | Plain LRU; frequency-based eviction with aging | Editors alternate long sequential screenings with repeated comparisons of small clip sets. Plain LRU has the lowest bookkeeping cost and adapts quickly when editors switch projects, but a sequential screening scan can evict active comparison sheets. Frequency-based eviction with aging retains popular clips, but counter maintenance and aging add overhead and can retain stale favorites across project switches. 2Q isolates one-off screening scans in the probation queue while protecting repeatedly accessed comparison sheets in the main queue, and confines the added queue bookkeeping and size-split configuration entirely within the preview cache. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD and let me know which of these `previews` gaps we should specify in the LLD now versus defer to `Open Questions & Future Decisions`:

1. **2Q queue structure & ghost history (`A1in` / `A1out` vs. Simplified 2Q)**: When a sheet is evicted from the FIFO probation queue before a second hit, should the cache retain its key in a ghost list (`A1out`) so a subsequent re-request promotes it to the main LRU queue (`Am`) on re-render, or use simplified 2Q (single `A1` resident probation queue where promotion happens only on a hit while resident in `A1`)?
2. **Capacity split and eviction victim selection**: How is the 12 GiB budget split between probation (`A1`) and main (`Am`) (e.g., 25% / 3 GiB for `A1`, 75% / 9 GiB for `Am`), and when admitting a new sheet requires freeing space, does eviction draw from `A1` whenever `A1` exceeds its target budget (falling back to `Am`'s LRU tail otherwise)?
3. **Oversized single contact sheet**: What happens when a single rendered JPEG exceeds the probation budget (or the entire 12 GiB limit)—should it bypass caching or be rejected?
4. **Metadata persistence across worker restarts**:On startup, does the worker rebuild cache state from existing files on disk (e.g., placing recovered sheets into `A1` or `Am`), or clear the cache directory on startup?
5. **Unbounded FIFO render queue**: While active rendering is capped at 4 concurrent jobs, is the waiting FIFO render queue bounded (returning 503 when full) or unbounded?

How would you like to triage these items, and do you approve the LLD updates to proceed to Phase 3?