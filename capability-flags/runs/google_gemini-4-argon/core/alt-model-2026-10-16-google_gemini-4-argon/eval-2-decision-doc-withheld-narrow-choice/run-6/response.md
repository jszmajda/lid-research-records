I have updated `docs/high-level-design.md` (closing the open eviction-policy note in the Architecture summary) and drafted the 2Q cache design in `docs/intent/previews/previews-design.md` with a row in its **Decisions & Alternatives** table (recording the choice in the table rather than a standalone decision doc, since the choice is bounded to the `previews` leaf and does not affect sibling nodes, API contracts, or sizing outside the preview cache).

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

The cache uses 2Q eviction to separate first-use sheets from reused sheets so long sequential screenings do not evict active comparison working sets. A newly rendered sheet enters the probationary first-use queue (`A1in`), and a ghost history queue (`A1out`) tracks keys recently evicted from `A1in` without retaining their JPEG bytes. A cache hit on a sheet in `A1in` or a re-rendered sheet whose key is present in `A1out` promotes the entry into the protected main LRU queue (`Am`), where subsequent hits refresh its recency.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Protects repeatedly compared sheets during long sequential screening scans at the cost of maintaining two queues and a split parameter, whereas plain LRU evicts comparison working sets during scans and aged frequency counters add ongoing maintenance and lag when editors switch projects. All replacement tracking remains private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Queue capacity split between `A1in` and `Am`, and Ghost queue (`A1out`) bound.
2. Whether ghost history (`A1out`) promotion happens only on re-admission after a miss or also on hit within `A1in`.
3. Eviction order when `A1in` is below its target share vs. above it, and behavior when a single sheet exceeds a queue partition bound.
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD and let me know which of these 2Q design gaps we should fix in the LLD now versus defer:

1. **Queue split and ghost-queue sizing**: How should the 12 GiB budget be split between the probationary FIFO queue (`A1in`) and the protected LRU queue (`Am`) (e.g., 25% / 3 GiB for `A1in` and 75% / 9 GiB for `Am`), and is `A1out` (ghost keys only) bounded by entry count (e.g., 3,000 keys, roughly matching ~6 GiB of 2 MiB sheets) or a virtual byte total?
2. **Promotion trigger on `A1in` hit vs. `A1out` re-admission**: In classic 2Q, hits while an entry is still resident in `A1in` do *not* promote it to `Am` (avoiding promotion from immediate double-fetches during a single viewing), and promotion to `Am` happens only when a sheet is evicted from `A1in` into `A1out` and subsequently requested again. Simplified 2Q variants also promote on a hit inside `A1in`. Which behavior do you want?
3. **Victim selection across queues when total size exceeds 12 GiB**: Because contact sheets have variable byte sizes, should eviction pull from `A1in` whenever `bytes(A1in)` exceeds its target budget (and otherwise from `Am`), and what happens if `Am` is empty when `A1in` is below its target budget?
4. **Crash / restart persistence of 2Q metadata**: On worker restart, does the worker start with an empty cache, scan disk into `A1in`, or persist queue membership metadata across restarts?
5. **Oversized or corrupted cache files**: What happens if a rendered JPEG exceeds the target `A1in` partition (or the 12 GiB limit), or if a cached file on disk is missing/unreadable on a cache hit?

Please let me know your feedback on the HLD/LLD updates and how you'd like to resolve or defer items 1–5 before I proceed to Phase 3 (EARS specs).