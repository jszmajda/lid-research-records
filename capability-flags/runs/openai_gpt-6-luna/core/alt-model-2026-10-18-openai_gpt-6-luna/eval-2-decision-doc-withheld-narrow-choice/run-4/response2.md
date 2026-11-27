**Phase 2 — Previews design draft:** I agree this merits a decision doc. The options have meaningful trade-offs a future maintainer could revisit, and the selection shapes the cache design. I recorded the choice as 2Q, with the queue-size split left for pilot tuning.

### HLD update

The Previews architecture entry now describes the private 12 GiB cache as using 2Q eviction.

### `docs/intent/previews/previews-design.md`

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

Use a 2Q replacement policy with two resident queues: a probationary FIFO queue for newly admitted sheets and a protected LRU queue for sheets requested again after admission. A hit in the probationary queue promotes the sheet to the protected queue; a hit in the protected queue refreshes its recency. The policy uses a configurable size split between the queues. Eviction removes the oldest probationary sheet before evicting the least-recently-used protected sheet, preserving reused comparison sheets against one-use screening scans. The queue split requires workload tuning.

Replacement bookkeeping and queue configuration remain private to the preview worker. The policy does not change the HTTP contract, render queue concurrency, or total 12 GiB JPEG budget.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache replacement policy | 2Q with a probationary FIFO queue and a protected LRU queue; see [the cache eviction decision](decisions/cache-eviction-policy.md) | LRU; frequency-based eviction with aging | Protecting reused comparison sheets from long one-use screening scans is more important than minimizing bookkeeping or adapting immediately to a workload switch. |

## Open Questions & Future Decisions

### Deferred

1. Tune the byte-capacity split between the probationary and protected queues against pilot screening and comparison workloads.
```

### `docs/intent/previews/decisions/cache-eviction-policy.md`

```markdown
---
node: previews
---

# Decision: Preview Cache Eviction Policy

## Context

The preview worker serves two recurring access patterns: long sequential screenings that introduce many one-use contact sheets, and comparison sessions that repeatedly revisit a smaller set. Cached JPEG data is bounded to 12 GiB. The replacement policy affects only private worker bookkeeping; the HTTP contract and render queue do not depend on the policy.

## Decision Elements

- **Major — retain reused sheets during sequential screening:** repeated comparison sheets should remain available when a long scan introduces many one-use sheets.
- **Moderate — adapt to changed workloads:** cached state should respond reasonably when editors switch projects or review sets.
- **Moderate — limit replacement bookkeeping:** policy state and updates should remain inexpensive for the single preview worker.
- **Moderate — avoid tuning burden:** the policy should not require extensive workload-specific configuration.

## Options in the Domain

### LRU

Least-recently-used eviction keeps entries ordered by their latest access and evicts the oldest. It adapts quickly when editors switch projects, but a long sequential screening can push repeatedly useful comparison sheets out of the cache.

- **Retain reused sheets during sequential screening — weak:** one-use scan entries become more recent than comparison sheets and can evict them.
- **Adapt to changed workloads — strong:** recent requests directly determine replacement order.
- **Limit replacement bookkeeping — strong:** the worker maintains recency order without frequency counts or multiple queues.
- **Avoid tuning burden — strong:** no queue split or aging interval is required.

### Frequency-based eviction with aging

Frequency-based eviction tracks how often each sheet is requested and periodically ages those counts so older popularity has less influence. It can retain repeatedly popular sheets, but adds counter and aging work and may retain yesterday's favorites after a project switch.

- **Retain reused sheets during sequential screening — strong:** repeated requests build an advantage over one-use scan entries.
- **Adapt to changed workloads — weak:** older frequency counts can continue to influence eviction after the working set changes.
- **Limit replacement bookkeeping — weak:** request counts and aging state require additional maintenance.
- **Avoid tuning burden — partial:** aging behavior requires a policy choice, though it has no queue-size split.

### 2Q

2Q places new sheets in a probationary FIFO queue and promotes a sheet to a protected LRU queue when it is requested again. The probationary queue absorbs first-use scan entries; the protected queue retains entries that have demonstrated reuse. A configurable size split determines the byte capacity assigned to each queue.

- **Retain reused sheets during sequential screening — strong:** one-use entries remain probationary while repeated comparison sheets are protected.
- **Adapt to changed workloads — partial:** new entries enter probationary state immediately, while previously protected entries remain until displaced from the protected queue.
- **Limit replacement bookkeeping — weak:** two queues and promotion tracking are required.
- **Avoid tuning burden — weak:** the split between queue capacities needs tuning against production workloads.

## Selection

Choose 2Q. Its protection of reused comparison sheets during long sequential screenings addresses the highest-importance criterion. The additional queue bookkeeping and the need to tune the queue-size split are accepted costs. LRU's faster response to workload changes and simpler state do not outweigh scan resistance; frequency aging also protects reused sheets but adds counter maintenance and can preserve stale popularity. The byte split remains a pilot-tuning question. This decision is local to the previews segment and keeps replacement state private to the preview worker.
```

### LLD-level edge-case probe

The draft still leaves these mechanics to pin down or explicitly defer:

1. **Queue capacity behavior:** Are the two queue sizes hard byte partitions, or can one queue borrow unused capacity from the other?
2. **Promotion into a full protected queue:** The draft implies evicting its least-recently-used entry. Should that entry be discarded, or demoted to probationary?
3. **A sheet larger than the probationary allocation:** Can it use capacity beyond that allocation, or should it be rejected from cache?
4. **Concurrent queue updates:** How should simultaneous hits, promotions, and admissions be serialized so an entry cannot be promoted or evicted inconsistently?

The existing EARS specs do not yet specify the 2Q behavior; that cascade belongs in Phase 3 after this design review. `git diff --check` passes.

Please review the draft and say which probe items you want resolved in the LLD now versus deferred. In particular, should the queue split be a hard partition or allow borrowing?