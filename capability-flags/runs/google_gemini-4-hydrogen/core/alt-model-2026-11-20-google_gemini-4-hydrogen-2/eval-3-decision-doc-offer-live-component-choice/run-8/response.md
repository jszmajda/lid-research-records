I have updated `docs/intent/record-store/record-store-design.md` around **whole-visit revisions** (Phase 2 — LLD). Downstream cascades to `tablet-sync` and `review-export` are recorded as contract obligations and paused at the segment boundary.

### Summary of `record-store-design.md`
- **Revision Model & Visit States**: Distinguishes immutable `submission` records from immutable `revision` snapshots. Each visit tracks `currentRevisionId`, `reviewStatus` (`clean` | `needs_review`), and `pendingRevisions`.
- **State Transitions**: Covers initial creation (`baseRevisionId: null`), fast-forward edit (`baseRevisionId == currentRevisionId && reviewStatus == clean`), concurrent edit (preserves submission, appends to `pendingRevisions`, sets `needs_review` without advancing `currentRevisionId`), coordinator resolution (creates a superseding revision citing `currentRevisionId` and all resolved `pendingRevisions`, clears `pendingRevisions`, returns to `clean`), and invalid `baseRevisionId` rejection.
- **Contracts**: Defines worker-scoped `(authorId, idempotencyKey)` deduplication and five operations (`Submit visit edit`, `Get visit`, `Get visit history`, `List review queue`, `Resolve visit`).
- **Decisions & Alternatives**: Records whole-visit revisions vs. field-aware three-way merge, holding `currentRevisionId` during `needs_review`, and superseding resolution lineage.

---

### Decision Doc Offer
Because the **whole-visit revisions vs. field-aware three-way merge** choice trades competing criteria (review queue size vs. merge-rule maintenance and preservation of coupled scientific edits) and both `tablet-sync` and `review-export` will be sized around it, would you like me to record it as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD), or leave it as the row in `Decisions & Alternatives`?

---

### LLD-Level Edge-Case Probe (for Triage)
A blind probe of `docs/intent/record-store/record-store-design.md` surfaced these internal gaps. Please indicate which to fix in the LLD now vs. defer:

1. **Plot immutability**: What happens when a submission for an existing `visitId` specifies a different `plotId` than the visit's current revision?
2. **Write serialization**: What concurrency control (locking/optimistic check) prevents two concurrent fast-forward edits or an edit + resolution from both advancing `currentRevisionId`?
3. **Concurrent initial creations**: What happens when two `baseRevisionId: null` submissions for the same `visitId` arrive concurrently with different idempotency keys?
4. **Stale `basePendingRevisionIds[]` on resolve**: What happens when a new competing revision arrives after a coordinator fetches the visit and submits `Resolve visit`?
5. **Invalid `Resolve visit` states**: What happens when `Resolve visit` is called on a `clean` visit, an unknown `visitId`, or concurrently by two coordinators?
6. **Resolution payload rules**: What are the precedence/exclusivity and validation rules between `resolvedPayload` and `selectedRevisionId?` in `Resolve visit`?
7. **Resolution retry safety**: Should `Resolve visit` also carry an `idempotencyKey` for transient failure retries?
8. **Idempotency scope**: Are rejected submissions cached under `(authorId, idempotencyKey)`, and are `visitId`, `plotId`, and `baseRevisionId` included in the payload-equivalence check?
9. **In-flight idempotency races**: How are two concurrent requests with the same `(authorId, idempotencyKey)` serialized before the first commits?
10. **Role-based authorization**: Are workers barred from `Resolve visit`, and how are auth/permission failures represented?
11. **Error shapes & empty states**: What error codes/shapes do operations return on rejection/not-found, and is `pendingRevisions` `[]` or omitted when `clean`?
12. **Payload domain invariants**: Beyond type checks, what domain bounds/requiredness apply to `observationDate`, `observers`, `speciesCover`, `notes`, and unknown fields?
13. **Ordering & pagination**: What sort keys govern `pendingRevisions`, `Get visit history` arrays, and `List review queue` (and cursor stability as visits enter/leave `needs_review`)?
14. **Revision provenance fields**: Should `sourceSubmissionId` and `resolutionId` on a `revision` be explicitly marked mutually exclusive/nullable?

---

**Phase 2 Stop:** Let me know:
1. Whether you want the decision doc created or kept as the table row.
2. Which of the 14 probe gaps to address in `record-store-design.md` vs. defer.
3. Whether you approve moving to **Phase 3** (updating `record-store-specs.md`) once those are settled.