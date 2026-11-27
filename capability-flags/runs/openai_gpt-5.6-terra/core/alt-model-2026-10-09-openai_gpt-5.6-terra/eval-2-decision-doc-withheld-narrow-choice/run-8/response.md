**Phase 1: HLD Review**

Updated `docs/high-level-design.md` to state that the preview worker’s private 12 GiB cache uses 2Q eviction.

The HLD remains coherent with the selected direction:

- 2Q stays wholly inside the preview worker.
- The review API contract, render-queue concurrency, cache budget, and pending-response behavior remain unchanged.
- The existing tenet requiring replacement bookkeeping to remain private still governs the design.
- The detailed mechanics and rationale belong in the previews LLD, where the choice will be recorded with the rejected alternatives.

Please approve this HLD update to proceed to Phase 2, the detailed previews design.