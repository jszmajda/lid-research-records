## Phase 2 — Record-store LLD for review

I updated `docs/intent/record-store/record-store-design.md` to specify whole-visit revisions, competing submissions, retrieval, and coordinator resolution. I also updated `docs/high-level-design.md` to reflect the selected policy and remove its now-stale “choice open” wording.

### `docs/intent/record-store/record-store-design.md`

---
parent: high-level-design  
prefix: REC  
---

# Record Store

## Context

The record store owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a stable catalog plot UUID. Tablets can submit edits days after the worker started from a previously retrieved revision. Submission arrival order does not establish which worker's observations are more authoritative.

The store preserves whole-visit revisions. A submitted visit is an indivisible scientific record; the server does not automatically combine fields from competing edits. This avoids silently combining edits whose scientific relationship cannot be inferred from field names. Competing revisions remain available for coordinator review.

## Visit and Revision Model

Each visit has a stable visit UUID, a plot UUID, a current revision ID, and zero or one open review case with a server-generated case ID. A revision is an immutable complete visit payload containing observation date, observer names, species cover estimates, and notes. The plot UUID is retained as the historical reference even if the catalog later archives the plot.

Every worker-submitted revision records:

- a server-generated revision ID;
- the visit UUID and complete submitted payload;
- the base revision ID from which the worker edited, absent only for the initial visit revision;
- the authenticated author's ID and server receipt time;
- the accepted submission's idempotency key.

The revision's base ID records its ancestry, not an instruction to merge its contents with the base. Original submissions and accepted revision payloads are immutable. Rejected requests do not create revisions.

A coordinator-created revision records the adjudicated payload, the resolution ID that created it, the coordinator's identity, and the resolution time; it has no worker submission or idempotency key.

## Submission and Current Revision

The submission operation accepts a complete visit payload, visit UUID, base revision ID (absent only when creating a visit), and idempotency key. The server authenticates the worker and validates field types, required values, and the plot reference before accepting the submission. Idempotency keys are scoped to the authenticated worker. Repeating an accepted key with the identical request returns its original result; reusing it with different request content is rejected.

For a new visit, the first valid request without a base revision creates its initial revision and current state. A request to create an already existing visit, or to edit a nonexistent visit, is rejected. For an existing visit, the base revision must belong to that visit.

When a valid edit is based on the current revision and the visit has no open review case, the store accepts the full payload as a new revision and makes it current. When an edit is based on any other revision, the store accepts and retains it as a competing complete revision, leaves the current revision unchanged, and opens or extends review work for that visit. It never replaces the current revision merely because a competing submission arrived later. Each additional competing submission is retained as a separate revision; the store does not deduplicate by payload content or merge fields.

An open review case makes the visit unresolved until a coordinator records a resolution. The current revision remains retrievable as the last non-competing state, but callers must also be told that competing revisions await review. A new submission received while review is open is retained as competing review work, including one based on the current revision, so it cannot implicitly clear or bypass the existing review.

Submission acceptance and comparison with the current revision/open-review state are atomic per visit. If a submission and a resolution race, the store serializes them: a submission accepted before resolution is included in that resolution's review set; one accepted after resolution is evaluated against the resulting current revision and review state.

## Retrieval and Resolution

Visit retrieval returns the current complete revision and explicitly indicates whether unresolved review work exists. Review retrieval returns the open case ID, current revision, and every competing revision in the case, with each revision's author, receipt time, base revision ID, and complete payload. The current revision is included among the complete revisions a coordinator may select when resolving the case. The record store supplies these values; presentation and export eligibility are owned by review-export.

A coordinator resolves an open review case by its case ID, either selecting the current revision or one of its competing complete revisions, or recording an adjudicated complete visit payload. Resolution is atomic and records the coordinator's identity, resolution time, all competing revision IDs considered, and the selected revision or newly created resolution revision. Selecting an existing revision makes it current without altering its submission. An adjudicated payload creates a new immutable revision attributed to the coordinator and linked to the resolution. The resolution closes the review case; unselected submissions remain in history and are not deleted. A later stale submission can open a new review case with a new case ID.

The store retains revision and resolution history so a current value can be traced to its submitted or adjudicated source. It does not decide scientific correctness, infer relationships between fields, or determine the user interface for reviewing alternatives.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent edits to one visit | Preserve each submission as a whole-visit revision; retain competing revisions for coordinator resolution | Field-aware three-way merge that combines disjoint changes and reviews overlapping changes | The team accepts a larger review queue to avoid maintaining merge rules that can combine scientifically related edits without recognizing their relationship. Whole-visit revisions preserve each worker's submitted record as a unit and keep the path from submission to resolved value inspectable. |

## Open Questions & Future Decisions

### Resolved

1. Concurrent edits use whole-visit revisions and are not automatically field-merged.

### Deferred

1. Define submit, retrieval, and resolution authorization rules and the exact error responses for invalid fields, missing visits, duplicate visit IDs, missing or cross-visit base revisions, and closed or mismatched review-case IDs.
2. Specify how idempotency behaves for simultaneous duplicate requests, key reuse after a rejected request, and a retry after the visit has since changed or been resolved; define which request fields determine an identical retry.
3. Decide how simultaneous initial creation requests for one visit UUID are handled, including whether identical payloads from different workers can share an accepted creation result.
4. Decide whether archived plots may be used for new visits or edits, and what happens if catalog status changes during submission.
5. Specify whether retrieval returns a consistent snapshot when a submission or resolution races it, and how a coordinator's review set is fixed when submissions arrive during review.
6. Specify resolution eligibility and invariants, including whether an adjudicated payload may change the plot UUID and how concurrent or repeated resolutions are rejected.

## References

- [High-Level Design](../../high-level-design.md)
- [Record Store EARS](record-store-specs.md)
- [Site Catalog Design](../site-catalog/site-catalog-design.md)

### Edge-case probe

The LLD-level probe identified these items for your judgment; they are recorded as deferred questions in the design:

- What authorization and error behavior should apply to invalid submissions, missing or mismatched revisions, and invalid or closed review cases?
- How should idempotency handle simultaneous requests, retries after rejection, and retries after a visit changes?
- What happens when multiple workers create the same visit UUID concurrently?
- May archived plots be used for new visits or edits, and what if catalog status changes during submission?
- Must retrieval return a consistent snapshot while submissions or resolutions race it?
- What resolution invariants apply to the plot UUID, and how are concurrent or repeated resolutions handled?

Please also check these specified behaviors: while a review case is open, every new edit becomes competing work—even if based on the current revision; the coordinator may select the current revision or a competing revision; and revisions are not deduplicated by payload content. Are those rules right for this record store, and which deferred questions should be resolved now versus left open?

### Coherence check

The HLD and LLD agree on whole-visit revisions and leave tablet-sync and review-export to consume the record-store contract. Existing REC-001–REC-006 broadly cover retained submissions, idempotency, competing edits, unresolved status, and resolution attribution. They will need Phase 3 updates for the new revision and resolution behavior. I also found a precision mismatch to resolve then: REC-002/003 say “identical/different payload,” while the LLD currently says “identical/different request content.” `git diff --check` passes; no tests were run for this documentation-only phase.

Please review the LLD and the questions above. Tell me any changes, which questions to settle or defer, and whether you approve this phase so I can proceed to the EARS update.