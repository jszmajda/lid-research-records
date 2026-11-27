I'll run an LLD-level edge-case probe to identify any gaps in the cache eviction design.

**LLD-level edge-case probe for 2Q cache eviction:**

1. **What happens when a clip is accessed while it's being evicted?** The LLD doesn't specify whether an in-progress eviction can be interrupted, or if access during eviction should block, fail, or promote the entry.

2. **What happens when the 25/75 queue split needs rebalancing?** If many entries promote from A1 to Am, Am could exceed its 75% target before the next admission triggers eviction. The LLD doesn't specify whether queue limits are hard (block promotion) or soft (allow temporary overage).

3. **What happens when a completed render is smaller or larger than expected?** The eviction decision is made before knowing the final JPEG size. If actual size differs from the estimate used for eviction, the cache could exceed 12 GiB or unnecessarily evict entries.

4. **What happens when entries in A1 are accessed multiple times before promotion?** The LLD says "accessed a second time" triggers promotion, but doesn't specify whether subsequent accesses while still in A1 reset position, update metadata, or have no effect.

5. **What happens during cache recovery after a worker restart?** The LLD doesn't specify whether queue membership and access counts persist across restarts, rebuild from filesystem scan, or start cold.

**STOP — Phase 2 (LLD) Review**

Updated `docs/intent/previews/previews-design.md` with the 2Q cache eviction decision. The design documents the two-queue structure (25% A1 admission queue, 75% Am main LRU), promotion on second access, and the rationale for protecting comparison sheets during sequential screening scans.

The edge-case probe above identifies five gaps. Please review the updated LLD and triage which gaps should be addressed now versus deferred.