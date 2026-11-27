I updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md` to settle the cache eviction policy on 2Q and recorded the rationale and rejected alternatives (LRU and frequency-based eviction with aging) in the Previews LLD's `Decisions & Alternatives` table (without a separate decision doc, since the choice stays entirely private to the preview worker and does not affect sibling nodes).

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

The cache uses 2Q eviction to protect repeatedly viewed comparison sheets from one-off sequential screening scans. New sheets enter a first-in, first-out probationary queue (`A1in`) on initial admission; evicted keys from `A1in` are tracked in a bounded ghost history (`A1out`), and a subsequent access promotes the sheet into the main LRU queue (`Am`).

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Documentary editors alternate long sequential screenings of one-off clips with repeated comparisons of a small working set. 2Q isolates one-off screening scans in a probationary queue so they do not evict comparison sheets in `Am`, whereas plain LRU flushes the working set during long scans and aged frequency counters add ongoing aging maintenance and lag when editors switch projects. All bookkeeping stays private to the preview worker. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please let me know which of these LLD gaps we should fix in `previews-design.md` now versus defer to `Open Questions & Future Decisions`:

1. **2Q queue sizing and partition split**: What is the capacity split between the probationary FIFO queue (`A1in`) and the main LRU queue (`Am`) within the 12 GiB budget (e.g., 25% / 3 GiB `A1in` and 75% / 9 GiB `Am`), and how is `A1out` (key-only ghost history) bounded (e.g., by key count such as 3,000 keys, or a virtual byte budget)?
2. **Hits while resident in `A1in`**: Per classic 2Q, does a cache hit on a sheet currently resident in `A1in` leave it in `A1in` (promoting to `Am` only when re-rendered after eviction into `A1out`), or should a second hit while still in `A1in` immediately promote it to `Am`?
3. **Oversized or variable-size sheets during eviction**: Since sheets average ~2 MiB but vary in byte size, when admitting a sheet requires eviction, does the worker evict from `A1in` whenever `A1in` exceeds its target byte share (otherwise evicting from `Am` tail), and what happens if a single rendered sheet exceeds the `A1in` partition or total cache limit?
4. **Render queue backpressure and failure response**: Does the FIFO render queue (max 4 active jobs) have a maximum pending depth before rejecting new misses (e.g., with `503`), and what HTTP status is returned to a polling request after a render job fails?
5. **Cold-start vs. persisted cache state**: On worker restart, is the 12 GiB cache directory cleared/rebuilt from disk (and if rebuilt, into which queue), or is 2Q metadata purely in-memory?

How would you like to resolve or defer these items, and does the updated LLD look ready to approve?