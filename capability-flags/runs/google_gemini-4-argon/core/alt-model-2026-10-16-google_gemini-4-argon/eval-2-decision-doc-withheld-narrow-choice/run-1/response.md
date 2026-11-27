I have updated `docs/high-level-design.md` (clearing the open-policy note) and `docs/intent/previews/previews-design.md` to record the 2Q replacement policy. Because all replacement queues and bookkeeping remain strictly internal to the preview worker (per the HLD tenet *Keep cache paths and replacement bookkeeping private to the preview worker*) and do not affect `review-api` or any other node, a row in the LLD's **Decisions & Alternatives** table captures the choice and trade-offs without needing a standalone decision doc.

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

The cache uses 2Q replacement to protect repeatedly compared sheets from eviction during sequential screenings. Newly rendered sheets enter a first-in, first-out probationary queue (`A1in`), while sheets hit again after initial admission are promoted to a main LRU queue (`Am`), with Ghost metadata (`A1out`) tracking recently evicted probationary keys so sheets revisited after a screening scan promote into `Am` on re-render. All queue structures, ghost-history metadata, and capacity-split parameters remain internal to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q replacement | LRU; frequency-based eviction with aging | Protects repeatedly revisited comparison sheets from sequential screening scans without retaining stale historical favorites across project switches; extra queue and ghost-key bookkeeping stays entirely within the preview worker. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the updated LLD and let me know which of these component-level questions we should resolve in the design now versus defer as open questions:

1. **Capacity split and ghost-queue sizing (`A1in` / `Am` / `A1out`)**: What byte budget or entry-count split should govern `A1in` vs. `Am` within the 12 GiB limit (e.g., 25% `A1in` / 75% `Am` by bytes), and how many ghost keys should `A1out` retain (e.g., bounded by key count such as 3,000–6,000 keys, or by equivalent evicted byte volume)?
2. **Promotion on `A1in` hit vs. `A1out` ghost hit**: In classical 2Q, a cache hit while an entry is still resident in `A1in` leaves it in `A1in` and only promotes to `Am` when a key is re-requested while in `A1out` (or alternatively, promotes to `Am` immediately on a second hit while still in `A1in`). Which promotion rule do you want?
3. **Oversized or variable-size sheet admission**: Because sheets vary in byte size around the ~2 MiB average, a newly rendered sheet may require evicting multiple entries from `A1in` or `Am` to free enough bytes, or could theoretically exceed `A1in`'s sub-budget on its own. How should eviction select between `A1in` and `Am` when freeing bytes, and what happens if a single sheet exceeds the `A1in` target budget?
4. **Startup / crash recovery**: Is the 2Q queue and ghost-key index held strictly in memory (rebuilding or starting cold when the worker restarts), or persisted alongside the cached JPEGs on disk?
5. **Concurrent hit and eviction during response streaming**: When a `200` response is actively streaming a cached JPEG and an admission triggers eviction of that entry, how is the in-flight read protected (e.g., reference counting, unlinking open file descriptors, or reading into memory before returning)?

How would you like to handle these items, and do you approve the LLD updates?