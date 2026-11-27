**2Q is recorded as the selected policy** in `docs/intent/previews/previews-design.md`, with comparison-sheet retention as the rationale. I also removed the stale “eviction policy remains open” statement from the HLD. `git diff --check` passes.

The decision fits a Decisions & Alternatives row: its substance stays inside the preview cache, and the rationale can be explained there.

<details>
<summary>Preview design for review</summary>

```yaml
parent: high-level-design
prefix: PREVIEW
```

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

### 2Q Replacement

Use 2Q to separate first-use sheets from sheets with demonstrated reuse. A FIFO probationary queue absorbs one-off screening traffic; an LRU protected queue retains reused comparison sheets. Cache hits in the protected queue refresh their recency. Newly rendered keys without retained reuse history enter the probationary queue. Both resident queues share the 12 GiB JPEG budget, accounted in bytes rather than sheet counts.

The policy prioritizes comparison-sheet retention over minimal bookkeeping. Protection is relative: a comparison working set larger than the protected capacity still causes evictions. Queue membership and replacement updates are serialized with cache admission and lookup so a resident key belongs to exactly one queue and concurrent completions cannot exceed the disk budget.

The reuse trigger, queue split, and capacity edge cases below require resolution before the replacement transitions can be fully specified.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Private cache replacement | 2Q | LRU; frequency-based eviction with aging | Retaining reused comparison sheets during long sequential screenings outweighs the cost of maintaining separate queues and tuning their size split. LRU adapts quickly with little bookkeeping but lets scans displace comparisons; aged frequency counts retain popular clips but require counter maintenance and can retain an old project's favorites too long. |

## Open Questions & Future Decisions

1. **Reuse detection:** simplified two-resident-queue 2Q promotes a sheet on a later resident hit; full 2Q also keeps a bounded FIFO history of keys evicted from probation, admitting a re-requested historical key into the protected queue after rendering. The former has less bookkeeping; the latter recognizes reuse even after the initial sheet is evicted. History contains keys only, not JPEG data. Select the variant and define whether polling requests for a newly completed job count as reuse.
2. **Queue sizing and replacement:** select the initial probationary/protected byte split and whether unused protected space is available to probationary sheets. Define victim selection when an incoming sheet crosses the probationary target and what happens when a probationary sheet is promoted into a full protected queue. Full 2Q also needs a bound for its key-only history.
3. **Capacity and lifecycle:** define delivery of a rendered sheet larger than the entire cache budget, handling of an individual sheet larger than its queue target, and whether replacement history survives worker restart. These cases must preserve the ready/pending contract and the 12 GiB JPEG bound.

## References

- [FrameDesk high-level design](docs/high-level-design.md)
- [Preview specifications](docs/intent/previews/previews-specs.md)

</details>

### Design gaps to triage

The edge-case probe confirmed the open questions above and found these additional gaps:

4. What response does a client receive when a render fails?
5. What happens if a completed sheet is evicted before its pending client retrieves it, or while delivery is starting?
6. What happens to pending tickets and temporary files after restart, or to new requests when the render queue is saturated?

**The next choice is within 2Q:** should reuse mean a second hit while the sheet is still resident, or should the worker also remember recently evicted keys? I recommend the latter for comparisons revisited after a long screening; it costs additional bounded, key-only history.

Which variant do you want, and which numbered gaps should we resolve in this design versus explicitly defer? I’m at the LLD review stop before updating EARS.