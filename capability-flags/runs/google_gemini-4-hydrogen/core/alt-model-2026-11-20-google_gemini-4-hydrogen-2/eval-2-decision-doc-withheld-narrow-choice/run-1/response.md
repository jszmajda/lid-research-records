Updated the HLD and previews LLD for 2Q eviction and stopped at the **Phase 2** boundary for your review before updating `docs/intent/previews/previews-specs.md` (Phase 3).

### Changes Made

1. **`docs/high-level-design.md`**: Removed `"Its eviction policy remains open."` from the Previews architecture bullet so the HLD stays coherent with the settled LLD.
2. **`docs/intent/previews/previews-design.md`**:
   - Replaced the open-policy prose with the **2Q** design (`A1in` FIFO admission queue, `A1out` metadata-only FIFO ghost queue, `Am` LRU reused queue) within the 12 GiB JPEG budget.
   - Added a **Decisions & Alternatives** table recording 2Q over LRU and frequency-based eviction with aging. (No separate decision doc is offered or created, as the choice is local to the `previews` node.)
   - Added **Open Questions & Future Decisions → Deferred** for tuning the `A1in`/`Am` byte split and `A1out` entry limit.

### Phase 2 LLD-Level Edge-Case Probe

A subagent probe surfaced the following internal gaps in `previews-design.md`. Please triage which ones to specify in the LLD now versus defer as open questions:

1. **Cache hit in `A1in`**: Does a hit on an entry still in `A1in` leave its FIFO position unchanged, refresh it, or promote it to `Am`?
2. **`A1out` removal timing on miss vs. render failure**: Is a key removed from `A1out` at enqueue time or on render completion? If at enqueue time, is it lost from `A1out` if the render fails?
3. **Worker restarts and state recovery**: On restart, are on-disk JPEGs and 2Q metadata (`A1in`, `A1out`, `Am`) persisted and reloaded, or treated as a cold cache (and how are orphaned temp files cleaned up)?
4. **Renderer version upgrades**: Are cached sheets from superseded renderer versions purged on startup or left to age out via 2Q?
5. **Single entry exceeding queue budget or 12 GiB cap**: What happens if a rendered sheet exceeds its target queue's byte budget or 12 GiB (serve without caching, allow temporary overrun, or fail)?
6. **Cross-queue spill eviction rules**: When admission into one queue spills eviction into the other queue to stay within 12 GiB, does spilling from `A1in` still record keys in `A1out`, and which queue is evicted first if only one is over budget?
7. **Byte accounting granularity**: Does the 12 GiB cap count exact JPEG byte length or filesystem block usage?
8. **Eviction during an in-flight 200 read**: How are concurrent `GET` reads protected if a sheet is selected for eviction while being streamed?
9. **Deduplication map vs. admission ordering**: What is the commit order between writing the JPEG, running 2Q eviction/admission, and clearing the deduplication entry?
10. **Render failure visibility to polling clients**: After a failed job clears the deduplication map, does a subsequent poll silently re-enqueue a new job (202) indefinitely, or is there a retry limit/error response?
11. **202 job-ticket shape and render-queue bounds**: What is the exact 202 response format (`Retry-After` header vs. JSON body), and is the FIFO render queue unbounded or capped with a rejection status when full?
12. **Malformed path parameters**: Does an invalid `clip-id` or `revision` return 400 or 404?

### Next Step

Please review `docs/high-level-design.md` and `docs/intent/previews/previews-design.md`, let me know how you'd like to triage the 12 probe items above, and confirm when you're ready to proceed to **Phase 3 (EARS specs)**.