Phase 1 — HLD check complete. The HLD remains coherent with whole-visit revisions; concurrency is a record-store responsibility and no architectural change is required.

Phase 2 — LLD updated: `docs/intent/record-store/record-store-design.md`
- Concurrency policy finalized as Whole-Visit Revisions.
- Submission envelope defined: visitId, baseRevisionId, payload, authorId, idempotencyKey, clientTimestamp; server assigns revisionId and serverReceiptTime.
- Revision model: single resolvedRevisionId per visit, pending when baseRevisionId ≠ resolvedRevisionId.
- Retrieval returns resolved payload + pending revision list with author/receipt/base linkage.
- Resolution `POST /visits/{visitId}/resolve` updates resolvedRevisionId, records coordinatorId, resolutionTimestamp and superseded IDs; retains all submissions.
- Downstream contracts for tablet-sync and review-export noted.
- Decisions & Alternatives table records the whole-visit choice vs field-aware three-way merge.
- Edge-case probe added:
  * submission with non-existent baseRevisionId
  * multiple pending revisions sharing same base
  * resolving to a revision whose base was later superseded
  * visit with no resolved revision and divergent bases
  * idempotency retry after resolution

Phase 3 — EARS specs updated: `docs/intent/record-store/record-store-specs.md`
Added:
- REC-007: store baseRevisionId with submission
- REC-008: mark revision pending when baseRevisionId differs from current resolvedRevisionId
- REC-009: resolution updates resolvedRevisionId and records timestamp/coordinatorId
- REC-010: retrieval includes pending revision IDs, author IDs, receipt times, baseRevisionIds

Post-draft consistency:
- Coverage: LLD submission envelope, revision model, retrieval and resolution are now spec-backed.
- Contradiction: none found.
- Implicit scope: REC-008 pending rule is ambiguous when resolvedRevisionId is null for first submissions; REC-005 and REC-010 overlap on unresolved indication.

Phase 4 — Intent-narrowing edge audit
Divergence risks to resolve before tests:
1. Null handling: Should a first submission with baseRevisionId = null be considered pending when resolvedRevisionId is null, or should it auto-resolve? The current wording admits both readings.
2. Pending definition after resolution: If a coordinator resolves to revision R, submissions based on a base earlier than R remain pending per REC-008. Do you want to keep them pending indefinitely or auto-close superseded branches?
3. BaseRevisionId validation: Should the server reject submissions whose baseRevisionId does not exist for the visit, or accept and treat as pending?

Please review the LLD and specs above and confirm:
- the null/baseRevisionId semantics you want,
- acceptance or rejection of non-existent base revisions,
- and whether the pending lifecycle after resolution is acceptable.

Once approved, I will lock the specs and proceed to Phase 5 tests-first for record-store.
