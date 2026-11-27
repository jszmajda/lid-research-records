2Q is now recorded as settled current intent — I haven't reopened the policy debate, and every change stays inside the previews node. The preview API, render queue, fixed 200/202/404 interface, and 12 GiB budget are unchanged; the review-api segment and its specs are untouched.

**Coherence pre-flight (resumption) + Phase 1 HLD check**
- EARS ↔ LLD: `PREVIEW-001…005` all trace to the previews LLD. Tests ↔ specs: no code or tests exist here (design-stage arrow); all five specs are `[ ]` active gaps — consistent, not drift.
- LLD ↔ HLD: fixed interface, FIFO queue (≤4 jobs), private 12 GiB cache, private replacement metadata — all match.
- Phase 1: the HLD covers the change and needs no architectural revision (2Q is internal to the preview worker, per the tenet "Keep cache paths and replacement bookkeeping private to the preview worker"). I removed the now-false "Its eviction policy remains open." line from the HLD so it reads as current intent.

**Phase 2 output — revised `docs/intent/previews/previews-design.md`**

```
# Previews Design

## Context
The worker renders one JPEG contact sheet per clip revision and renderer version. Long
screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller
working set. The mix varies by production, so the replacement policy must keep the reused
comparison set warm while absorbing one-off screening scans.

## Architecture
Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG
bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown
revision. This contract is fixed.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all
replacement-policy metadata belong exclusively to this worker. Other nodes do not access
files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication
Resolve the immutable source revision before rendering. The cache key includes clip ID,
revision, and renderer version. Concurrent misses for one key share a job ticket. Once
rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are
removed from the deduplication map so a later request can retry.

## Private Cache
Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict
enough existing sheets to remain within that bound. Temporary render output is kept
separately and removed on completion or failure. Eviction never deletes source footage or
changes job-ticket semantics.

The cache uses 2Q replacement with two queues: a probationary queue for first-use sheets
and a protected queue for sheets accessed again while cached. A newly admitted sheet
enters the probationary queue; a subsequent access to the same key promotes it to the
protected queue. Eviction draws from the probationary queue before the protected queue,
so a long sequential screening recycles through probationary entries without displacing
the comparison sheets editors revisit. Both queues and their bookkeeping are private to
the worker; the fixed HTTP interface, render-queue concurrency, and 12 GiB disk bound are
unchanged.

## Decisions & Alternatives
| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache replacement policy | 2Q: a probationary queue for first-use sheets and a protected queue for reused sheets, promoting on a second access | LRU; frequency-based eviction with aging | 2Q isolates one-off screening scans in the probationary queue so they cannot evict the small set of comparison sheets editors revisit. The extra queue and split bookkeeping stays inside the worker's private cache and leaves the fixed interface, render-queue concurrency, and 12 GiB disk bound unchanged. LRU lets a long sequential screening displace that reused working set. Aged frequency keeps yesterday's popular clips too long after editors switch projects and adds counter maintenance and aging. |

## Open Questions & Future Decisions
### Deferred
1. The size split between the probationary and protected queues, and the replacement order within each queue, are tuning parameters to set against observed screening/comparison mixes during implementation.
```

**LLD-level edge-case probe** — gaps in this LLD; I have not resolved these:
1. A key evicted from probationary before a second access: on its next miss, does it re-enter probationary, and is any prior access remembered toward promotion?
2. Promoting a reused sheet into a full protected queue: is a protected entry demoted to probationary or evicted, and in what order?
3. Admission when free space is smaller than the incoming sheet: which queue drains first, and is eviction atomic with admission so a failed job leaves no partial state?
4. Bookkeeping under failure/races: a render job failing after a sheet was tentatively counted, or two requests racing to promote the same key — what keeps both queues' membership and byte accounting consistent?
5. What the "size split" denotes — fixed byte budget per queue, entry count, or ratio — and whether it is static or adapts to a production's screening/comparison mix.

I've tentatively parked only the size split and within-queue order (gaps 2/5) under **Deferred**; the rest are unclassified.

**Your call before I continue:**
1. Triage the probe gaps — which to fix in the LLD now, which to defer as open questions?
2. The HLD line removal is an upstream edit — flag if you'd rather I leave the HLD untouched.
3. How should this stop be inspected — you read it directly, or should I hand the LLD to a zero-context reader / delegated inspector for a cold read?

With your approval I'll move to Phase 3 (EARS specs for the 2Q behavior — promotion on reuse, scan-resistant eviction, queue bounds), then the Phase 4 edge audit, each with its own stop. I haven't drafted anything downstream yet, and won't until you approve.