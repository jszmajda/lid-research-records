## Phase 1: HLD check

The HLD covers this change. The Previews node owns the private cache, and its eviction policy is the open item. Choosing 2Q does not alter the architecture. The `GET /internal/previews/{clip-id}/{revision}` contract, the FIFO render queue of four jobs, and the 12 GiB bound all stay the same, and 2Q lives entirely inside the preview worker.

**One HLD sentence goes stale.** `high-level-design.md` says the Previews node's "eviction policy remains open." Proposed replacement:

> Owns rendering, pending jobs, and a private 12 GiB cache; its eviction policy is internal to the node.

This keeps the mechanism out of the HLD and matches the existing rule that no other node reads cache state.

**Tenets and goals.** I found no conflict. 2Q's queues and bookkeeping stay private, as the tenet "Keep cache paths and replacement bookkeeping private to the preview worker" requires. The goal of 24 editors on one eight-core worker is not measured, but 2Q's extra work is constant-time per access.

**Recording the decision.** The choice affects only the Previews node, so I won't offer a decision doc. It becomes one row in `previews-design.md`'s Decisions & Alternatives table. The row names LRU and frequency-with-aging as the alternatives and gives the rationale: scan resistance keeps comparison sheets resident during long screenings, at the cost of two queues and a split to tune.

**Carried to Phase 2 (not decided here):**
- The 2Q split parameters, meaning the first-use queue size and the ghost-list size. We need either fixed starting values or a rule, since you said the split will need tuning.
- Ghost entries would hold keys only, not JPEG bytes, so they sit outside the 12 GiB bound. Please confirm that's acceptable.
- The "Private Cache" section of `previews-design.md` still narrates the three-way debate. It will be rewritten to describe the chosen design only.

No files have been changed yet. Phases 2 and 3 each need your sign-off before I continue, so the answers to these are needed first:

1. Do you approve the HLD wording above?
2. Do you approve the Phase 1 decision row, and should I proceed to the Phase 2 LLD draft?