2Q is settled — I didn't re-open it, and I didn't create or offer a decision doc. The choice is private to the previews segment (no other node is sized around it), so it goes in a Decisions row; a long debate is a symptom, not the test for a full doc.

**Coherence pre-flight (new session):** HLD, previews LLD, and PREVIEW-001–005 are mutually coherent — all three said the policy was open, so no existing drift to repair. All five PREVIEW specs are `[ ]` active gaps; the repo has no source or tests.

**Phase 1 — HLD check:** architecture unchanged. I removed two stale "policy open" clauses so the docs read as current intent:
- Architecture bullet: dropped "Its eviction policy remains open."
- Goal: "…through the same interface for every eviction policy." → "…through the same interface."
Cascade check: the review-api segment (`REVIEW` prefix) is a different leaf and needs no change — the policy stays private to the preview worker per the HLD tenets.

**Phase 2 — LLD, full draft for review:**

```
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set. The cache keeps that working set warm through a screening scan so editors do not re-render the comparison sheets they return to.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

Replacement uses 2Q. A newly admitted sheet enters a first-use probationary queue; a request served from that queue promotes the sheet into a reused protected queue. Eviction draws from the first-use queue before the reused queue, so a long sequential screening of one-use sheets does not displace sheets that comparison sessions revisit. The 12 GiB budget is split between the two queues; the split is a tuning parameter. Replacement bookkeeping is private to the worker and does not change the external interface, the FIFO render queue, or the disk budget.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache replacement policy | 2Q — a first-use probationary queue feeding a reused protected queue, with a size split between them | LRU; frequency-based eviction with aging | 2Q preserves the reused comparison working set through long sequential screenings, the workload the pilot must serve. LRU lets a sequential scan evict those reused sheets. Aged frequency adds counter maintenance and can retain clips popular in a previous project after editors switch projects. The extra queues and the size-split parameter are the accepted cost. Replacement stays inside the preview worker and leaves the external interface, render-queue concurrency, and the 12 GiB budget unchanged. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Cache replacement policy: 2Q. See Decisions & Alternatives.

### Deferred
1. The split of the 12 GiB budget between the first-use and reused queues is a tuning parameter to set during implementation.
```

The "still open / candidates" prose is gone; the rejected alternatives and why now sit in the Decisions table, and the doc reads cold without the thread.

**LLD-level edge-case probe (delegated, summarized):** the size split is already recorded as Deferred. The remaining gaps are yours to triage — fix in the LLD now vs. defer as open questions:
1. Which entry is the victim inside each queue (no intra-queue FIFO/LRU discipline stated)?
2. What exactly triggers promotion — does the first 200-serve from the first-use queue itself promote, or must a further distinct request occur, and does a 202/temp serve count as a hit?
3. On a miss completing, is the sheet always admitted to the first-use queue, and is the waiter served from cache after admission or from temp before it?
4. At the 12 GiB bound, what is the eviction order across the two queues, does it fall through to the protected queue when first-use is empty, and what happens if an incoming sheet cannot fit at all?
5. Is an entry evicted from the protected queue discarded or demoted, and does a re-request recover its reuse status?
6. Does "at most 12 GiB" cover in-flight temp render output too, or admitted bytes only?
7. How do old-renderer-version entries in both queues behave once a new version is active?
8. Is admission/eviction atomic when four renders complete together, and how does a hit/promotion race with eviction of that same entry?

**STOP — Phase 2 review gate.** I have not started Phase 3 (EARS), the Phase 4 intent-narrowing audit, tests, or code. The stops still apply even though you're ready to be done, so I'll cascade on your word. Before I proceed, I need:

1. Approval or numbered feedback on the LLD draft and the two HLD coherence edits.
2. Your triage of the eight probe gaps.
3. A ruling on a fork I won't settle for you: the PREVIEW specs are deliberately policy-agnostic — should 2Q's scan-resistance be pinned as a new EARS spec (and later a test), or stay private bookkeeping with only PREVIEW-004 covering the 12 GiB bound?
4. Scope: this segment has no code or test harness — should I walk EARS (Phase 3) + the edge audit (Phase 4) only, or also scaffold tests/code (Phases 5–6)?

You can review this yourself, or I can dispatch a zero-context or delegated inspector for the cascade — your call.