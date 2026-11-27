Phase 2 LLD and Phase 3 EARS updates for record-store are ready for review.

**record-store-design.md** – whole-visit revisions locked in
- Context and Architecture clarified for tablet-sync / review-export dependency.
- Submission Envelope: visitId, baseRevisionId, complete payload, authorId, clientTimestamp, idempotencyKey; server stores immutable revision with receipt time and revisionId.
- Current State Representation: currentRevisionId points to coordinator-resolved revision; when unresolved, latest accepted revision is used and reviewStatus is pending/clean/resolved with competingRevisionIds returned.
- Unresolved Work Representation: pending when ≥2 revisions share same baseRevisionId with no resolution; export eligibility is false while pending.
- Resolution Operation: coordinator selects an existing revision or creates manual revision; records resolvingCoordinatorId, chosenRevisionId/manual payload, contributingSubmissionIds, timestamp; clears competing set.
- Decisions & Alternatives table added:
  * Concurrent edit policy → Whole-visit revisions chosen over field-aware three-way merge. Rationale: preserves worker intent as a unit, avoids scientifically-related field rules, matches tenet not to silently discard edits; accepts larger review queue.
  * Revision identification → client-generated visitId with server-generated revisionId.
- Open Questions & Future Decisions: concurrency policy resolved; deferred: manual revision creation UI/validation, retention policy for superseded revisions.

**record-store-specs.md** – coverage added
Existing REC-001 to REC-006 retained.
New:
- REC-007: When a submission includes a baseRevisionId, the system SHALL store the baseRevisionId with the created revision.
- REC-008: When two or more revisions for the same visit share the same baseRevisionId and no resolution exists, the system SHALL mark the visit reviewStatus as pending.
- REC-009: When a visit has reviewStatus pending, the system SHALL report it as not export-eligible.
- REC-010: When a coordinator resolves review work by selecting an existing revision, the system SHALL set currentRevisionId to the chosen revision and update reviewStatus to resolved.
- REC-011: When retrieving a visit with reviewStatus pending, the system SHALL return the list of competingRevisionIds.

Post-draft consistency:
- Coverage: submission envelope, current state, unresolved work, resolution now have specs.
- Contradiction: none found.
- Scope disambiguation: WHEN clauses name visit-specific context.
- Context-free reading: specs stand alone.

LLD-level edge-case probe – gaps surfaced for triage:
- What happens when baseRevisionId references a revision that does not exist?
- Multiple resolution rounds: new submissions arriving after a partial resolution with a new base.
- Same author submits two competing revisions from same base – treat as competing or collapse?
- Coordinator manual revision creates a new base for subsequent edits – does reviewStatus reset correctly?
- Idempotency key reuse across different visitIds.
- Visit deletion / archival interaction with competing revisions.

Approve the LLD and EARS updates, or provide numbered feedback to adjust the design/spec wording before proceeding to Phase 4 intent-narrowing edge audit?