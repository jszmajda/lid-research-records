**Phase 1 (HLD check) is done. Stopping here for your review before the record-store LLD.**

**What I changed in `docs/high-level-design.md`**
- The record-store State cell now reads "Drafted; whole-visit revisions selected, contract pending" (it was "concurrency choice open").
- The paragraph under the table now says record-store uses whole-visit revisions, and that tablet-sync and review-export depend on its contract. It still says those two designs must wait for that contract.

The HLD's architecture is unchanged. The concurrency decision itself belongs in the record-store LLD, so I did not add it to the HLD.

**Tenet tension to confirm**
The tenet "Prefer workflows two coordinators can operate without a dedicated systems administrator" is in tension with a larger review queue. You've already accepted the bigger queue, and the tenet is about administration rather than queue size, so it may still hold. Do you want it left as written, or reworded?

**Decision doc offer**
This choice will stay live for a cold reader, and tablet-sync and review-export will be sized around it. Do you want me to record it as a decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, with a row in the record-store LLD's Decisions & Alternatives table pointing to it? If not, I'll record just the row.

**Next (after your approval)**
Phase 2 is the record-store LLD draft. It will close the OPEN section and define the submission envelope, current-state response, unresolved-work representation, and resolution operation. It will also raise any forks I find there, such as what a retrieval returns for a visit with competing revisions. Phases 3–6 follow with their own stops. Tablet-sync and review-export come after record-store is finished.