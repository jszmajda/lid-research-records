Record-store design is updated for whole-visit revisions.

**Phase 2 – LLD**
`docs/intent/record-store/record-store-design.md` now defines:
- Submission envelope: visitId, baseRevisionId, payload, idempotencyKey, authorId, clientTimestamp
- Revision model: each accepted submission creates a whole-visit revision; a visit tracks resolvedRevisionId and pendingRevisions derived from the same base
- Current state retrieval returns resolved payload + `hasUnresolvedWork` and pending revision metadata
- Resolution records coordinatorId, selectedRevisionId, supersededRevisionIds, resolutionTime and promotes the winner to resolved

Decisions & Alternatives table records the concurrency choice:
- Chosen: Whole-visit revisions
- Alternatives considered: Field-aware three-way merge
- Rationale: preserve submitted visit as a unit, avoid merge rules that can combine scientifically related edits without noticing, accept larger review queue

**LLD edge-case probe – triage needed**
1. What happens when baseRevisionId is null for a non-initial submission? Reject or treat as new visit?
2. What happens when baseRevisionId references a revision that does not exist for the visit?
3. What happens when a new submission arrives after resolution but is based on a superseded base? Create new pending set?
4. How is the first submission handled when no resolved revision exists yet? Does it become resolved immediately?
5. Should retrieval order/present pending revisions deterministically, and by what key?
6. What error shape is returned for validation failures and for idempotency key reuse with different payload?
7. Is concurrent resolution by two coordinators prevented? What locking/serialisation is required?
8. What is the retention rule for superseded pending revisions after resolution?

**Phase 3 – EARS**
`docs/intent/record-store/record-store-specs.md` updated. New specs:
- REC-007: When a worker submits a visit edit, the system SHALL store the provided baseRevisionId with the submission.
- REC-008: When a submission is accepted, the system SHALL create a new revision ID for the submission and store the complete visit payload as that revision.
- REC-009: When a visit has one or more pending revisions, the system SHALL include those revisions in the retrieval response with their revision IDs, baseRevisionIds, author IDs, and server receipt times.
- REC-010: When a coordinator selects a winning revision to resolve review work, the system SHALL set that revision as the resolved revision for the visit and retain superseded pending revisions for audit.

Existing REC-001 to REC-006 retained.

Consistency report:
- Coverage: Submission envelope, revision creation, pending work exposure, and resolution are covered by specs REC-007 to REC-010; retention and idempotency covered by REC-001 to REC-003; preservation and review signalling covered by REC-004 to REC-006.
- Contradiction: none found.
- Implicit scoping: specs name visit and submission context explicitly; no universal reading.
- Context-free reading: each spec stands alone.

Please review the LLD, edge-case list, and specs. Confirm the design and which edge cases to resolve now vs defer, and approve to proceed to Phase 4 intent-narrowing edge audit.