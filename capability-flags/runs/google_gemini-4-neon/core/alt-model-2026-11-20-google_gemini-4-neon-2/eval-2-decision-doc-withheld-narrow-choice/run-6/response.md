Updated `docs/intent/previews/previews-design.md` to specify 2Q as the private cache eviction policy with a `Decisions & Alternatives` entry, and removed the stale "Its eviction policy remains open." note from `docs/high-level-design.md` to keep the HLD coherent.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses a 2Q replacement policy to isolate one-off screening scans from repeatedly accessed comparison sheets. Two byte-bounded queues partition the 12 GiB budget using a configurable size split:

- **Probation queue (FIFO)**: receives newly rendered sheets on first admission. Eviction from probation drops the oldest entry first so sequential scans cycle through probation without displacing reused sheets.
- **Main queue (LRU)**: holds sheets that have been reused. A cache hit on a probation entry promotes it to the most-recently-used position of the main queue; a cache hit on a main-queue entry refreshes its position to most-recently-used. When the main queue exceeds its share of the budget, its least-recently-used entries are evicted.

All queue metadata and the size-split configuration are private to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache eviction policy | 2Q | LRU, frequency-based eviction with aging | Separates first-use sheets from reused sheets so long sequential screenings do not evict active comparison sheets, accepting two queues and a tunable size split. LRU is vulnerable to sequential scans; frequency-based eviction with aging adds counter maintenance and can retain stale popular clips after a project switch. All replacement bookkeeping remains private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Initial probation-to-main queue size split for the 12 GiB budget (tunable based on observed screening vs. comparison workloads).
```

### Phase 2 LLD Edge-Case Probe

Please triage which of these gaps to specify in `previews-design.md` now vs. defer as open questions:

1. **Ghost queue vs. two-queue-only 2Q:** When a sheet is evicted from probation and requested again later, does it re-enter probation as a first-use sheet, or should the worker keep a bounded ghost queue of recently evicted probation keys so re-requested sheets admit directly into the main queue?
2. **Hard vs. soft queue partitions (and oversized sheets):** May one queue borrow unused headroom from the other up to the 12 GiB total, or are probation and main strictly hard-capped? If hard-capped, what happens if a single sheet exceeds the probation share?
3. **In-flight reads during eviction:** When a cached sheet is chosen for eviction while a `200` response is streaming its bytes, are in-flight reads protected (e.g., via unlinked open file handles or refcounting), and do those bytes count against the 12 GiB budget?
4. **Promotion and main-queue overflow:** When promoting a probation entry pushes the main queue over its share, are evicted main-queue entries dropped outright or demoted to probation?
5. **Render failure loops, queue depth, and completion handoff:** Should repeated deterministic render failures be bounded against 2-second retry loops, is the waiting FIFO render queue bounded, and how is the handoff between temp-file admission and deduplication-map removal sequenced?
6. **Worker restart and renderer-version upgrades:** On restart, is the cache rebuilt cold or scanned from disk, how are orphaned temp files cleaned up, and do older renderer-version sheets stay until naturally evicted?
7. **Error shapes outside 200/202/404 and `202` wire format:** What status codes/payloads apply for internal or malformed-input errors, and how are the `202` job ticket and two-second retry interval encoded?

Stopping at **Phase 2** for your review. Let me know what to adjust in the LLD and how you want to triage the probe items before we move to Phase 3 (updating `docs/intent/previews/previews-specs.md`).