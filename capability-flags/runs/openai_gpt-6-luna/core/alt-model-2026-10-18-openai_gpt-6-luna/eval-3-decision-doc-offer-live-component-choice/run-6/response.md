## Phase 2 — Record-store LLD draft

I updated `docs/intent/record-store/record-store-design.md` for whole-visit revisions, and updated the record-store status and dependency wording in `docs/high-level-design.md`. The LLD now defines immutable revision history, base revision IDs, stale-edit review state, retrieval, and downstream contract obligations.

### `docs/intent/record-store/record-store-design.md`

---
parent: high-level-design  
prefix: REC  
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. Arrival order does not establish which worker's observations are more authoritative.

Tablet-sync and review-export consume this node's submission and review-state contract. Tablet-sync needs to retain the revision on which an edit was based. Review-export needs to recognize unresolved visits and keep them out of the partner CSV. Those components are designed separately.

## Architecture

The record store accepts authenticated complete-visit submissions, validates and retains them, exposes current and historical revisions, and records coordinator resolutions. A revision is an immutable complete visit payload plus its provenance. Review resolution changes which revision is current; it does not rewrite or delete submitted revisions.

Each accepted submission has a server-assigned revision ID, visit ID, optional base revision ID, submitting author ID, server receipt time, idempotency key, and the complete visit payload. The payload includes the plot reference, observation date, observer list, species cover estimates, and notes. A null base revision ID is used to create a visit. An edit names the revision from which the worker made the complete replacement payload.

Acceptance is atomic per visit: validation, idempotency handling, revision persistence, and current/review-state updates produce one result. A base revision must exist and belong to the submitted visit. Invalid plot references and invalid field types are rejected before a revision is accepted. Accepted revision history remains available regardless of whether a revision is current, competing, or superseded by review.

## Whole-Visit Revision State

Each visit has a current revision when it has a usable, resolved state. It may also have unresolved review work containing the complete revisions that need coordinator consideration. The current pointer is not advanced by a submission that creates or joins unresolved review work.

| Submission condition | Resulting state |
|---|---|
| First submission for a visit has no base revision | Accept as the initial current revision. |
| No review is pending and the submitted base equals the current revision | Accept the complete revision and advance the current pointer to it. |
| The submitted base differs from the current revision, or review is already pending | Accept and retain the complete revision; mark the visit unresolved and leave the current pointer unchanged. Include the current revision and accepted competing revisions in the review set. |

All accepted edits based on an outdated revision require review, including edits to apparently unrelated fields. The record store does not infer whether edits are scientifically independent and does not combine fields automatically. A retry using the same accepted idempotency key and identical payload returns the original acceptance result; reuse of that key with a different payload is rejected without changing the accepted revision.

## Submission and Retrieval

Submission requires an authenticated worker, a visit ID, a base revision ID for edits (or no base for initial creation), a complete visit payload, and an idempotency key. The server assigns the revision ID and receipt time. An accepted response identifies the revision and reports whether the visit now has unresolved review work.

Retrieval returns the current complete revision when one exists, its revision ID, and an explicit unresolved-review indicator. When review is pending, retrieval also identifies the complete revisions in the review set; callers can retrieve each full payload and its author, receipt time, and base revision ID. Submission-history retrieval includes every accepted revision for the visit and any recorded resolution that changes the current pointer.

The record store exposes review status but does not decide CSV formatting or export execution. The review-export component must exclude a visit from export while its review status is unresolved.

## Review Resolution

A coordinator resolution records the coordinator identity, the revision IDs considered, the selected whole revision, and the resolution time. It changes the current pointer to the selected complete revision, clears the unresolved-review state for that review set, and preserves every competing revision and the resolution record in history. It does not synthesize a field-level merge. The current contract selects one submitted revision; whether a coordinator may instead author a new complete revision remains open.

## Downstream Contract Obligations

- Tablet-sync must submit the base revision ID associated with its local edit and retain the server-assigned revision ID returned for an accepted submission. It must be able to explain that an accepted submission is awaiting review.
- Review-export must compare complete revisions, make unresolved review work visible to coordinators, and exclude unresolved visits from the partner CSV.
- Neither downstream component may replace the record store's revision history or infer a different concurrency outcome.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Reconcile independent edits to one visit | Whole-visit revisions; stale-base submissions remain intact and require coordinator resolution | Field-aware three-way merge of disjoint edits with review for overlaps | The team accepts a larger review queue rather than maintaining merge rules that could combine scientifically related edits without recognizing their relationship. Whole submissions and their provenance remain directly inspectable. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Use whole-visit revisions and send stale-base edits to coordinator review rather than merging fields automatically.
2. ✅ Keep every accepted submitted revision and its provenance after review resolution.

### Deferred

1. Define review-set concurrency so submissions arriving during coordinator resolution cannot be omitted from review; consider rejecting resolution against an outdated review-set version.
2. Confirm whether resolution must select one submitted revision, or may create a new complete coordinator-authored revision.
3. Confirm that submissions based on the still-current revision join the review set while another branch is unresolved, as the state table currently specifies.
4. Define behavior for a second initial submission with no base revision after the visit ID already exists.
5. Define idempotency-key uniqueness and retention scope across workers and visits.

## References

- `docs/high-level-design.md`
- `docs/intent/record-store/record-store-specs.md`

### LLD edge-case probe

Please triage these gaps—say which should be fixed in the LLD now and which can remain deferred:

1. If a submission arrives while a coordinator is resolving a review set, should resolution against an outdated set be rejected so the new submission cannot be missed?
2. Must a coordinator choose a submitted revision, or may they author a new complete revision?
3. Should an edit based on the still-current revision join an already-open review set, as the draft specifies?
4. What should happen when a second initial submission arrives without a base revision for an existing visit ID?
5. What scope and retention period should apply to idempotency keys?

The LLD records the selected concurrency tradeoff in its Decisions & Alternatives table. Would you like a standalone decision document for that choice, or is the table row sufficient?

`git diff --check` passed. Please review the draft and triage the questions above.