Recorded **whole-visit revisions** in `docs/intent/record-store/record-store-design.md`, including your rationale: preserving scientific relationships is worth the larger review queue.

The record-store design draft is below. Its edge-case probe found a few decisions that need your judgment before I can finalize the contract and expand the requirements.

<details>
<summary>Full record-store design draft</summary>

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. Arrival order does not establish scientific authority.

Whole-visit revisions preserve each submitted visit as a unit. Independent corrections become competing complete revisions for coordinator review, even when their changed fields appear unrelated. Scientific relationships between species identification, cover estimates, and notes need not be expressible as merge rules.

## Architecture

The record store exposes authenticated submission, current-state retrieval, revision-history retrieval, unresolved-work retrieval, and coordinator resolution operations.

Original submissions are immutable. Each revision contains:

- A complete visit payload.
- A server-assigned revision ID.
- Its base revision ID.
- The authenticated author ID.
- Server receipt time.

The payload contains the plot UUID, observation date, observer list, species cover estimates, and notes. Original payloads remain separate from resolution metadata. The catalog supplies stable plot references, including archived references for historical visits.

Persistence commits the revision, idempotency result, and visit-state change atomically. Concurrent submissions for one visit are serialized for base comparison so two edits based on the same revision cannot both become an uncontested successor.

## Submission Contract

| Input | Meaning |
|---|---|
| `visitId` | Client-generated UUID identifying the visit |
| `idempotencyKey` | Retry identity scoped to the authenticated author and visit |
| `baseRevisionId` | Stored revision from which the submitted visit was edited; null for initial creation |
| `payload` | Complete visit values, including the catalog plot UUID |

The store authenticates the worker and validates field types, the plot reference, and base ownership before acceptance. An unknown base or a base belonging to another visit is an error. Authentication and validation failures return a reason without changing stored visit state. An archived plot remains resolvable for historical corrections.

For a new visit, the first valid submission has a null base and establishes its current revision. For a visit without unresolved work:

- A submission based on its current revision becomes its complete successor.
- A submission based on a retained older revision is preserved as a competing revision and opens review work.

Fields are never automatically combined.

Acceptance returns the stored revision ID and the visit’s review state at acceptance. An identical retry returns that original result, even if the visit subsequently changed. Identity comparison includes the base revision ID and complete payload. Reuse of the key with different content is rejected. Current-state retrieval supplies subsequent changes.

## Current State and Review Work

Current-state retrieval distinguishes an uncontested complete revision from a visit with unresolved review work.

A conflicted response exposes the retained current revision and competing revision IDs, with an explicit unresolved flag. The retained current revision is not an export-ready outcome.

History retrieval supplies complete immutable payloads, base links, authors, receipt times, and resolution records for comparison.

Unresolved-work retrieval identifies the visit, revisions requiring review, and a review-state token. The token changes when work changes. A resolution names the state the coordinator reviewed, so a new submission or another coordinator’s resolution cannot be silently omitted. A stale resolution request returns a changed-state error and leaves the newer state intact.

## Resolution Contract

Only an authenticated coordinator can resolve work.

A successful resolution retains the coordinator ID, server receipt time, contributing submission IDs, and the complete resulting visit. All original submissions remain available.

Resolution atomically establishes the current outcome and closes the work covered by the reviewed state. The allowed outcome forms remain an open decision below.

## Decisions & Alternatives

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions with explicit coordinator review | Field-aware three-way merge | A larger review queue is preferable to maintaining merge rules that can combine scientifically related edits without recognizing their relationship. Complete submissions preserve whole-visit intent and make review explainable. |
| Submission representation | Complete payload plus base revision ID | Base snapshots plus structured changes | Whole-visit comparison requires an identifiable starting revision and preserves the submitted visit without a maintained field-merge model. |

## Open Questions & Future Decisions

1. **Resolution outcome:** Can coordinators only select an existing complete revision, or also author a corrected complete revision with contributing submission links?
2. **Submissions during unresolved review:** How do corrections to a competing revision replace or extend its pending work, and which revisions must the coordinator explicitly disposition?
3. **Repeated creation:** Is a second null-base submission with a new idempotency key retained as competing work, or rejected until the tablet fetches a base?
4. **Validation limits:** Confirm required fields, cover-estimate bounds, and permissible changes to a visit’s plot reference.
5. **Resolution identity and retry:** Define the revision ID used for future edits and recovery after a lost resolution response.
6. **Resolution ordering:** Define serialization of the review-token check and resolution commit with incoming submissions.
7. **Retry equivalence:** Define equality for differently encoded JSON and retry lookup ordering when validation rules or catalog state change.
8. **Error contract:** Define machine-readable results for an unknown visit, invalid base, reused key, insufficient authority, stale review state, and resolution without open work.

## Downstream Obligations

**Tablet-sync:** Retain base revision IDs, submit complete payloads, distinguish acceptance from a resolved current state, and fetch current state after retries when necessary.

**Review-export:** Provide complete-revision comparison, resolve against a reviewed-state token, and exclude unresolved visits from the CSV. Record-store supplies conflict state; review-export owns presentation and export execution.

These obligations are recorded here for later design of the sibling nodes. Their interfaces and workflows require separate review before propagation.

## References

- `docs/high-level-design.md`
- `docs/intent/record-store/record-store-specs.md`
- `docs/intent/site-catalog/site-catalog-design.md`

</details>

### Review needed

The most consequential remaining choice is **what coordinators can produce**:

- **Select an existing revision only:** simpler review and direct provenance, but reconciling evidence from several submissions requires a separate correction.
- **Select or author a corrected complete revision:** permits a deliberate reconciliation with linked sources, but adds editing and validation responsibilities to review.

Which do you prefer? Please also triage the other open questions: which should we settle now, and which may remain explicitly deferred?

This concurrency choice is substantial enough to merit a standalone decision document for future maintainers. Would you like one, or is the rationale table sufficient?

The HLD and site-catalog still describe the concurrency choice as pending. May I update those references to point to this contract as part of approval?

`git diff --check` passed. This is the required record-store design review stop.