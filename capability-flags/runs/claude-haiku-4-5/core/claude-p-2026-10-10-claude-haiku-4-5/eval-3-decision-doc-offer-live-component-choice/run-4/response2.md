---

## Phase 2 Stop — Record Store LLD Review

I've completed the record-store design based on your whole-visit revisions decision. Here's what's ready for review:

**Updated LLD: `docs/intent/record-store/record-store-design.md`**

The design now specifies:

1. **Whole-Visit Revisions mechanism**: each submission carries a base revision ID; competing submissions trigger coordinator review. No field-level merging.

2. **Why this choice**: preserves scientific integrity (field relationships remain as submitted), eliminates merge rule maintenance, makes exports fully auditable. Trade-off: higher coordinator review volume, which the team accepts.

3. **Why the alternative matters**: Field-aware three-way merge remains viable if review load becomes unsustainable. The specs and storage are unchanged; only the merge logic and review workflow would evolve. This is explicitly recorded so the path stays open.

4. **Downstream contracts — what tablet-sync must do**:
   - Store base revision IDs and chain submissions from current state
   - Display pending unresolved work to the worker
   - Block export of unresolved visits

5. **Downstream contracts — what review-export must do**:
   - Revision comparison interface (side-by-side view of competing submissions)
   - Resolution operations (accept-this, discard-this, manual-combine)
   - Hold unresolved visits from the Friday CSV export
   - Audit trail of coordinator decisions

6. **Submission envelope, current-state response, and resolution operation**: all specified with enough detail that tablet-sync and review-export can size their interfaces around this contract.

7. **Decisions & Alternatives table**: documents the concurrency choice and why it was made.

8. **Open Questions**: deferred decisions (retention policy, concurrent resolution locking, revision sort order, plot immutability, revision limits) with context on why each is deferred.

**Ready to proceed?** Once you approve, I'll move to Phase 3 (expand the EARS specs to cover the full submission, retrieval, and resolution lifecycle) and then Phase 4 (edge-case audit across tablet-sync and review-export dependencies).