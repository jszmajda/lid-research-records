Now I'll run the Phase 2 LLD-level edge-case probe to identify any gaps in the design before proceeding to EARS validation:

**LLD-Level Edge-Case Probe for 2Q Design**

The following gaps were identified in the preview worker's 2Q implementation. Please triage which gaps to address in the LLD now vs. defer as open questions:

1. **Cold-to-hot promotion atomicity**: Is the transition from cold queue to hot queue atomic, or could a concurrent request see an entry mid-transition? The design should clarify whether an entry briefly appears in both queues.

2. **Evicted entry re-request**: If a cold entry is evicted before being accessed a second time, and then re-requested later, does it re-enter the cold queue as a new entry, or should there be some tracking to recognize it as previously cached?

3. **Empty cold queue admission**: When the cold queue is empty but the hot queue has space, can a new first-time entry go directly to hot, or must it always start cold even if that forces hot eviction?

4. **Render version mismatches**: If an entry is cached for clip X at renderer v1, and then the renderer upgrades to v2, the cache key changes (revision + version). Does the old v1 entry remain in place (normal FIFO eviction applies), or is there an invalidation rule?

5. **Deduplication during eviction**: If entry E has an in-flight render job and becomes subject to eviction while rendering, should the system delay eviction until the job completes, or evict the cached entry and leave the job's dedup entry intact?

6. **Cold queue overflow under sustained screening**: If a long screening fills the cold queue faster than FIFO eviction can make space, does the system error, block new admissions, or aggressively borrow from hot?

7. **Tuning parameter change at runtime**: The 80/20 split is tuned based on pilot data. How does changing the split (e.g., 70/30) affect existing queue assignments — do in-place entries get re-classified, or does the split apply only to new admissions?

Which of these should be addressed now (update the LLD) vs. deferred to implementation?