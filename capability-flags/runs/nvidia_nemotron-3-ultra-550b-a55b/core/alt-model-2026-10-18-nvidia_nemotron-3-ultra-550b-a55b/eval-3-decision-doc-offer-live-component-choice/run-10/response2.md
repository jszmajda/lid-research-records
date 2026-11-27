---

**Phase 3 Stop — EARS Specs Review**

I've updated `docs/intent/record-store/record-store-specs.md` with 18 specs covering:

**Implemented (carried forward):**
- REC-001–006: Core submission retention, idempotency, conflict preservation, unresolved indication, resolution tracking

**New specs for whole-visit revisions:**
- REC-007: Conflict rejection when base_revision ≠ current revision
- REC-008: Unresolved marking when competing submissions share base_revision
- REC-009: Retrieval returns competing submissions for unresolved visits
- REC-010–011: Resolution via submission selection or manual merge
- REC-012: New visit creation (revision 1, resolved)
- REC-013: Rejection of stale base_revisions
- REC-014–015: Validation (plot existence, cover 0–100)
- REC-016: Revision increments by exactly 1
- REC-017: Unresolved visits excluded from export
- REC-018: Full submission history query

**Consistency check:**
- Coverage: All LLD behaviors (submission envelope, current-state response, unresolved representation, resolution operation, validation, export eligibility, provenance) have corresponding specs
- No contradictions detected
- Scopes explicit (all specs name their trigger condition)
- Context-free: each spec line stands alone without relying on section headers

Please review the specs and confirm to proceed to Phase 4 (intent-narrowing edge audit).