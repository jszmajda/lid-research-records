---

**Phase 2 Stop — LLD Review**

I've updated the record-store LLD with the **whole-visit revisions** policy selected and completed the design with:
- Data model (Visit, Submission, Resolution entities)
- Submission envelope (complete payload + base_revision + idempotency key)
- Current-state response (resolved vs. unresolved with competing submissions)
- Unresolved-work representation (competing revisions sharing a base_revision)
- Resolution operation (coordinator picks one submission or provides manual merge)
- Decisions & Alternatives table recording the choice and rationale

The HLD has also been updated to reflect the resolved concurrency choice.

Please review the updated `docs/intent/record-store/record-store-design.md` and confirm to proceed to Phase 3 (EARS specs update).