Record-store design is finished for whole-visit revisions.

**Phase 1 – HLD check**
HLD `docs/high-level-design.md` is present, LID mode Full, and the record-store concurrency choice is now settled. Coherence pre-flight passes: HLD → LLD → EARS are aligned for the segment.

**Phase 2 – LLD updated**
`docs/intent/record-store/record-store-design.md` updated.

* Context & Architecture refined to whole-visit revisions
* Concurrency Policy: Whole-Visit Revisions section added
  * Submission envelope: `visitId`, `baseRevisionId`, `revisionId`, `payload`, `idempotencyKey`, `authorId`, `submittedAt`
  * Current-State Retrieval: `GET /visits/{visitId}` returns `currentRevisionId`, `currentPayload`, `hasUnresolved`, `baseRevisionId`
  * Unresolved Work Representation: `GET /visits/{visitId}/revisions` lists competing revisions sharing same `baseRevisionId` with resolution metadata
  * Resolution Operation: `POST /visits/{visitId}/resolve` records coordinator ID, chosen revision, contributing submission IDs; chosen revision becomes `currentRevisionId`
* Decisions & Alternatives table records the choice:
  Whole-visit revisions with base revision IDs and coordinator resolution vs Field-aware three-way merge. Rationale: preserve whole-visit intent and avoid merge rules that could combine scientifically related edits without noticing; accept larger review queue.
* Open Questions & Future Decisions: revision comparison UI/diff format and retention policy deferred to review-export.

**LLD-level edge-case probe**
What happens when…
1. First submission with `baseRevisionId = null` is later edited — does the new edit reference the first revision’s `revisionId` as base?
2. Coordinator resolves one competition, then new edits arrive based on the resolved revision — does a new `baseRevisionId` lineage start?
3. Submission references a non-existent `baseRevisionId` — reject or create orphan?
4. Same worker submits two competing revisions — allowed and treated as competition?
5. Coordinator resolves with a `chosenRevisionId` not in the competing set — validation required?
6. Idempotency key reused with different payload — rejected per REC-003, but does base revision handling stay consistent?
7. Visit has no submissions — retrieval returns null current state with `hasUnresolved` false?

Please triage which gaps to close in the LLD now vs defer.

**Phase 3 – EARS specs updated**
`docs/intent/record-store/record-store-specs.md` now contains:

- REC-001 to REC-006 existing
- REC-007: When a worker submits a visit edit with a base revision, the system SHALL require the submission to include a `baseRevisionId` and a unique `revisionId`.
- REC-008: When two or more submissions for the same visit share the same `baseRevisionId`, the system SHALL treat them as competing revisions and mark the visit as having unresolved review work.
- REC-009: When a visit has competing revisions with no coordinator resolution, the system SHALL return `hasUnresolved` true and `currentRevisionId` null for that visit.
- REC-010: When a coordinator resolves competing revisions by selecting a `chosenRevisionId`, the system SHALL set that revision as the visit's `currentRevisionId` and record the coordinator ID, resolution time, and contributing submission IDs.

Post-draft consistency:
* Coverage: submission envelope, current-state retrieval, unresolved representation, resolution are covered.
* Contradiction: none found.
* Implicit scoping: specs state scope explicitly with WHEN clauses.
* Context-free reading: each spec stands alone.

**Stop**
Phase 2 LLD and Phase 3 EARS are presented for review. Approve the whole-visit revisions design and spec set, and confirm which edge-case gaps to address now, before I proceed to Phase 4 intent-narrowing edge audit → Phase 5 tests-first → Phase 6 code.