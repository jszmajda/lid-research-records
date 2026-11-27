## Phase 2 — Record-store design ready for review

Updated:

- `docs/intent/record-store/record-store-design.md`
- `docs/high-level-design.md`

The design now specifies:

- Immutable, complete visit revisions with base-revision lineage.
- **Settled** visits with one current revision and **contested** visits with no current revision.
- Atomic submissions that never combine fields or discard competing edits.
- Additional edits joining an open conflict rather than replacing candidates.
- Coordinator resolution by selecting one complete candidate.
- Conflict versions preventing review from closing over newly arrived edits.
- Submission and resolution idempotency, current-state retrieval, and full revision history.

Tablet-sync and review/export remain outside this change.

### Edge-case probe

No direct contradictions were found. The probe identified these gaps for your triage:

1. **Submission/resolution race:** Should all submissions and resolutions share one per-visit serialization order?
2. **Resolution after closure:** Should a second, non-idempotent resolution return a conflict-closed error with the winning revision, or the closed conflict and resolution?
3. **Idempotency scope:** Should cross-author key reuse be rejected, and should submission and resolution keys use separate namespaces?
4. **Error contract:** Should rejected operations have machine-readable codes and structured details? Which failures should return current visit/conflict state?
5. **Payload validation:** Should record-store validate only structure and plot references, or also scientific invariants such as observer requiredness, duplicate species, and cover ranges?
6. **Identical retries:** Should idempotency compare canonical semantic content rather than raw serialized bytes?
7. **Deterministic metadata:** Should conflict versions start at 1, candidates use receipt order, and history use a deterministic tie-breaker for equal timestamps?
8. **Replayed responses:** Should idempotent retries return the original frozen acceptance response even after the conflict has advanced?

Please indicate which gaps to settle now versus defer, and approve or request changes to the LLD. I’ll update the EARS specs after that review.

This concurrency choice also qualifies for a standalone decision document because it trades review workload against scientific-merge risk and shapes both downstream components. Would you like one, or is the LLD Decisions & Alternatives row sufficient?