**Phase 1 (HLD check) is done. I've stopped here for your review, so the record-store design is not finished yet.** The skill requires a stop after each phase, and you haven't authorized a consolidated cadence.

**What I changed**
- In `docs/high-level-design.md`, the record-store row's state now reads "Drafted; whole-visit revisions selected" (was "Drafted; concurrency choice open"). The HLD still covers this change, and the concurrency mechanism stays in record-store, so no architecture changes.
- `docs/intent/record-store/record-store-design.md` still shows the choice as OPEN. That is a known inconsistency until Phase 2 rewrites it.

**Things for you to decide**
1. **Tenet check.** The HLD tenet "Prefer workflows two coordinators can operate without a dedicated systems administrator" is the one whole-visit revisions puts pressure on, through the larger review queue. You've accepted that trade, so I haven't changed anything. Do you want it recorded in the HLD or only in the record-store Decisions table?
2. **Decision doc.** This choice will stay live for a cold reader, because the two options trade review workload against merge burden and the tablet-sync and review-export designs will be sized around it. Do you want it recorded as a decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, linked from a Decisions row? Or just a Decisions row?

**Next phases, once you approve this one**
- **Phase 2 (LLD):** rewrite the record-store design around whole-visit revisions. This covers the submission envelope with base revision ID, the current-state response, the unresolved-work representation, and the resolution operation. Tablet-sync and review-export stay untouched, as you asked.
- **Phase 3 (EARS):** REC-004 currently reads "regardless of the concurrency policy's outcome," which needs rewriting for the chosen policy. I'll also check REC-005 and REC-006 against the new contract.
- Then the Phase 4 edge audit, Phase 5 tests, and Phase 6 code, each with a stop.

Reply with your answers to the two questions and approval to proceed to Phase 2.