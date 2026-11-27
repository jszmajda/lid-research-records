Done. The record-store design is finished around whole-visit revisions:

- **LLD** (`docs/intent/record-store/record-store-design.md`): the open choice section is replaced by a concrete revision model — complete-visit payloads with a client-supplied `base_revision_id`; edits against the current tip advance it silently, edits against anything else become competing revisions and the visit goes unresolved; no server-side merging; resolution adopts one revision and preserves all originals. Decisions & Alternatives records the rejected field-aware merge and why.
- **Specs** (`record-store-specs.md`): REC-001–005 kept (REC-006 tightened to name the adopted revision); new REC-007–014 cover initial revision, tip-advance vs. competing-revision paths, behavior while unresolved, resolution, the two retrieval shapes, and the preservation invariant.
- **HLD**: record-store's state updated and the "designs must wait" paragraph now states the chosen contract tablet-sync and review-export will build on.

Consistency notes: REC-004 and REC-014 overlap intentionally — 004 is the concurrent-edit case, 014 the general preservation invariant. No spec contradicts another; scopes are explicit per line.

Two judgment calls I'd like your read on before this feeds tablet-sync and review-export:

1. **Unresolved-visit submission rule (REC-010)**: while a visit is unresolved, I made *every* further submission another competing revision — there's no adopted revision to edit against, and arrival order shouldn't grant authority. Alternative: allow edits naming the pre-conflict tip to auto-win. Which do you want?
2. **Resolution shape**: I limited coordinators to *adopting* one competing revision as submitted. Whether they may author a corrective revision inline at resolution time is left as a deferred open question in the LLD. Should resolution stay adopt-only for this release?

One offer: the concurrency-policy choice is genuinely live — a cold reader might re-litigate whole-visit revisions against field-aware merge since two nodes will size around it. Want a standalone decision doc under `docs/intent/record-store/decisions/`, or is the LLD's Decisions row enough?