**Phase 1 (HLD check): done, stopping for your review before I touch the record-store LLD.**

**What I changed in `docs/high-level-design.md`.** The edit is small, and the record-store design itself is untouched so far.
- The record-store State cell now reads "Drafted; revision contract pending" instead of "concurrency choice open".
- The paragraph under the architecture table said tablet-sync and review-export must wait on an unresolved choice. It now states the whole-visit revisions approach:
  - Each submitted visit stays intact, and competing revisions go to a coordinator.
  - Record-store owns the revision and unresolved-work contract.
  - Tablet-sync keeps each visit's base revision ID and shows pending competing revisions.
  - Review-export gets a revision comparison workflow and holds unresolved visits out of the CSV.

I kept the mechanism itself in record-store and left the tenets and goals alone. Whole-visit revisions follows "Do not silently discard a submitted edit" and the non-goal against inferring scientific intent.

**Decision to record.** Choosing whole-visit revisions over field-aware three-way merge trades review volume against merge-rule maintenance, and tablet-sync and review-export will be sized around it. A cold reader could plausibly want to reverse it. I'd offer a full decision doc at `docs/intent/record-store/decisions/`, laying out the options, the criteria, and your reason (a larger review queue is better than rules that can combine scientifically related edits without noticing). The alternative is a row in the record-store Decisions & Alternatives table, which would carry the same rationale in one line.

**Questions for you:**
1. Is the HLD wording above right, and do you approve it so I can move on to the record-store LLD?
2. Do you want the full decision doc, or just the table row?

**Next, in Phase 2, I will:**
- Remove the "Open Design Choice" section and write the contract it called for: the submission envelope with base revision ID, the current-state response, the unresolved-work representation, and the resolution operation.
- Run the LLD edge-case probe and present the gaps for your triage.

The LLD will have real choices for you to settle. One example is what happens when a tablet submits against a base revision that is no longer the latest, including a chain of three or more competing revisions. I'll sketch options for those rather than pick one myself.