**Phase 2 Complete — Updated LLD**

I've updated the previews LLD to finalize the 2Q eviction decision:

**Added sections:**

1. **2Q Eviction Policy** (lines 26-32) — specifies the two-queue mechanism:
   - A1 (admission queue): 25% of budget, FIFO, holds first-access entries
   - Am (main queue): 75% of budget, LRU, holds proven-reusable entries
   - Promotion: A1 entries accessed twice move to Am
   - Eviction order: A1 first (FIFO), then Am (LRU)

2. **Decisions & Alternatives table** (lines 34-38) — records the eviction policy choice with rationale against LRU and frequency-based alternatives

The updated design reads context-free. The 25/75 queue split is specified but noted as tunable. All replacement metadata stays private to the preview worker.

**Ready for your review.** Does this capture the 2Q design you want?