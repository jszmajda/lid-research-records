I picked up Phase 2 where the sketch left off — the 2Q decision is recorded in `previews-design.md`'s new Decisions & Alternatives table, and the HLD's "eviction policy remains open" line is updated to name 2Q. Since the decision's effect is confined entirely to the preview worker's private cache (per your own framing — no sibling node is sized around it), it gets a Decisions-table row rather than a standalone decision doc.

Two things fell out while finishing the LLD that need your call before this is spec-ready:

1. **Queue structure** — minimal two-queue 2Q (FIFO first-use + LRU reused, promote on second access) or the original three-structure form (first-use queue + a ghost list of recently-evicted keys + reused queue, which also resists re-request-right-after-eviction churn)? Your sketch said "two queues," so I defaulted the write-up to that, but flagged the ghost-list variant since it changes what "extra bookkeeping" means.
2. **Size split** — what fraction of the 12 GiB bound goes to the reused queue vs. the first-use queue? No value is set yet.

LLD-level edge probe also turned up gaps worth your triage (fix now vs. defer):
- When eviction pressure hits and the first-use queue is already empty, does it pull from the reused queue too, and LRU-ordered?
- Does a shared pending-job ticket (PREVIEW-003, concurrent misses) count as one access or multiple toward the "second access" promotion trigger?
- If the ghost-list variant is chosen: does a ghost-list hit promote the re-rendered sheet straight into the reused queue, even though the JPEG itself was gone and had to be rebuilt?

How do you want to resolve the two parameters, and which of the probe gaps should I fold into the LLD now versus park as open questions?