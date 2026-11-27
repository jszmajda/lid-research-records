Finished the preview design (Phase 2). Stop for your review before I draft EARS specs.

**Coherence pre-flight**
- Specs → LLD: `PREVIEW-001`–`005` still trace cleanly; the 2Q mechanism adds behavior that has no spec yet — that's Phase 3 work, not a drift.
- LLD → HLD: consistent. One stale line fixed: the HLD architecture bullet still said "Its eviction policy remains open." Since the policy is a previews-node decision, I dropped that clause; the HLD keeps the relevant tenet ("Keep cache paths and replacement bookkeeping private to the preview worker"). Flagging the adjacent-node edit for you.
- Tests/code → specs: none exist in this repo, so nothing to trace.

**`docs/intent/previews/previews-design.md` (revised in full)**

---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so no single recency rule fits every observed workload.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

### Eviction: 2Q

The cache separates sheets seen once from sheets seen more than once, so a long sequential screening evicts its own one-use sheets instead of the comparison working set.

- **First-use queue.** A sheet enters here when it is admitted after a render. This queue is FIFO: it holds sheets requested exactly once since admission, in admission order.
- **Reuse queue.** A sheet that is requested a second time is promoted from the first-use queue to the reuse queue. The reuse queue is LRU: a hit refreshes the sheet's position, and its least-recently-used sheet is the preferred victim once the first-use queue is within its share.
- **Ghost list.** Keys recently evicted from the first-use queue are remembered for a short window. A request that misses the cache but matches a ghost entry is admitted directly to the reuse queue, so a working-set sheet a scan pushed out is restored to the protected queue rather than re-entering as first-use.
- **Size split.** The first-use queue is capped at a tunable share of the cache budget; the reuse queue may use the remainder. While the first-use queue exceeds its share, eviction takes its oldest entry; otherwise eviction takes the least-recently-used entry of the reuse queue.

A hit in the reuse queue, and a ghost-list promotion, leave the reuse queue holding sheets requested at least twice — the mechanism that keeps a repeatedly compared working set resident through a screening burst. The split share is the one tuning knob and is fixed per deployment.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache eviction policy | 2Q — a first-use FIFO and a reuse LRU separated by a tunable size split | LRU; frequency-based eviction with aging | 2Q keeps a long screening from evicting the comparison working set: one-use sheets turn over in the first-use queue while reused sheets stay in the reuse queue. LRU adapts fastest but a sequential scan evicts sheets still needed for comparison. Aged frequency counts retain repeatedly popular clips but add counter maintenance and age out slowly after a project switch. All three leave the external interface, render-queue concurrency, and disk budget unchanged; only the worker's private replacement bookkeeping differs. |

## Open Questions & Future Decisions

### Deferred

1. The size-split share between the first-use and reuse queues — tune against pilot screening-versus-comparison workloads.

---

The alternatives you weighed in the thread are recorded as the Decisions row's Alternatives column rather than body prose, so the design reads as current intent.

**Edge-case probe (blind reader, LLD-internal gaps).** These are gaps in the LLD, not cross-spec issues (Phase 4). Triage each as *fix now* or *defer*:

1. Does a 202 pending ticket count as a "request" for promotion, or only a served 200? Polling could spuriously promote a sheet.
2. On ghost-list re-request, is the sheet's hit count continued, reset, or forced to two?
3. First-use within share, reuse queue empty, and admission still exceeds 12 GiB — no victim is named.
4. Is the size split a continuous invariant (steady-state eviction below budget) or only admission-time pressure relief?
5. A single sheet larger than the whole budget — no termination/refusal rule.
6. Are reuse-queue victims ghosted too, or only first-use victims?
7. Ghost promotion — at request time (while the render is pending) or at admission time? Which queue does the pending job resolve into?
8. Is the ghost list bounded (size/TTL), and is an entry consumed on promotion?
9. Where does a promotion insert into the reuse queue (MRU?), and does the promoting hit refresh position?
10. Eviction with no existing sheets / empty candidate queues — behavior?
11. Known revision but unknown renderer version — response shape? The contract only names "unknown revision."
12. Job-ticket lifetime across retries; when is an outstanding ticket invalidated on failure?
13. First-use-queue hit: is promotion synchronous with that request?
14. Temporary render output across four concurrent jobs — bounded?

**Next rung:** Phase 3, EARS specs for the 2Q behavior (likely a promotion/protection spec plus scope clarifications to `PREVIEW-004`, and probably specs answering gaps 1, 6, 7, 9). 

Please confirm: (a) the 2Q LLD and the HLD tweak, (b) which probe gaps to fix in the LLD vs. defer, and (c) whether to proceed to Phase 3.