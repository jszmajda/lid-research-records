**Phase 2 complete. LLD updated with 2Q decision and Decisions & Alternatives table. Now running the LLD-level edge-case probe:**

**Edge-case probe for 2Q eviction:**
1. **Am promotion when A1 is full** — When an Am entry is accessed and must promote to A1, but A1 is at capacity, does A1 evict its own tail first to make room, or does the promotion fail and the entry stay in Am?
2. **Admission when both queues full** — A new completed sheet arrives; both Am and A1 are at capacity. Eviction scans Am tail first, but what if Am is empty (all entries promoted) and only A1 has entries? Does eviction proceed to A1 tail?
3. **Variable entry sizes** — Sheets are ~2 MiB but vary. The 3 GiB / 9 GiB split is a *byte budget*, not a count. Does eviction remove entries until bytes-free ≥ incoming-size, or is there a minimum-eviction quantum?
4. **Concurrent hit on same key** — Two requests hit an Am entry simultaneously. Both try to promote it to A1. Does the deduplication map extend to queue mutations, or can a race duplicate the entry?
5. **A1 recency update on hit** — An A1 entry is accessed. It moves to A1 head. If A1 is full, does this require evicting A1's tail *before* the move, or is the move free (just pointer update)?
6. **Renderer version change** — A clip gets a new renderer version. Old cached entries become stale (different key). Do they linger until evicted, or is there proactive invalidation?
7. **Partial eviction during admission** — Admitting a 3 MiB sheet when 2 MiB free. Evict one 2 MiB entry → still 1 MiB short. Does the loop continue until budget satisfied, or admit and temporarily overrun?
8. **Queue membership metadata persistence** — Worker restarts. Is queue state (Am/A1 membership, recency order) reconstructed from disk metadata, or does it start cold?

**STOP for user review.** Please confirm the LLD update and triage which gaps to fix in the LLD vs. defer.