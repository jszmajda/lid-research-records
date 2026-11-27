**Phase 1 — HLD check**

The HLD still covers this change; no architectural revision was needed. I updated the record-store status row (no longer “concurrency choice open”) and replaced the paragraph that said tablet-sync and review-export must wait on an unresolved choice with a statement of the selected policy. Those two downstream nodes remain unwritten and untouched.

**Phase 2 — Record-store LLD, revised**

`docs/intent/record-store/record-store-design.md` now reads:

---

# Record Store

## Context

The record store owns visit persistence and the meaning of a visit's current state when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Tablet-sync and review-export consume this node's contract. Tablet-sync retains base revision IDs and displays pending competing revisions to field workers. Review-export compares competing revisions and holds unresolved visits out of the partner CSV.

## Architecture

The record store exposes authenticated operations to submit a revision, retrieve a visit's current state, retrieve a visit's history, and resolve unresolved work. Persistence is append-only for revisions and resolutions. A visit holds its identity, a pointer to its current revision, its pending revisions, and its resolution log.

A visit's scientific fields are observation date, observer list, species cover estimates, and notes. Every accepted edit is a complete visit revision rather than a patch to individual fields. The server never combines fields from different revisions. This keeps each worker's submitted visit intact as a unit; even edits to unrelated fields produce competing revisions that a coordinator resolves.

## Submission and Retrieval

Authenticate the submitting worker and validate field types and plot references before accepting a submission. A submission carries:

- The visit UUID.
- The base revision ID from which the worker edited, or null when creating a visit.
- An idempotency key scoped to the submitting worker.
- A complete visit payload: plot ID, observation date, observer list, species cover estimates, and notes.

The server assigns every accepted revision an opaque immutable revision ID and records its author and server receipt time. It preserves the submitted payload exactly; later state changes never overwrite it.

A retry with the same idempotency key and an identical payload returns the original acceptance result. Reusing an accepted key with a different payload is rejected. A submission naming an unknown base revision, or a base revision belonging to another visit, is rejected. Creating a visit with a UUID that already exists is rejected unless the submission is an idempotent retry of the original creation.

Retrieval returns the visit's status, its current revision, and any pending revisions. The current revision is always a complete visit payload with provenance. Pending revisions are the complete competing proposals awaiting review, each with its own provenance. A visit with no pending revisions is resolved. Retrieval never substitutes a combined or partially updated payload for a submitted revision.

## Revision Model

Revisions form a tree rooted at the visit's creation revision. Each revision names the base revision it was derived from, so a revision's ancestry is the path back to the creation revision. A revision derived directly from the current revision advances the current revision; every other accepted revision becomes a pending revision.

A revision is pending when it is a branch head awaiting coordinator resolution. The pending set contains branch heads only: when a submission extends a pending branch, its new revision replaces the previous branch head in the pending set. When a submission extends a revision that is not the current revision—including a revision that a prior resolution set aside—its new revision becomes pending and the visit becomes unresolved again. A submission derived from the current revision does not itself resolve existing pending work.

A visit is resolved when its pending set is empty and unresolved when its pending set is non-empty. The current revision remains the baseline shown for comparison until a coordinator resolves the visit.

## Resolution

A coordinator resolves unresolved work by choosing one complete revision as the visit's current revision. The choice may be the existing current revision or any pending revision; choosing the current revision rejects all pending proposals. The server records an immutable resolution containing the coordinator's identity, the chosen revision, the contributing revision IDs, the server resolution time, and an optional note. It then clears the pending set.

The resolution request carries the pending revision IDs the coordinator reviewed. If the visit's pending set has changed since that review—because a new competing revision arrived—the server rejects the resolution and returns the current pending set. This prevents a coordinator from resolving a stale comparison and leaving an unseen proposal silently set aside. Concurrent resolutions are ordered by the same check: the first resolution clears the pending set, and a later resolution naming the old set is rejected.

Resolutions never delete or rewrite revisions. All original submissions remain retrievable through visit history, including revisions set aside by a resolution.

## History

History returns every revision with its base revision, author, receipt time, and payload, together with every resolution and its outcome. It distinguishes the current revision and any pending revisions from revisions that a resolution set aside. History is sufficient to explain how the current visit state was reached from the original submissions.

## Downstream Contract Work

This node defines the revision envelope, the current-state response, the pending-revision representation, and the resolution operation. Tablet-sync sizes its local storage and retry state machine around the revision envelope and displays pending revisions from the current-state response. Review-export builds its comparison view from the current and pending revisions and excludes visits whose status is unresolved. Both link back to this node rather than inventing their own concurrency semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent visit edits | Whole-visit revisions: each submission is a complete visit derived from a named base revision; competing revisions go to review | Field-aware three-way merge; last-write-wins | Keeps every submitted visit intact as a unit and avoids maintained merge rules that could automatically combine scientifically related edits without noticing. Accepts more review work in exchange for simpler, inspectable conflict handling. |
| Revision identity | Server-assigned immutable revision IDs with an explicit base revision ID | Client-assigned revision IDs; mutable per-visit version counter | Immutable IDs preserve every accepted submission and make branch ancestry explicit without trusting client clocks or counters. |
| Unresolved representation | Visit status plus current revision and pending branch-head revisions | A separate conflict record per field; collapsing conflicts into a single merged record | Complete revisions give review-export and tablet-sync the same payload shape as a resolved visit; no field-level merge state is needed. |
| Resolution concurrency | Resolution must name the pending set the coordinator reviewed; a changed set is rejected | Last-write-wins resolution; locking the visit for the coordinator | Prevents a coordinator from silently setting aside a proposal that arrived after their comparison screen loaded. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrency policy: whole-visit revisions with coordinator resolution.

### Deferred

1. Whether a coordinator may submit a corrected revision after resolving a visit. The ordinary submission operation permits it (the coordinator becomes the revision author); the review-export interface will decide whether to expose it.
2. Whether the record store rejects a new visit against an archived plot. The catalog keeps archived plot references resolvable, but review-export and tablet-sync own the workflow decision about new observations on archived plots.

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
- `docs/intent/record-store/record-store-specs.md`

---

**Edge-case probe — needs your triage**

A blind probe of the LLD surfaced these gaps. I have not silently resolved them. Please say which to fold into the LLD now, and which to defer.

1. A new revision based on the current revision advances the baseline without changing the pending set. A coordinator who reviewed the old baseline could resolve a comparison they never saw. Recommend: the resolution request also names `reviewed_current_revision_id`, and a changed current revision is rejected like a changed pending set.
2. Two edits from the same current revision: the first-arriving becomes current and the second becomes pending, so arrival order chooses the comparison baseline. Is that acceptable because both are still compared, or should the common base remain “current” until resolution?
3. A pending branch head superseded by its own extension is neither current, pending, nor “set aside by a resolution.” Recommend naming that state in History (superseded by a later revision on its branch).
4. The resolution request never names the chosen revision field. Recommend: `chosen_revision_id` must be the current revision or one of the reviewed pending IDs.
5. Resolution retries have no idempotency key; a retry after success looks identical to losing a race. Recommend adding a resolution idempotency key.
6. A never-contested visit is labeled “resolved,” which may read as adjudicated. Recommend defining status as “unresolved work exists / does not exist,” or renaming the values.
7. The exact-match rule for the reviewed pending set is unstated (omitted IDs, extra IDs, empty set, already-resolved visit). Recommend: exact equality, with a distinct error for an already-clear visit.
8. Error response shapes for unknown visit/revision, duplicate creation, idempotency conflict, and stale review are unspecified. Recommend a small named error set in this LLD so tablet-sync and review-export can build against it.

**Decision-doc offer**

The whole-visit-versus-merge choice is likely to be re-litigated by a cold reader, and tablet-sync and review-export are about to be sized around it. Would you like me to record it as a full decision doc under `docs/intent/record-store/decisions/`, or keep the Decisions & Alternatives row only?

Please approve or amend the LLD and answer the probe triage and the decision-doc question. I will then draft the Phase 3 EARS updates; I have not touched tablet-sync or review-export.