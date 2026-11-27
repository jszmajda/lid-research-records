I've updated `docs/intent/previews/previews-design.md` with the 2Q cache design and recorded the eviction policy choice in its `Decisions & Alternatives` table, and removed the stale *"Its eviction policy remains open."* sentence from `docs/high-level-design.md` so the HLD and LLD stay coherent.

### Phase 2 Output — `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set. The cache must keep comparison sheets warm across screening passes without retaining stale popularity after editors switch projects.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before enqueuing a render job. The cache key combines clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data occupies at most 12 GiB under a 2Q replacement policy that separates first-use sheets from reused sheets:

- **Probation queue (FIFO)**: Newly rendered contact sheets enter the probation queue on admission. One-off sheets from sequential screenings age out in arrival order without disturbing reused sheets.
- **Protected queue (LRU)**: Reused sheets promoted out of first-use probation reside in the protected queue, where each cache hit refreshes recency and eviction removes the least-recently-used sheet.
- **Admission and eviction**: Before admitting a completed sheet, the worker evicts enough existing cached sheets to keep total cached JPEG bytes within the 12 GiB bound and honor the configured queue split between probation and protected storage.

Temporary render output is stored outside the cache budget and removed on completion or failure. Eviction deletes only cached JPEG files and private queue entries; it never deletes source footage or changes job-ticket semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache eviction policy | 2Q (FIFO probation + LRU protected queues) | Single-queue LRU; frequency-based eviction with aging | Sequential screenings stream thousands of single-use contact sheets that would flush comparison sets under plain LRU, while aged frequency counters add ongoing maintenance and hold yesterday's popular clips after editors switch projects. 2Q isolates one-off scans in probation and keeps replacement bookkeeping private to the preview worker, at the cost of maintaining multiple queues and tuning their capacity split. |

## Open Questions & Future Decisions

### Deferred

1. **Queue capacity split**: Choose the byte-budget partition between the probation queue and the protected queue within the 12 GiB cache limit.
2. **Promotion trigger (resident hit vs. ghost history)**: Confirm whether a cache hit while resident in the probation queue promotes directly to the protected queue, or whether keys evicted from probation are tracked in a bounded non-resident ghost queue (`A1out`) and promoted upon re-admission.

## References

- High-Level Design: `docs/high-level-design.md`
- Preview Specifications: `docs/intent/previews/previews-specs.md`
```

---

### Phase 2 LLD Edge-Case Probe & Unsettled Choices

Please triage which of these items you want resolved in `previews-design.md` now versus kept deferred as open questions before we move to Phase 3 (`previews-specs.md`):

1. **Queue split & slack borrowing**: What initial byte split should probation vs. protected target within the 12 GiB limit (e.g., 3 GiB / 9 GiB), and while total cached data is under 12 GiB, does each queue enforce a hard sub-cap immediately or borrow unused slack until total usage hits 12 GiB?
2. **Promotion mechanic (`A1` hit vs. `A1out` ghost queue) and initial `202 -> 200` poll**: Because every render miss returns `202` and the waiting caller polls two seconds later to fetch the newly admitted JPEG (`200`), if resident hits in probation promote directly to protected, that initial post-render delivery poll (or concurrent polls from a deduplicated `202` batch) could promote every one-off screening clip immediately. Should 2Q use classic ghost history (`A1out` keys evicted from probation promote only on subsequent re-render/re-admission), or resident promotion that ignores the initial delivery window?
3. **Protected-queue overflow on promotion**: When promoting a sheet pushes the protected queue past its target share, is the LRU victim evicted from the cache outright or demoted into the probation queue?
4. **Render failures & retry polling**: When a render job fails and is cleared from the deduplication map, what HTTP status does the endpoint return on failure, and does a waiting caller's two-second poll immediately enqueue a fresh `202` job (risking a tight retry loop on deterministic media errors) or receive a failure response?
5. **Render queue backpressure**: With four active render workers, is the waiting FIFO render queue bounded (returning `503` when full) or unbounded during heavy screening bursts?
6. **Startup & renderer-version rollover**: On worker restart or a `renderer version` bump, does the worker purge unrecognized/older-version cached JPEGs on disk, or scan and rebuild 2Q state?
7. **Concurrent read vs. eviction**: What happens if an entry is selected for eviction while an in-flight `200` response is streaming its JPEG bytes?

Let me know how you'd like to handle these items (by number) and confirm when you're ready to proceed to **Phase 3 (EARS specs)**.