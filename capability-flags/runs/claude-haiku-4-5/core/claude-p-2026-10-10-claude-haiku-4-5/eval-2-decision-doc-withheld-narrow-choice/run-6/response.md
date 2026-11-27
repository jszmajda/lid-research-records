Now I'll perform the **Phase 4: Intent-narrowing edge audit** to identify any ambiguities in the 2Q spec that could lead to different implementations.

Looking at the new specs, I've identified several areas where an implementation could diverge from the latent intent:

**PREVIEW-012 divergence probe:**
The spec says "When a cached entry in Queue A1 is accessed a second time, the system SHALL promote it to Queue A2."

**Divergent reading 1:** Does "accessed a second time" mean:
- Reading A: Accessed again *while still physically in A1*? (requires checking if the entry is still in A1 before promotion)
- Reading B: Accessed again at any point, regardless of whether it's already been evicted from A1?

Reading A makes sense (you can't promote something that's been evicted), but the spec needs to clarify the boundary condition: if A1 eviction removes an entry before it gets reaccessed, does a future access of that same preview key start fresh in A1, or does promotion to A2 still apply?

**Suggested narrowing:** "When a cached entry that is currently in Queue A1 is accessed, and this is not its first access, the system SHALL promote it to Queue A2 (or re-admit it to A2 if it was previously evicted)."

---

**PREVIEW-013 and PREVIEW-014 divergence probe:**
The specs describe eviction from A2 "least recently used first" and from A1 "in FIFO order."

**Divergent reading:** When should eviction happen?
- Reading A: Only when an entry is *about to be admitted* that would exceed the limit?
- Reading B: Continuously, as soon as any queue exceeds its limit?

Reading A suggests eviction happens on-demand during admission. Reading B suggests eviction could be proactive. The current design says "Before admitting a completed sheet, evict enough existing sheets to remain within that bound," which points to Reading A, but PREVIEW-014 doesn't explicitly mention "on admission."

**Suggested narrowing:** "When Queue A1 exceeds its 4 GiB limit *after* the most recent admission, the system SHALL evict entries from Queue A1..." (or clarify whether it's "before admission" as in the original design language).

---

**PREVIEW-015 divergence probe:**
The spec says eviction "SHALL NOT affect any pending render jobs, deduplication entries, or the pending-response protocol."

**Divergent reading:** If a render job completes and produces a JPEG that would be admitted, but eviction is needed first—
- Reading A: Evict, then admit the newly rendered sheet
- Reading B: Reject the newly rendered sheet if there's no room (keep the job ticket live)

The design intent is Reading A (the JPEG gets evicted if needed to make room), but the spec could be misread as Reading B.

**Suggested narrowing:** "Eviction happens before a newly rendered JPEG is admitted to the cache and SHALL NOT affect any pending render jobs or the deduplication map."

---

**Question for you:** Should I record these as resolved (with the narrowed readings captured in the spec), or would you like to review these divergences and decide how to narrow them before I update the specs?