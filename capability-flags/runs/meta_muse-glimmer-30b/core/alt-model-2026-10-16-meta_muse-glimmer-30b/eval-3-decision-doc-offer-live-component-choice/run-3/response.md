Phase 1 — HLD check

HLD at docs/high-level-design.md covers the domain and correctly delegates the concurrency mechanism to record-store. No HLD change required.

Coherence pre-flight passed: HLD → LLD → EARS are mutually coherent for the record-store segment; no tests exist yet.

Phase 2 — LLD updated

record-store-design.md is updated with whole-visit revisions selected.

Key additions:
* Concurrency Policy: Whole-visit Revisions — each edit names its starting revision, competing complete revisions are created for coordinator resolution. Tablets retain base revision IDs; review/export needs revision comparison and holds unresolved visits out of CSV.
* Submission Envelope: visit_id, base_revision_id, payload, idempotency_key, author_id, client_timestamp
* Current State Retrieval returns current_revision_id, current_payload, unresolved flag, base_revision_id
* Unresolved Work Representation: revisions sharing same base_revision_id with no resolution → visit unresolved
* Resolution Operation records resolving_coordinator_id, chosen_revision_id, resolution_timestamp, optional note; original submissions preserved
* Decisions & Alternatives table records the choice and rationale
* Open Questions & Future Decisions moved; concurrency policy resolved, manual merged revision option deferred

Phase 2 edge-case probe — LLD-level gaps surfaced for your triage:
* What happens when a submission references a non-existent base_revision_id?
* Three or more competing revisions to the same base — representation and UI scaling
* Submission arrives for a base_revision_id that is already resolved — accept as new branch or reject?
* Concurrent resolution attempts by two coordinators
* Initial creation with base_revision_id null when a visit already exists
* Idempotency key reuse after a resolution creates a new revision chain
* History retrieval after resolution — should resolved chain be pruned or kept fully inspectable?
* Whether coordinators should be allowed to create a manual merged revision instead of selecting one existing revision

Phase 3 — EARS specs updated

docs/intent/record-store/record-store-specs.md now contains:

- REC-001 to REC-006 unchanged
- REC-007: When a submission includes a base_revision_id, the system SHALL store the submission as a new revision linked to that base revision.
- REC-008: When two or more revisions share the same base_revision_id and no resolution exists, the system SHALL mark the visit as unresolved.
- REC-009: When a coordinator resolves an unresolved visit, the system SHALL set current_revision_id to the chosen revision and record the resolving coordinator identity and resolution timestamp.
- REC-010: When a visit is unresolved, the system SHALL return unresolved=true and current_payload null on retrieval.
- REC-011: When a submission references a base_revision_id that differs from the current revision, the system SHALL accept it as a competing revision.
- REC-012: When a submission is for initial creation with base_revision_id null, the system SHALL create the first revision and set it as current if no competing revisions exist.

Phase 3 consistency verification:
* Coverage: submission envelope, current state, unresolved representation, and resolution are covered by specs.
* Contradiction: none found.
* Implicit scoping: specs name the whole-visit revisions context explicitly via base_revision_id and unresolved conditions.
* Context-free reading: each spec is self-contained.

Stop for review. Please confirm:
1. The whole-visit revisions LLD and Decisions & Alternatives record are correct
2. Which of the edge-case probe items you want addressed in the LLD now vs deferred
3. Approval to proceed to Phase 4 Intent-narrowing edge audit for cross-spec composition

Once approved, I will run Phase 4 before any tests-first work.
