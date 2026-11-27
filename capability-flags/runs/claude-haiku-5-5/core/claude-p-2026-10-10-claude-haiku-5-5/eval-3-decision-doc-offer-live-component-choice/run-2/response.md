**Phase 1 (HLD check) is ready for your review. I haven't edited any files yet.**

I worked from the two options as recorded in `docs/intent/record-store/record-store-design.md` and your message. I don't have last session's sketch, so if it said something different, tell me.

**Pre-flight:** The six REC specs agree with the record-store design. The design doc doesn't yet have a Decisions & Alternatives table, which Phase 2 will add.

**HLD check:** The HLD assigns the concurrency choice to record-store, and whole-visit revisions fits that. On acceptance, the only HLD change is the record-store state cell, from "Drafted; concurrency choice open" to "Drafted; whole-visit revisions." The architecture doesn't change. Keeping both competing revisions honors "Do not silently discard a submitted edit." The cost is a larger coordinator queue, which you've already accepted.

**Decision record:** This choice would still be questioned by a cold reader, and tablet-sync and review-export will be sized around it. I'd record it as a decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, linked from a row in the record-store Decisions table. Do you want the doc, or just the row?

**Questions only you can settle:**
1. **Friday export for a visit with unresolved competing revisions.** Should the visit be left out of the partner's CSV, exported with its last accepted revision and a flag, or should the export wait until it's resolved? The partner reads this CSV, and the "do not silently discard" tenet applies directly. The design doesn't say yet.
2. **How a coordinator resolves competing revisions.** Do they pick one existing revision, or can they enter a new combined revision? REC-006 and the resolution operation depend on this.

Once you approve the HLD note and answer both questions, I'll draft the record-store LLD (Phase 2) with its Decisions table, then the EARS updates (Phase 3).