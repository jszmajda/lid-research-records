The record-store design is finished and ready for your review. I consolidated the LLD and EARS stops into this one review since you asked me to finish the node's design in one go — say the word if you'd rather split them.

**What changed**

- `docs/intent/record-store/record-store-design.md` — the open choice is resolved to whole-visit revisions. New "Revision Model" section defines the contract tablet-sync and review-export will build on: each accepted submission is an immutable revision carrying visit ID, revision ID, base revision, complete payload, author, and receipt time. Base = head extends the chain; base ≠ head is a competing revision — retained in full, head doesn't move, visit flagged unresolved. Resolution adopts one competing revision and clears the flag. The "Downstream Contract Work" section now states the concrete obligations: tablet-sync retains base revision IDs per draft and reads the unresolved flag; review-export gets the comparison view and holds unresolved visits out of the CSV.
- `docs/intent/record-store/record-store-specs.md` — REC-004 rewritten from "regardless of the concurrency policy" to concrete fork semantics; REC-005 expanded to list competing revisions; new REC-007–REC-013 cover first submissions, chain extension, frozen head while unresolved, resolution, bad base references, revision-history retrieval, and field/plot validation.
- `docs/high-level-design.md` — record-store row updated and the "must wait for its contract" paragraph rewritten; tablet-sync and review-export may now design against the settled contract.

**Decision doc offer (once)**: the whole-visit-revisions choice traded two credible options on review workload, merge-rule burden, and payload shape, and both sibling segments are being sized around it — a cold reader could plausibly be tempted to reverse it. I've recorded it as a Decisions & Alternatives row. Want a full decision doc (`docs/intent/record-store/decisions/`) so the tradeoffs can be re-run later, or is the row enough?

**Forks and deferred questions for you to rule on before tablet-sync starts**

1. **Two first submissions for the same visit.** If two workers both create the same visit UUID independently (neither saw the other's first submission), both arrive with no base revision. Should the second be treated as a competing revision (fork → review), or rejected as a duplicate?
2. **Submissions based on a losing revision.** After a fork resolves by adopting revision A, a worker whose draft was based on the rejected revision B submits. Today's design accepts it as a new competing revision. Alternative: only the adopted line may be extended, and off-line bases are rejected.
3. **Deferred in the LLD** — confirm or override: (a) resolution adopts one revision only; coordinator-authored combined records deferred to the review-export design; (b) worker withdrawal of their own pending revision deferred until tablet-sync asks for it.

No capability flags applied to this session.