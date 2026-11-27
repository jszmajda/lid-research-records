Recorded **2Q** in `docs/intent/previews/previews-design.md`, with scan resistance as the reason to accept extra bookkeeping. This choice is confined to the preview cache; a Decisions & Alternatives row captures it adequately.

The preview specs remain consistent with the existing API and cache limit. The HLD still says the eviction policy is open—that stale statement needs reconciliation when you approve the design.

## Preview design draft

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

Use 2Q replacement tracking to separate first-use sheets from reused sheets. First-use sheets occupy a probationary FIFO queue; reused sheets occupy a recency-ordered queue. This separation limits the displacement of comparison sheets by one-off sequential screenings. Both queues share the 12 GiB JPEG-data budget, and the worker owns their membership, ordering, and accounting.

The policy's promotion rule and queue-size split need to be specified together: they determine which requests count as reuse and how much capacity a screening can consume. Replacement tracking operates on the same immutable preview key used for rendering and deduplication.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache replacement policy | 2Q | LRU; frequency-based eviction with aging | Protect repeatedly reused comparison sheets from one-off screening scans, accepting extra queue bookkeeping and size tuning. LRU is cheaper and adapts quickly but allows scans to displace the comparison working set; aged frequency counts add maintenance and can retain yesterday's favorites too long. |

## Open Questions & Future Decisions

- Choose the 2Q promotion rule: promote on a second resident request, or use a bounded history of evicted first-use keys and promote when a key is requested again from that history.
- Choose the initial first-use allocation and, if eviction history is used, its size bound. Account for JPEG capacity in bytes because sheet sizes can vary.
- Define victim selection when either queue is empty or sheets have unequal sizes.
- Define admission and delivery for a single completed sheet larger than the entire JPEG cache budget.
- Define recovery of resident queue membership and reuse history after a worker restart.

## References

- [FrameDesk high-level design](../../high-level-design.md)
- [Preview specifications](previews-specs.md)
```

## Design-probe findings

The probe identified these additional gaps for your **fix now / defer** triage:

1. **Reuse accounting:** Do pending polls or coalesced requests count as reuse? What refreshes recency?
2. **Concurrent admission:** How do simultaneous render completions and eviction during delivery preserve consistent accounting?
3. **Ordering:** Does probationary FIFO order follow request time or completed admission?
4. **Failed tickets:** What does a caller receive after its render fails?
5. **Resource exhaustion:** What happens when the pending queue grows indefinitely or a renderer hangs?

**First, which promotion rule do you want?**

- **Resident-hit promotion:** A second request while the sheet is cached promotes it. Simpler, but rapid screening polls can qualify sheets for protection.
- **History-based 2Q:** Keep a bounded, key-only history of evicted first-use sheets; a later request promotes the re-rendered sheet. Adds bookkeeping and a history-size setting, but distinguishes returns after eviction from immediate repeats.

I recommend **history-based 2Q** for the screening/comparison workload. Do you approve that direction, and which numbered gaps should be resolved now versus deferred?