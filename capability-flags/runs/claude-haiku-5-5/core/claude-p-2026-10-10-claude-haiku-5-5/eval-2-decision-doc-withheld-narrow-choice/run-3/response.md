**Phase 1 (HLD check) is done. I've stopped for your review and haven't edited any files.**

I worked from the three options as they're recorded in `docs/intent/previews/previews-design.md`, in the Context and Architecture paragraphs. I don't have last session's thread.

**Architecture impact:** Choosing 2Q doesn't change the architecture. The HLD already leaves the eviction policy to the preview worker. The external contract, the four-job render queue, and the 12 GiB budget all stay the same. The design work moves into the previews LLD in Phase 2.

**Coherence pre-flight:** The HLD, the previews design, and PREVIEW-001 through PREVIEW-005 agree with each other. The only stale line is in the HLD's Architecture section: "Its eviction policy remains open." I propose deleting that sentence. The HLD Tenets already say replacement bookkeeping stays private to the worker.

**Decisions I need from you:**

1. **2Q sizing.** I propose a first-use queue at about 25% of the 12 GiB budget and a reused queue at about 75%, held as a configuration parameter so you can tune it. Is that the starting point you want?
2. **Ghost list.** Classic 2Q keeps a metadata-only list of keys recently evicted from the first-use queue, so a sheet requested again soon after its first use gets promoted. It stores keys, not JPEG bytes, so it doesn't count against the 12 GiB. I recommend including it, capped at about the first-use queue's sheet count, because without it a second look at a sheet never promotes. Include it, or drop it for simpler bookkeeping?
3. **Specs (for Phase 3).** PREVIEW-004 says "evict entries" without an order. 2Q needs one: evict from the first-use queue when it is over its share, otherwise from the reused queue. I'll write that as new atomic specs.

When you reply, approve or change the HLD edit and answer 1 and 2. Then I'll move to Phase 2 and draft the previews LLD, replacing the options paragraph with the chosen policy and adding a Decisions & Alternatives row that records the rationale.