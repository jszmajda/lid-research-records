The decision is recorded in `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store design.

It documents:

- Why whole-visit revisions best preserve scientific context and understandable provenance.
- Why field-aware merging remains credible if review volume becomes unsustainable.
- The tradeoff between coordinator workload and maintained scientific merge rules.
- Tablet obligations: base revision IDs, complete payloads, stable idempotency keys, unresolved outcomes, and no client-side merging.
- Review/export obligations: whole-revision comparison, exact candidate-set resolution, deliberate replacement revisions, provenance retention, and exclusion of unresolved visits from CSV exports.

Before Phase 2 can close, I still need your rulings on the edge cases:

1. Should an unresolved set contain only the current revision plus submissions accepted since that conflict opened?
2. Should coordinator-created replacement revisions have no submission ID, using the resolution and coordinator as their origin instead?
3. Can a revision correct a visit’s plot UUID, or is the plot UUID immutable after creation?
4. If two tablets concurrently create the same visit UUID, should the first become current and the second become a competing revision?
5. Should coordinator resolution requests carry idempotency keys for safe retry after a lost response?