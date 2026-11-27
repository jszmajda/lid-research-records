I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`. I took "write that up properly" to mean the decision doc from question 2; tell me if you meant something else.

**What it records**
- **Context:** why concurrent visit edits need a policy, and why the server can't tell related edits from unrelated ones by field name.
- **Gates:** original submissions are never discarded, and capture works offline for 48 hours.
- **Criteria:**
  - Major: scientific integrity of the resolved visit, and explainability of exported values.
  - Moderate: review volume, and maintenance burden.
  - Minor: tablet and submission size.
  - Each is tied to the HLD tenets and non-goals it comes from.
- **Options:** each of the two options is described at its strongest, with a worked example and a verdict per criterion.
- **Selection:** whole-visit revisions win on the two major criteria. They lose on review volume, which is a moderate criterion with a visible, bounded cost.
- **Why the other approach stays credible:** a "Conditions to Revisit" section. Reconsider field-aware merge if the queue stops clearing before Friday and the competing edits are mostly plainly unrelated fields, or if the protocol stabilizes enough for a short owned rule set. It also notes that merge could later return as a coordinator-reviewed candidate revision.
- **What tablet-sync and review-export must accommodate:**
  - Tablet-sync keeps a base revision ID per local draft and sends it with each submission. It shows workers when competing revisions exist, and it needs no base snapshots or structured change sets.
  - Review-export provides a revision comparison, records each resolution, and holds unresolved visits out of the CSV. It sizes its queue and export-eligibility rules around that hold-back.

**Your call**
1. **Tenet:** you didn't answer whether to add "Keep a worker's submitted visit intact; never automatically combine edits across fields." I haven't added it to the HLD, and the doc cites only existing tenets.
2. **Site-catalog:** you also didn't answer whether to update the stale "pending that choice" line in `site-catalog-design.md`. I left it alone because it's a different segment.
3. **Conflict rate:** nothing in the repo says how often visits get competing revisions. The doc says so, and that rate is the evidence that would show whether the queue is workable. If the team has last season's numbers, I'd put them in.
4. **Resolution model:** the doc doesn't say whether a coordinator picks one revision or authors a new one. I'll raise that as a Phase 2 question.

I haven't linked the doc from the LLD's Decisions & Alternatives table yet. That happens in Phase 2.

Do you approve the HLD update and this doc? If so, I'll start Phase 2: replace the OPEN section in the record-store LLD with the whole-visit contract and run the LLD edge-case probe.