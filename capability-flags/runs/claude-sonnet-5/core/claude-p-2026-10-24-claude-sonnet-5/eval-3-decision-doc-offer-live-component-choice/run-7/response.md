I picked up the choice you made last session and finished the record-store design around whole-visit revisions.

**What changed**
- `docs/intent/record-store/record-store-design.md`: resolved the open concurrency choice. Added the concurrency policy (base-revision matching, competing revisions never auto-combined), the submission envelope, current-state/unresolved-work retrieval, the resolution operation (coordinator submits contributing submission IDs + a resulting payload; record-store just records the outcome, never interprets how it was composed), and a Decisions & Alternatives row capturing your rationale.
- `docs/high-level-design.md`: record-store's state is now "Drafted" (no longer "concurrency choice open"); tablet-sync and review-export are noted as waiting on this contract.

**Decision doc or just the table row?**
This choice has two credible options traded against more than one criterion, and tablet-sync and review-export are about to be sized around it — that clears the bar where I'd normally offer a full decision doc instead of just the table row I added. Want one (`docs/intent/record-store/decisions/concurrency-policy.md`), or is the row enough?

**Gaps the LLD itself doesn't settle yet** (Phase 2 edge-case probe — these are internal to record-store, not cross-segment):
1. If a submission's base revision ID doesn't match any revision record-store has for that visit (stale/corrupt client state), is that a validation rejection or does it also become a competing revision?
2. Can a resolution be revised later (coordinator realizes they picked wrong), or is a resolution final once recorded?
3. If a coordinator's resolution payload is identical to neither contributing revision (manually composed), does it need a fresh idempotency key the way a worker submission does, or is resolution exempt from idempotency concerns?
4. Three-plus-way races: if three submissions land on the same base revision, do they all become competing revisions together, or does the second settle as current and the third contest against it?

Let me know which of these to pin down in the LLD now versus leave as deferred open questions, and the decision-doc call above — then I'll treat the record-store design as ready to move on from.