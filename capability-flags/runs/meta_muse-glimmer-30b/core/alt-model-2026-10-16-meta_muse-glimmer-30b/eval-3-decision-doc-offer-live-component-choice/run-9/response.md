Record-store design is updated for whole-visit revisions.

**Phase 1 – HLD check**
- HLD exists at `docs/high-level-design.md` and covers the domain. Record-store concurrency remains an LLD-level choice. Coherence pre-flight: HLD → LLD → EARS trace is intact; no drift found.

**Phase 2 – LLD**
`docs/intent/record-store/record-store-design.md` rewritten as a fresh author doc with whole-visit revisions selected.

Key changes:
- Submission envelope now requires `visit_id`, `base_revision_id` (nullable for first submission), full `payload`, `author_id`, `idempotency_key`, `client_timestamp`.
- Current state is the `resolved_revision_id` payload only. Pending revisions are stored separately and never auto-advance.
- Unresolved work = one or more pending revisions; submission-history returns the revision graph for comparison.
- Resolution operation records coordinator identity, chosen `revision_id`, and superseded submission IDs.
- Decisions & Alternatives table records the whole-visit choice over field-aware three-way merge with rationale.
- Open Questions & Future Decisions keeps retention policy and fan-out alerting deferred.

**Phase 2 edge-case probe**
Gaps surfaced for your triage:
- Submission with `base_revision_id` that does not exist for the visit.
- Submission whose base is a pending revision, not the resolved revision.
- First submission arriving with non-null `base_revision_id`.
- Concurrent coordinator resolutions on the same visit.
- Resolve to a revision that itself has children pending revisions.
- Idempotency key reuse across different visits.
- Payload validation failure after idempotency acceptance.

**Phase 3 – EARS**
`docs/intent/record-store/record-store-specs.md` updated. Existing REC-001 to REC-006 retained, added:
- REC-007: store `base_revision_id` with the revision.
- REC-008: accepted submissions for a visit with an existing resolved revision are stored as pending and do not change resolved.
- REC-009: retrieval returns resolved revision payload only, no pending incorporation.
- REC-010: coordinator resolution updates `resolved_revision_id` to selected revision.
- REC-011: first accepted submission becomes resolved when no resolved revision exists.
- REC-012: submission referencing unknown base revision is rejected.

Post-draft consistency:
- Coverage: submission envelope, current state, pending, resolution are covered. Validation of field types/plot references is described in LLD but not yet a spec.
- Contradiction: none found.
- Implicit scoping: REC-008 now explicitly scopes to “visit with existing resolved_revision_id”.
- Context-free reading: specs stand alone.

**Phase 4 – Intent-narrowing edge audit**
Divergence points needing your resolution before tests:
1. REC-008 says all submissions after first are pending. Do you want any linear auto-advance case, e.g., when no other pending revisions exist and base matches resolved, or keep strict manual review for every edit?
2. When a coordinator resolves to a revision, what happens to other pending revisions that descend from the same parent? Keep them pending against the new resolved revision, or close them?
3. REC-011 makes first submission resolved. Should a first submission with non-null `base_revision_id` be rejected, or allowed and treated as first?
4. Validation failure handling: should idempotency acceptance be atomic with validation, or accept key first then validate?

Please confirm the intended handling for 1-4, and whether you want a spec added for field-type/plot-reference validation on submission. Once confirmed, I will finalize the LLD open questions and proceed to tests-first for this segment.
