**Phase 1: HLD check (stopping for your review)**

I read the HLD, the record-store and site-catalog designs and specs, and the decision-doc guidance. No files are changed yet.

Coherence check: the HLD, the record-store design, and REC-001 to REC-006 agree with each other. The catalog node doesn't depend on this choice. The HLD's architecture is unchanged, and the choice of whole-visit revisions is consistent with the tenet "Do not silently discard a submitted edit."

**Proposed edits, pending your approval**

1. **HLD status.** In the architecture table, change record-store's State from "Drafted; concurrency choice open" to "Drafted; whole-visit revisions selected."
2. **Recording the choice.** This choice will stay live for a cold reader. Field-aware merge is a credible alternative, and tablet-sync and review-export are being sized around it. So it clears the bar for a decision doc. I'd offer one at `docs/intent/record-store/decisions/concurrency-policy.md`, owned by record-store and carrying no spec IDs, with a Decisions & Alternatives row in the record-store LLD linking to it. The lighter option is a single row in the LLD with field-aware merge rejected in one line. Which do you want?

**What the choice commits us to**

- Every edit names the revision it started from. Concurrent edits become competing complete revisions. Original submissions are always kept.
- Retrieval reports whether unresolved review work exists (REC-005).
- Tablet-sync keeps base revision IDs and shows pending competing revisions.
- Review-export needs a revision comparison screen and keeps unresolved visits out of the CSV.
- The accepted cost: unrelated edits, such as an observer-name fix plus a missing species, now create review work.

**One decision needed before Phase 2**

How does a coordinator resolve competing revisions?

- **(a) Select one submitted revision as a whole.** The other stays in history. Every resolved visit then equals a submission a worker actually made.
- **(b) Select one, or author a new combined revision.** This needs a coordinator-authored revision type, and the record would no longer have a single worker as its author.

I recommend (a). It fits "preserve the worker's submitted visit as a unit" and is simpler for the coordinators to operate.

Reply with: approval or changes to the HLD status edit, your choice on the decision doc or row, and (a) or (b). I'll then draft the record-store LLD (Phase 2) and stop again for review.