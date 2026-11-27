Record-store design is finished for whole-visit revisions. Phase 1–3 completed with mandatory stops.

**Phase 2 — LLD updated:** `docs/intent/record-store/record-store-design.md`

- Context and Architecture now state the concurrency policy is fixed to whole-visit revisions.
- Submission envelope defined: `visitId`, `baseRevisionId`, `payload`, `idempotencyKey`.
- Current-state response returns `revisionId`, `visitId`, `payload`, `authorId`, `receivedAt`, `status`, `unresolved`.
- Unresolved work representation: `competingRevisions` list with author/receivedAt/baseRevisionId and fork `baseRevisionId`; no field merging.
- Resolution operation: `resolveVisit(visitId, chosenRevisionId, coordinatorId, note)` records coordinator identity + contributing submission IDs, marks chosen revision current, others superseded, idempotent.
- Downstream contract notes added for tablet-sync and review-export.
- Decisions & Alternatives table records:
  * Decision: Concurrent visit edits — Chosen: Whole-visit revisions — Alternatives: Field-aware three-way merge — Rationale: preserves submitted visit as unit, avoids merge rules that could combine scientifically related edits without noticing; larger review queue accepted.
- Open Questions: revision comparison UI shape deferred to review-export; tablet-sync offline queueing deferred to tablet-sync LLD.

**Phase 3 — EARS specs updated:** `docs/intent/record-store/record-store-specs.md`

- **REC-001** to **REC-006** retained for auth, idempotency, preservation, unresolved indication, coordinator audit.
- **REC-007**: When a visit edit is submitted with a baseRevisionId, the system SHALL store the baseRevisionId with the new revision.
- **REC-008**: When a visit has two or more revisions with the same baseRevisionId and no resolution, the system SHALL present them as competing revisions.
- **REC-009**: When a coordinator resolves a visit by selecting a revision ID, the system SHALL mark the selected revision as current, mark other competing revisions as superseded, and update the visit's current revision pointer.
- **REC-010**: When retrieving a visit with unresolved competing revisions, the system SHALL return the current revision if one is selected, or indicate no current revision, together with the list of competing revisions.

Consistency verification:
- Coverage: LLD submission envelope, current-state, unresolved representation, and resolution are covered by REC-007–REC-010 plus REC-001–REC-006.
- Contradiction: none found.
- Implicit scoping: scopes are explicit in WHEN clauses; no universal statements that hide mode.

Phase 4 intent-narrowing edge audit — gaps for you to triage:
1. What happens when a new edit arrives with `baseRevisionId` pointing to a superseded revision? Should it be allowed, rejected, or create a new fork chain?
2. Initial submission uses `baseRevisionId = null`. Does an edit based on an unresolved competing revision need validation that the base is the current revision, or is any base allowed?
3. After a coordinator resolves a visit, can further edits be based on the superseded revision? If so, how is the fork represented?
4. Idempotency key reuse with different `baseRevisionId` — REC-003 rejects different payload, but should a different baseRevisionId with same payload be treated as a new submission?
5. Concurrent resolution attempts — resolution is idempotent per design, but do we need a last-writer-wins rule or explicit conflict error?

Approve the LLD and specs as written, or provide numbered feedback to adjust the design or specs before we proceed to tablet-sync and review-export.