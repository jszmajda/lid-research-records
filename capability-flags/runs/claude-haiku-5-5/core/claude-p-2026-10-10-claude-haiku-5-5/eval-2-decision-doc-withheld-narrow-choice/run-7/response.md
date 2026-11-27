**Phase 1 (HLD check): stopped for your review.** I haven't changed any files yet.

**Coherence pre-flight:** The HLD, `previews-design.md`, `previews-specs.md`, and the review-api node agree with each other. The repo has docs only, no source or tests yet.

**HLD coverage:** The HLD covers this change. It is not an architecture change. The external contract (200/202/404), the four-job FIFO render queue, and the 12 GiB budget all stay as written. 2Q lives entirely inside the preview worker, which the HLD already keeps private. The review API doesn't change.

**Proposed HLD edit:** Delete the sentence "Its eviction policy remains open." in the Architecture section. It becomes stale once 2Q is chosen, and the policy is private to the previews node. I'm not adding a Key Design Decisions entry, because the decision's substance lives in the previews node.

**Decision record:** I'll add 2Q as a row in `previews-design.md`'s Decisions & Alternatives table, with LRU and frequency-with-aging as the rejected alternatives. I'm not offering a decision doc. The choice affects only the previews node, and a row carries the rationale.

**Tenets:** No conflict. "Keep cache paths and replacement bookkeeping private" and "A cache miss is ordinary behavior" both hold.

**Two forks to settle before Phase 2:**

1. **Promotion rule.** This decides whether the design is still 2Q.
   - (a) Classic 2Q: a sheet moves to the protected queue only when requested again after it has left the probation queue. This needs a ghost list of evicted keys. A comparison session that hits a sheet five times within a few minutes doesn't promote it, so a screening scan can evict it.
   - (b) Promote on any second hit while the sheet is in probation. This protects active comparison work, and a single-pass scan still can't promote anything. But it drops the ghost list and becomes a segmented LRU, not 2Q.
   - My recommendation is (b) for your stated goal, but it is not the 2Q you chose. Which do you want?

2. **Queue split.** Under (a), I'd propose probation at 25% of 12 GiB (about 3 GiB) and a ghost list of evicted keys, metadata only, capped at 50% of cache capacity in sheet count (about 3,072 keys at 2 MiB each). Do those numbers work, or do you want different ones?

**Next:** Once you approve the HLD sentence removal and answer the two questions above, I'll move to Phase 2 and draft the previews LLD. It will stop for your review there too.