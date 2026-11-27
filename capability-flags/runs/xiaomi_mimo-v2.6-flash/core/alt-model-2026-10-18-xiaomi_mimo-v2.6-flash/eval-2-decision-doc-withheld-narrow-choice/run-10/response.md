**Coherence pre-flight** (resuming a new session): specs trace to the current LLD, LLD traces to the HLD, no tests exist yet (all specs are `[ ]` — implementation hasn't started), working tree clean. One HLD statement was stale: it still called the eviction policy open.

**Phase 1 — HLD check**

Choosing 2Q doesn't change the architecture (one preview worker, bounded private cache, fixed HTTP contract), but two lines in `docs/high-level-design.md` were written while the policy was still open:

```diff
- Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open.
+ Owns rendering, pending jobs, and a private 12 GiB cache with a 2Q eviction policy.

- Return a ready preview or a pending response through the same interface for every eviction policy.
+ Return a ready preview or a pending response through the same interface, independent of the cache eviction policy.
```

Both applied. The four tenets, goals, and non-goals otherwise still hold. `review-api` is untouched — its contract is policy-agnostic, matching your note that the preview API and render queue stay unchanged — so no cross-segment cascade.

**Where the choice gets recorded:** a Decisions & Alternatives row in `previews-design.md` — rationale: protects reused comparison sheets from large sequential screening scans; cost accepted as extra queues plus a size split to tune. Not a standalone decision doc: the choice affects only the previews node, however long the argument ran.

**STOP — Phase 1 review.** Please give numbered feedback:

1. Tenet candidate for the HLD: *"Retention favors reused sheets over one-off screenings."* The reverse is defensible (pure LRU welcomes scans), and it would tie-break future cache choices no spec anticipates — split tuning, admission under memory pressure, later policy swaps. Add it under `## Tenets`, or keep the lean only as the LLD Decisions row rationale?
2. Anything else you want changed in the HLD now? If not, I'll proceed to Phase 2: rewriting the Previews "Private Cache" section around 2Q's queues, ghost entries, and the size split — I'll bring the split defaults plus an edge-case probe to that stop.