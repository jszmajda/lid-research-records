I wrote the decision doc and made the HLD status change.

**Files**
- `docs/intent/record-store/decisions/concurrency-policy.md`: new. It records the choice between whole-visit revisions and field-aware merge, with the criteria, both options, the reasons for selection, and what the choice commits the system to.
- `docs/high-level-design.md`: the record-store State cell now reads "Drafted; whole-visit revisions selected."

**What the doc covers**
- **Why whole-visit:** each visit stays a unit a worker actually submitted, and related scientific edits, such as a species identification and its cover estimate, are never recombined by rules that can't see their relationship. The cost is a larger review queue, since even edits to unrelated fields create review work. That cost was accepted, and the doc says so.
- **Why field-aware merge stays under consideration:** it would be reconsidered if review volume becomes unmanageable before the Friday export, if most concurrent edits turn out to touch unrelated fields, or if the scientific team can state which field combinations are safe to merge automatically. The doc also notes that a reversal changes the submission envelope and review model, so it should be deliberate.
- **Tablet-sync must:** send the starting revision ID and the complete visit with each submission, keep base revision IDs for local drafts, and show pending competing revisions to the field worker. It does not merge.
- **Review-export must:** provide a comparison view of competing revisions and exclude visits with unresolved competing revisions from the Friday CSV.
- **Record-store retrieval must:** report whether unresolved competing revisions exist for a visit (REC-005).

**Still open**
- **How a coordinator resolves competing revisions.** Does resolution only select one submitted revision as a whole, or can a coordinator also author a combined revision? I recommended selecting a whole submitted revision, but this is your call, and the doc deliberately leaves it open. The record-store LLD will need your answer.
- **The record-store LLD is out of step with the HLD for now.** It still says the concurrency choice is OPEN. I haven't changed it because the LLD draft is Phase 2 work, after your review of this phase. The HLD and the decision doc now say the choice is selected.

I haven't started the LLD. Once you answer the resolution question and approve this, I'll draft it (Phase 2) and stop again for your review.