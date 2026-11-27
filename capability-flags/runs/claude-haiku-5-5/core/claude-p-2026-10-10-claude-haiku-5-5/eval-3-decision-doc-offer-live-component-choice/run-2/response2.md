Phase 2 (LLD) is drafted for review. I haven't touched the EARS specs yet, since Phase 3 waits for your approval here.

**Files changed**
- `docs/intent/record-store/decisions/concurrent-visit-edits.md` (new): the decision doc. I read "write that up properly" as accepting the decision-doc offer. It covers the criteria, both options, and why whole-visit revisions won. It also says when to reopen the choice: if unrelated competing revisions dominate the review queue and can't be cleared before Friday, the field-aware merge should be reconsidered.
- `docs/intent/record-store/record-store-design.md`: rewritten as a full LLD. It has the submission envelope, acceptance outcomes, current-state response, the concurrency rules, obligations for tablet-sync and review-export, a Decisions & Alternatives table, and open questions.
- `docs/high-level-design.md`: the record-store state cell now reads "Drafted; whole-visit revisions selected."

**Rules I chose (redirect any of these)**
1. A submission based on the current revision becomes the next current revision. Any other submission becomes a competing revision.
2. While a visit has unresolved competing revisions, every new submission for it also competes. Nothing advances the current revision automatically.
3. The current revision holds at the last revision before the conflict until a resolution makes a different one current.
4. Idempotency keys are client-generated. A retry with an identical payload returns the original result.

**What tablet-sync must accommodate**
- Each draft keeps its base revision ID and the full visit until the server accepts it.
- A competing-revision result is shown to the worker as a saved edit awaiting review, not as an error.
- Retries reuse the same key and payload.
- Storage scales with visits edited, since each draft holds a whole visit.

**What review-export must accommodate**
- A comparison view across the revisions of one visit, with author and receipt time for each.
- Review queues sized by visits with competing revisions, including edits to unrelated fields.
- Every exported row traces to its revision, and resolved rows also trace to the resolution and its submissions.

**Still open, and needs your answer before Phase 3**
1. **Friday export for a visit with unresolved competing revisions.** Omit it from the CSV, export its current revision with a flag, or hold the whole export until it's resolved?
2. **Form of a resolution.** Can a coordinator only select an existing revision, or also compose a new one from parts of several submissions?

A third question, whether a resolution covers submissions that arrive while it's being recorded, is deferred to the Phase 4 edge audit.

Once you answer these and approve the LLD, I'll update the EARS specs (Phase 3). The spec file currently has REC-001 through REC-006 and doesn't yet cover the competing-revision rules.