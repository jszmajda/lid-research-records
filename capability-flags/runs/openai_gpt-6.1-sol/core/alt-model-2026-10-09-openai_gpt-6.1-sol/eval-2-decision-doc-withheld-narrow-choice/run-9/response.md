Recorded **2Q** in `docs/intent/previews/previews-design.md`, with a Decisions & Alternatives row explaining why protecting comparison sheets justifies the extra bookkeeping. Also removed the stale “eviction policy remains open” wording from the HLD.

A table row captures this worker-local decision adequately.

## Preview design for review

- First-use sheets enter a **probationary FIFO queue**.
- Sheets with demonstrated reuse occupy a **protected LRU queue**. Protected hits refresh recency.
- Sequential screenings churn probationary entries, favoring retention of reused comparison sheets.
- Both resident queues share the **12 GiB JPEG budget**, accounted in bytes because sheet sizes vary.
- Protected entries remain evictable; the policy does not guarantee that a particular sheet stays cached.
- Queue membership, ordering, and any evicted-key history belong to the preview worker and use the complete preview key.
- Admission and eviction update resident-byte accounting and replacement metadata together. Replacement tracking applies to completed sheets; rendering and shared job tickets retain their existing lifecycle.

## Choices needed to finish the LLD

1. **What counts as reuse?** Promote on a second request while a sheet is still probationary, or use full 2Q with bounded history of evicted probationary keys and promote when one is requested again? The former recognizes immediate comparisons; the latter distinguishes reuse across eviction from screening-time request bursts.
2. **Queue allocation:** What probationary share should we start with, and may either queue borrow unused capacity? A smaller probationary share favors comparisons but leaves newly screened sheets less time to demonstrate reuse.
3. **Oversized sheets:** How should a JPEG larger than the entire cache budget be delivered without admission?
4. **Restart behavior:** Restore resident sheets and replacement state, or clear the cache and restart tracking?

The LLD edge-case probe also found gaps in **ticket behavior after failure or eviction, concurrent admission/eviction ordering, admission failure, waiting-queue limits, and renderer-version changes during a job**.

Please give numbered feedback on the four choices and identify which probe gaps to resolve now versus defer. Do you approve the rest of the 2Q design? I’ll pause here for LLD review before drafting its EARS requirements.