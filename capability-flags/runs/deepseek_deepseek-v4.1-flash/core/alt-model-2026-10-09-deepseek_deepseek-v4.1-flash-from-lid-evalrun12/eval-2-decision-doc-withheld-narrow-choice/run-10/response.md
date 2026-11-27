**Phase 2 — Previews LLD, settled on 2Q. For your review.**

**Coherence pre-flight.** The HLD's previews entry carried `Its eviction policy remains open.` — stale now that the policy is settled. I removed that clause; the policy is a leaf concern and belongs in the previews LLD. No other HLD text and nothing in the review-api segment references the eviction policy, so no cross-segment cascade was needed. Flagging the HLD edit so you can veto it.

**How the choice is recorded.** I entered 2Q as a row in the previews LLD's Decisions & Alternatives table, with LRU and aged-frequency as the rejected alternatives. Every candidate stays inside the preview cache — the choice affects only this node — so it gets a table row rather than a standalone decision doc; the row carries the rationale a cold reader would need.

I finished `docs/intent/previews/previews-design.md`. Context, Architecture, and Rendering & Deduplication are unchanged. The changed and added sections:

```
## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

### 2Q Eviction

The cache uses the 2Q policy: a probationary queue holds sheets that have been referenced once, and a protected queue holds sheets that have been referenced more than once. A size split reserves a tunable share of the 12 GiB budget for each queue.

- When a completed sheet is admitted, it enters the probationary queue.
- When a sheet in the probationary queue is requested again, it moves to the protected queue.
- When a sheet in the protected queue is requested again, it stays in place.
- When a queue exceeds its share, the worker evicts that queue's least-recently-used sheet.

A long sequential screening streams one-use sheets through the probationary queue, so it does not displace the repeatedly compared sheets in the protected queue. All queue metadata and the size split stay private to the preview worker; the external interface, render-queue concurrency, and the 12 GiB budget are unchanged.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q, with a probationary queue, a protected queue, and a tunable size split | LRU; frequency-based eviction with aging | 2Q gives each admitted sheet a probationary pass before it can occupy the protected queue, so a long sequential screening cycles one-use sheets through the probationary queue instead of evicting the repeatedly compared working set. LRU tracks recent work with little bookkeeping but lets a screening scan displace comparison sheets. Aged frequency counts retain repeatedly popular clips but need per-sheet counters and aging maintenance and lag when an editor switches projects. 2Q's extra bookkeeping stays private to the worker and does not alter the external interface, queue concurrency, or disk budget. |

## Open Questions & Future Decisions

### Deferred

1. The size split between the probationary and protected queues is not fixed; tune it against observed screening and comparison workloads during implementation.
```

**Phase 2 edge-case probe** (delegated to a no-context reviewer, since you chose no inspector). It surfaced gaps in this LLD. Grouped:

*Introduced or exposed by the 2Q section:*
1. When the protected queue overflows, is its LRU sheet **discarded**, or **demoted back** to the probationary queue (canonical 2Q demotion)? Only "evicts" is stated.
2. Is the size split a **hard per-queue cap**, or can an under-full queue lend headroom to an overflowing one?
3. Promotion into an already-full protected queue: does the move evict first, and what if the promoted sheet is itself the protected LRU? (race)
4. What counts as a **reference** — does the render request that creates the sheet count as its first reference (so it should enter protected), or do only later requests count?
5. A sheet larger than its queue share, or the whole 12 GiB: eviction can never make it fit; behavior unspecified.
6. Can a sheet be evicted **while a 200 read is serving it** (need a pin), or can a client get a truncated/absent body?
7. Admission arithmetic: does "within that bound" account for the incoming sheet's size, or only current occupancy?
8. A request arriving **after render completes but before cache admission**: duplicate job ticket, or block?

*Pre-existing (not introduced by this change):*
9. A failed job's terminal response to a client holding its ticket (currently only "removed from the dedup map").
10. Queue saturation and ticket TTL/body shape — the 202 job ticket is referenced but never specified.
11. Cache key includes renderer version, but the URL carries none; how a request selects a version.
12. Crash recovery of temp render output and dedup-map entries.

**Question:** which of these should I fold into the LLD as design now, and which do you want recorded as deferred open questions? My recommendation: resolve 1–4 and 7 now (they are load-bearing for the 2Q behavior you selected), and defer 5, 6, 8, and the pre-existing 9–12. Tell me your triage, or say "your recommendation" to accept it.

**Approval:** Do you approve this LLD as the Phase 2 output? On your approval I'll proceed to Phase 3 (EARS) — `PREVIEW-004` currently states the 12 GiB bound generically; I'd adjust/extend specs to cover the probationary/protected promotion and per-queue eviction. If you want me to stop here instead, say so.