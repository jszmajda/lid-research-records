Good. The LLD is now updated. Let me present the Phase 2 stop.

---

**Phase 2 — LLD stop**

The `previews-design.md` LLD is updated with the 2Q decision. Here's what changed:

**Private Cache section** — replaced the open-ended "candidates are…" paragraph with a full 2Q design:
- A1 (probationary, FIFO, 3 GiB default) receives all first-admission entries.
- Am (main, LRU, 9 GiB default — derived as `total limit − A1 limit`) holds promoted entries.
- Admission: evict from A1 head when A1 is at its size limit, with "one or more" to handle variable-size entries.
- Promotion: move A1 entry to Am's MRU end; evict from Am's LRU end if Am would exceed its own capacity (I caught and corrected an error in my first draft — promotion doesn't change total occupancy, so the eviction condition is "Am at capacity," not "total at ceiling").
- Am hit: move to MRU end, no size change.
- Screening-scan narrative explaining why Am is protected.

**Decisions & Alternatives table** added, with row for policy choice (pointing to a potential decision doc) and a row for the 3 GiB A1 default.

**HLD** updated: "Its eviction policy remains open" → "using 2Q replacement."

---

**Edge-case probe — gaps to triage**

Two gaps the LLD doesn't resolve that I'd like you to triage (fix in the LLD now, or defer as open questions):

1. **Startup validation bounds for the A1 size limit.** The LLD says the parameter is configurable but sets no valid range. Two degenerate values are possible: 0 GiB (every entry immediately evicted from A1 — no probationary queue, no scan resistance) and 12 GiB (Am capacity is 0 — nothing ever gets LRU protection). Should the worker reject these at startup? If so, what are the stated valid bounds?

2. **Concurrent eviction during an Am hit read.** When Am's LRU end is evicted during a promotion, the LLD doesn't address what happens if the eviction target is currently being read (a 202→200 retry is in-flight, reading that entry's bytes). Does eviction wait for the read to complete, or proceed immediately? The LLD is silent on this I/O ordering question.

---

**Decision doc offer (once)**

The eviction policy choice won't look obvious to a cold reader: 2Q is less common than LRU, and a future maintainer could reasonably try to simplify it. Three credible options were weighed against concrete criteria, and the Am/A1 size split is a parameter future tuning decisions will lean on. That clears the earns-its-place bar for a full decision doc. The Decisions row already exists in the LLD and is sufficient if you'd rather not write a doc — your call. Would you like me to write `docs/intent/previews/decisions/eviction-policy.md`?

---

Please review the LLD and triage the two probe gaps. Once you approve Phase 2, I'll move to Phase 3 (EARS specs).