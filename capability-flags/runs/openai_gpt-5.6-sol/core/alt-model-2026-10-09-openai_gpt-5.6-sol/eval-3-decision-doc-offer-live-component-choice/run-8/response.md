**Phase 2: Record-Store Design**
The whole-visit revision design is drafted in `docs/intent/record-store/record-store-design.md`. I also removed the stale open-choice status from `docs/high-level-design.md`.

The design now defines:

- Complete, immutable visit revisions with base revision IDs.
- Transactional current-revision advancement.
- Competing revisions and unresolved visit state.
- Exact-candidate-set coordinator review.
- Candidate selection or deliberate replacement revisions.
- Idempotent worker submissions.
- Retrieval, history, provenance, authorization, and downstream boundaries.

The EARS specs remain unchanged pending this design review.

The edge-case probe found five choices that need your ruling:

1. Should an unresolved set contain only the current revision plus submissions accepted since that conflict opened? The present wording could also include older clean revisions.
2. Should coordinator-created replacement revisions omit `submission ID` and instead identify the coordinator and resolution as their origin?
3. Can a revision correct a visit’s plot UUID, or is the plot UUID immutable once the visit is created?
4. If two tablets concurrently create the same visit UUID with `null` bases, should the first become current and the second become a competing revision, or should the second be rejected?
5. Should resolution operations have their own idempotency keys so a lost response can be retried safely?

The whole-visit versus field-merge choice remains credible enough that a future reader may re-litigate it, and tablet-sync plus review-export will be sized around it. Should I record it in a full decision document, or leave it as the existing Decisions & Alternatives table row?

Please reply with numbered answers and any other changes to the Phase 2 design.