Created `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the record-store design.

The decision document now records:

- Why whole-visit revisions preserve scientific context.
- The strongest case for field-aware merging, especially its smaller review queue.
- Conditions that could justify reconsidering field-aware merging later.
- Weighted criteria and project tenets behind the selection.
- Tablet-sync obligations: base revision IDs, complete payloads, stable idempotency keys, and review-required outcomes.
- Review-export obligations: complete-revision comparison, provenance, exact resolution membership, and exclusion of unresolved visits from CSV.
- Clear ownership boundaries so those later designs control their workflows without redefining concurrency semantics.

`git diff --check` passes.

Phase 2 still needs your answers to the edge-case questions from the previous review, particularly rejected-request retention, idempotency behavior, validation scope, and conflict races. Once those are resolved and you approve the design, I’ll proceed to the EARS requirements.