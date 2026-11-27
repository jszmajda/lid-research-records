The decision doc is written, and the record-store design now points to it. I haven't changed the HLD tenets yet.

**Written**
- `docs/intent/record-store/decisions/concurrency-policy.md` is the full decision doc. It covers the context, the criteria with the tenets they come from, both options analysed against those criteria, the selection, what the choice forecloses, the obligations for tablet-sync and review-export, and the conditions for revisiting it.
- `docs/intent/record-store/record-store-design.md`: the "OPEN" section is replaced by a short statement of the policy that links to the decision doc. Its downstream-contract paragraph now says the contract is pending the Phase 2 LLD rewrite.

**Why we'd still consider field-aware merge.** It cuts coordinator workload and gets more visits to the Friday export. Its cost is that it can combine scientifically related edits without anyone reviewing the combination. The decision doc lists three conditions that would justify reconsidering it after the first season: unresolved visits holding back the export, competing revisions that differ only in unrelated fields, and tablet resubmissions piling up competing revisions.

**What tablet-sync must accommodate.** Each local draft keeps its base revision ID. Pending competing revisions must be shown, and a submission that was held back must be explained to the worker. Tablets send whole visits, so they need no per-field merge state.

**What review-export must accommodate.** It needs a side-by-side revision comparison that shows which submission produced each revision. It has to exclude every visit with unresolved competing revisions from the CSV and list those visits in the export report. It also needs a queue of unresolved visits for the coordinators.

**Still open**
- The record-store LLD has no Decisions & Alternatives table yet. The decision is linked from the body text for now. The Phase 2 rewrite will add the table row.
- The tenet I proposed last time is still unanswered: *Keep each submitted visit whole as the unit of coordinator review, even when that adds review work.* I haven't added it to the HLD. Should I add it, reword it, or leave it out?

I'm stopping at the Phase 1 boundary. Once you approve this and answer the tenet question, Phase 2 rewrites the record-store LLD around whole-visit revisions.