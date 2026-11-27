Record-store design is updated for whole-visit revisions. Phase 2 LLD and Phase 3 EARS are ready for review.

**Phase 2 — LLD updated: docs/intent/record-store/record-store-design.md**
- Context and Design Philosophy clarified with preservation and inspectability tenets
- Submission Envelope defined: visitId, baseRevisionId, revisionPayload, authorId, idempotencyKey; authentication and validation required; idempotency behavior preserved
- Revision Model: whole-visit revisions
  - Each submission creates a revision with revisionId, baseRevisionId, payload, author, receipt time
  - baseRevisionId matches current resolved revision → submission becomes new current resolved revision
  - baseRevisionId older than current → submission accepted as competing revision, visit marked with unresolved review work
  - No automatic combination
- Retrieval: returns currentResolvedRevision + pendingRevisions list, and flags unresolved work
- Resolution: coordinator selects a revision, resolution records coordinator identity, timestamp and considered revision IDs; original submissions retained
- Export eligibility: visits with pendingRevisions are ineligible for export
- Decisions & Alternatives table records the choice:
  - Chosen: Whole-visit revisions with explicit coordinator resolution
  - Alternatives: Field-aware three-way merge
  - Rationale: preserves worker submitted visit as a unit, avoids merge logic for scientifically related fields, accepts larger review queue over maintaining merge rules
- Open Questions & Future Decisions updated; concurrency choice resolved

**Phase 3 — EARS specs updated: docs/intent/record-store/record-store-specs.md**
Existing REC-001 to REC-006 retained. Added:
- REC-007: When a submission includes a baseRevisionId, the system SHALL store the baseRevisionId with the revision.
- REC-008: When a submission's baseRevisionId matches the visit's current resolved revision ID, the system SHALL accept the submission as the new current resolved revision.
- REC-009: When a submission's baseRevisionId is older than the visit's current resolved revision ID, the system SHALL accept the submission as a competing revision and mark the visit as having unresolved review work.
- REC-010: When a visit has pending competing revisions, the system SHALL include those revisions in the visit retrieval response.
- REC-011: When a coordinator resolves a visit with competing revisions by selecting a revision, the system SHALL set the selected revision as the current resolved revision and record the coordinator's identity with the resolution.
- REC-012: When a visit has unresolved review work, the system SHALL exclude it from export eligibility.

Post-draft consistency check:
- Coverage: submission envelope, revision branching, retrieval, resolution and export eligibility are now covered by specs
- Contradiction: none found
- Scope: all specs name scope explicitly via When clauses
- Context-free: specs read standalone

Stop for user review. Please confirm the LLD and specs reflect the whole-visit revisions intent and the submission/retrieval/resolution contract you want tablet-sync and review-export to build against. On approval I will proceed to Phase 4 intent-narrowing edge audit before tests-first.