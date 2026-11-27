## Phase 2: Record-Store LLD Review

Updated `docs/intent/record-store/record-store-design.md` with:

- Immutable, complete visit revisions rather than field patches.
- Base revision IDs for edits.
- Automatic selection only when an edit starts from the selected revision and no review is open.
- Stale-base edits retained as competing revisions, with no arrival-order winner.
- Coordinator selection of a complete competing revision, with coordinator and contributing-revision provenance.
- Tablet obligations: retain base revision IDs, retry with the same idempotency key, submit full payloads, and expose pending review.
- Review/export obligations: compare whole revisions, record the selected revision, retain provenance, and exclude unresolved visits from the reviewed CSV.
- A Decisions & Alternatives row explaining why whole-visit revisions were selected and why field-aware merging remains a credible future alternative.

The alternative remains worth reconsidering only if review volume becomes unsustainable and the team can safely maintain scientific merge rules for all fields and their relationships. It would reduce review volume, but changes the contract to base snapshots, structured field changes, and field-level provenance.

The LLD edge-case probe found these decisions must be settled before I can write unambiguous EARS specs:

1. When a visit already has unresolved review work, should a later edit be rejected, retained as another competing revision in the same review item, or handled another way?
2. May a coordinator only choose among submitted competing revisions, or may they create a corrected revision during resolution?
3. Does the candidate set include the revision selected before the conflict, allowing a coordinator to keep it?
4. How should two simultaneous stale-base submissions be serialized so exactly one becomes selected and the other opens review?
5. How should a concurrent coordinator resolution and competing submission be serialized?
6. Should resolving an already-resolved review item fail, or be idempotent for the same coordinator request?
7. What is the intended scope of an idempotency key: per authenticated worker, globally, or another boundary?
8. Should the store treat semantically equivalent but differently encoded retry payloads as identical, or require byte-for-byte equality?
9. What should happen when an edit names an unknown revision, a revision from another visit, or a revision that cannot be used as a base?
10. For current-state retrieval while review is unresolved, should the response expose the last selected revision alongside an `unresolved` status, or only the unresolved state and review identifier?

Please answer the numbered decisions and approve the LLD draft.