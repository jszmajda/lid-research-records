## Phase 2 — Record-store LLD

Updated `docs/intent/record-store/record-store-design.md`:

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. Arrival order is not evidence that one worker's observations are more authoritative than another's.

The store uses whole-visit revisions. Every accepted submission is an immutable, complete representation of the visit's scientific fields. An edit either advances the current revision directly or joins a competing-revision review; the store never combines fields from different submissions. This accepts more coordinator work in exchange for preserving each worker's scientific judgment as a coherent unit and avoiding merge rules that could overlook relationships between species identifications, cover estimates, observers, and notes.

Tablet-sync and review-export consume the contracts defined here. They must not introduce their own concurrency semantics.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, competing-revision retrieval, and review-resolution operations. Persistence retains original submissions, their authors, server receipt times, revision relationships, and resolution decisions.

A visit has one current revision and may have one open revision review. The current revision remains available while review is open, but the visit is unresolved and therefore ineligible for reviewed export. Submission acceptance and changes to the current revision or open review occur in one transaction so concurrent requests cannot both advance the same current revision unnoticed.

### Revision identity and ancestry

- `visitId` is the client-generated UUID shared by every revision of a visit.
- `revisionId` is a server-generated UUID that uniquely identifies an accepted submission.
- `baseRevisionId` identifies the current revision from which the submitting tablet edited. It is null for a new visit.
- Each revision contains the complete visit payload: plot UUID, observation date, observer list, species cover estimates, and notes.
- A revision's payload, author, base revision, and receipt metadata never change after acceptance.

A supplied base revision must exist and belong to the submitted visit. An unknown or cross-visit base is rejected rather than creating an orphaned branch. A null base is valid only for creation; if the visit already exists, the submission becomes a competing creation rather than replacing its current revision.

## Submission Acceptance

Authenticate the submitting worker and validate the idempotency key, field types, plot reference, visit identity, and base revision before accepting a submission. Preserve the original payload independently of the current-revision pointer and any review outcome.

A retry with the same idempotency key and identical submission envelope returns the original acceptance result without creating another revision. Reuse with a different envelope is rejected and leaves the original submission unchanged. Acceptance results distinguish `current` from `pendingReview`; neither result implies that the submission has been discarded.

For an accepted submission, the transactional concurrency rules are:

1. If no current revision exists and there is no open review, a null-base submission becomes the first current revision.
2. If no review is open and `baseRevisionId` equals the current revision, the submission becomes the new current revision. The previous current revision remains in history as its ancestor.
3. Otherwise, the submission becomes a candidate in the visit's open review, creating that review if necessary. The current revision does not change.

Once a review is open, no submission advances the current revision automatically, including a submission based on that current revision. This keeps the comparison anchored to one current revision while allowing field workers to continue submitting complete revisions. Every candidate remains intact regardless of its relationship to earlier candidates.

The submission response includes the accepted `revisionId`, the visit's current `revisionId`, acceptance state, and the open review's identifier and version when one exists. Tablets therefore learn whether their submission became current without inferring that from HTTP success alone.

## Competing-Revision Review

An open review consists of the anchored current revision, every competing revision accepted while that review is open, and a monotonically increasing review version. Adding a candidate increments the review version. Retrieval returns the complete current and candidate payloads together with each revision's author, base revision, and receipt time so a coordinator can compare whole visits and inspect provenance.

A coordinator resolves a review by selecting exactly one complete revision: either the anchored current revision or one of the candidates. Selecting the current revision keeps it current; selecting a candidate makes that candidate current. The operation records the coordinator's identity, resolution time, selected revision, and all revision IDs participating in the review. Non-selected candidates remain immutable history and are never merged into the selected payload.

Resolution includes the review version the coordinator inspected. If candidates have been added since then, the store rejects the resolution and leaves the review open, forcing the coordinator to see the additional submission before deciding. Resolution and candidate insertion use the same transaction boundary as submission acceptance. After successful resolution, the review closes and the selected revision becomes the only basis for subsequent automatic advancement.

A coordinator who needs corrections beyond a submitted revision resolves the review first and then submits a new complete revision based on the selected current revision. Review resolution itself never authors a hybrid payload.

## Retrieval and History

Current-state retrieval returns the current revision, its complete payload, and a summary of any open review. The presence of an open review is explicit even though a current payload remains available for read-only field reference. Export eligibility is derived from the absence of an open review, not from the existence of a current revision.

History retrieval returns every accepted revision and every resolution decision in server receipt order. Revision history retains both automatically superseded revisions and non-selected review candidates, with their original ancestry and authorship. No concurrency outcome deletes or rewrites an original submission.

## Tablet-Sync Obligations

Tablet-sync must retain the server-issued base revision ID alongside each locally accepted visit state and submit that ID with the next complete visit payload. New visits use a null base. Retries reuse the original idempotency key and submission envelope.

The tablet must handle `current` and `pendingReview` as distinct successful outcomes. A pending submission is preserved server-side and must not be presented as lost or silently overwritten by a later refresh. Before submitting another edit, the tablet must deliberately choose the revision it is editing; a refresh does not rewrite the base of an existing local draft.

After review resolution, tablet-sync refreshes the selected current revision and its revision ID. A worker who continues an older local draft submits it with its actual base, making it a new competing revision when appropriate. Tablet-sync does not need base snapshots, structured field changes, or field-level merge logic for this protocol.

## Review and Export Obligations

Review-export must provide a visit-level queue and a comparison screen showing the anchored current revision and every candidate as complete visits. It must preserve revision authorship and submission provenance in that view and submit the displayed review version when recording a selection. A review-version conflict requires reloading the comparison rather than retrying the decision blindly.

Any visit with an open revision review is excluded in full from the reviewed CSV. Once its review closes, only the selected current revision is eligible for export. The export path needs revision-level provenance linking an exported visit to its selected submission and resolution; it does not need field-level provenance or merge-rule maintenance.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent edit representation | Immutable whole-visit revisions with coordinator selection | Field-aware three-way merge with structured changes and field-level provenance | Whole visits cannot combine scientifically related edits unnoticed, and the small coordination team can operate the workflow without maintaining merge rules. Three-way merge remains worth reconsidering if unrelated-field review volume becomes unmanageable: it would reduce queue size and submission payload simplicity is less valuable at that point, but tablets would need base snapshots and structured changes while review/export would need field-level provenance and maintained merge rules. |
| Current revision while review is open | Keep the current pointer anchored until resolution | Continue advancing the current pointer on later submissions | A stable anchor gives coordinators one explicit comparison set and prevents arrival order from silently displacing a submission already under review. |
| Resolution payload | Select one submitted complete revision | Coordinator authors a merged resolution during review | Selection preserves whole-visit authorship and avoids an implicit merge path; any further correction is an ordinary new revision. |
| Concurrent resolution and submission | Reject resolution when the review version has changed | Resolve against the originally displayed candidates and close later arrivals automatically | Optimistic review versioning prevents an unseen field submission from being excluded by a stale coordinator decision. |
| Original submissions | Retain every accepted revision and resolution permanently as history | Keep only the selected revision and a summary of rejected candidates | Original payloads and provenance are required to explain corrections and prevent silent loss. |

## Open Questions & Future Decisions

### Deferred

1. History pagination and operational retention limits can be sized with implementation and observed seasonal volume; they do not change revision semantics.
2. Coordinator notification and queue assignment belong to review-export, not record-store.

## LLD edge-case probe

The independent probe found these internal design gaps:

### Design blockers

1. **Delayed resolutions:** Should resolution require both `reviewId` and `reviewVersion`, so a delayed decision cannot close a newer review?
2. **Idempotency scope:** Are keys globally unique or scoped per worker? Concurrent first uses need atomic deduplication, and envelope equality needs a canonical comparison rule.
3. **Retries after later changes:** Should an identical retry return the original response snapshot, or the original acceptance classification with fresh current/review state?
4. **Resolution retries:** Should resolutions have idempotency keys so a timeout retry returns the original result without adding another history event?
5. **Consistent reads:** Must current/review retrieval return one transactional snapshot so payloads, candidate lists, and versions cannot come from different states?
6. **Error contracts:** Which stable machine-readable errors distinguish invalid bases, idempotency mismatches, stale reviews, and retryable failures?
7. **Atomic compare-and-apply:** Must submission and resolution transactions serialize their version predicates, ensuring two submissions based on one revision become one advancement plus one candidate?

### Deferrable details

8. **History ordering:** Concurrent events need a deterministic tie-breaker before cursor pagination is designed.
9. **Retention:** “Permanent history” conflicts with mentioning future retention limits; the deferred item should concern storage capacity, not deletion of original submissions.

Please approve the LLD’s main model and indicate which of items 1–7 to settle now versus defer. I recommend settling all seven before drafting the EARS specifications.