I updated `docs/intent/record-store/record-store-design.md` with the whole-visit revision contract and updated `docs/high-level-design.md` to reflect that the concurrency policy is defined. `git diff --check` passes.

The record-store design draft is below for this phase’s review:

---

# Record Store

## Context and Design Philosophy

The record store accepts visit submissions from workers whose tablets may have been offline for up to 48 hours. Two workers can independently correct the same visit from different starting states. A visit is identified by a client-generated UUID and refers to a stable plot UUID from the site catalog.

The record store preserves every accepted submission as a complete, immutable visit revision. A submission based on the current revision can advance the current visit when no review is pending. A submission based on an older revision is retained as a competing revision and makes the visit unresolved; arrival order does not choose a winner. The store does not automatically combine fields from separate revisions. This keeps each worker's submitted observation intact and leaves scientific judgment with a coordinator.

## Visit and Revision Model

Each visit has a stable visit ID, a current revision ID once initialized, and a review state. Each revision has a stable revision ID, the visit ID, the complete visit payload, the submitting worker ID, the server receipt time, and the base revision ID from which the worker edited. The initial revision has no base revision. A revision never changes after acceptance.

The complete payload contains the plot UUID, observation date, observer list, species cover estimates, and notes. A revision is a full snapshot, not a patch. Revision metadata identifies provenance without altering the submitted payload. The current revision is the complete snapshot presented as the visit's current state; competing revisions remain available in submission history and are not folded into it.

The visit's review state is either `clear` or `unresolved`. `clear` means the current revision can be returned as the visit's current state without a pending competing submission. `unresolved` means at least one accepted revision is awaiting coordinator resolution. The record store reports this state with current-state retrieval so consumers cannot mistake an unresolved visit for an unambiguous record.

## Submission Contract

A submission contains a visit ID, an idempotency key, a nullable base revision ID, and the complete visit payload. The authenticated identity supplies the submitting worker ID; clients cannot attribute a submission to another worker by changing payload metadata.

Before acceptance, the store authenticates the worker and validates required fields, field types, and the plot UUID against the catalog. A new visit is initialized by a submission with no base revision. A later submission must identify an existing revision belonging to the same visit. A missing or unknown base revision for an existing visit, or a base revision belonging to another visit, is rejected without storing a revision.

If the idempotency key has already been accepted with the same worker and identical submission content, the store returns the original acceptance result and creates no revision. Reuse of that key with different content is rejected and does not change the earlier submission. The idempotency check and revision acceptance are atomic so concurrent retries cannot create duplicate revisions.

Submission outcomes distinguish a newly accepted current revision, an accepted competing revision that requires review, and a rejected submission. Rejections identify the validation or conflict reason and do not modify the visit. A competing submission is accepted and preserved; it is not reported as the current revision.

## Current Revision and Competing Submissions

When a valid initial submission creates a visit, its revision becomes current and the visit is clear. When a valid submission names the current revision as its base and the visit is clear, the new complete revision becomes current and the visit remains clear.

When a valid submission names a revision other than the current revision as its base, the store accepts it as a competing revision, leaves the current revision unchanged, and marks the visit unresolved. The store does not infer which revision is scientifically preferable from receipt time or from which fields differ.

While a visit is unresolved, subsequent valid submissions are retained as revisions and remain part of that visit's unresolved review work; none advances the current revision automatically. The store keeps the complete revision history, including revisions that are not selected during resolution. A retry of an already accepted submission returns its original outcome and does not reopen or duplicate review work.

## Retrieval and Resolution

Current-state retrieval returns the current complete revision and the visit's review state. Submission-history retrieval returns the accepted revisions with their authors, receipt times, base revision IDs, and complete payloads. Both operations identify revisions by stable IDs so a consumer can refer to an exact snapshot.

A coordinator resolves an unresolved visit with an explicit resolution operation. The operation records the coordinator ID, resolution time, selected revision ID, and the IDs of the revisions considered in that resolution. The selected complete revision becomes current and the visit returns to `clear`. Revisions not selected remain in history and the resolution records which revision was chosen; the store does not delete or silently overwrite their submissions.

The resolution operation must be atomic with the review-state transition. It rejects a revision that does not belong to the visit and rejects a resolution if the visit is no longer unresolved. A successful resolution is idempotent by resolution key, so retrying after a lost response returns the original resolution result.

## Persistence and Consistency

The store persists accepted revisions, idempotency results, current-revision pointers, and resolution records durably. Accepting a submission, advancing the current revision or opening review, and recording idempotency outcome occur as one atomic operation. A failure cannot leave a revision accepted without the corresponding current/review state, or update the state without retaining the revision.

The store retains original revisions after resolution. The active current pointer and review state are derived operational state; they do not replace the immutable submission history. The storage technology and physical schema are implementation choices as long as these invariants hold.

## Downstream Contracts

Tablet-sync uses the base revision ID and the submission outcomes to report whether an edit became current or needs review. It must retain the full local visit snapshot used for submission until it receives the server outcome.

Review-export consumes current-state and revision-history retrieval, presents competing complete revisions for coordinator comparison, and excludes unresolved visits from CSV eligibility. Its design owns the comparison interface and export workflow; it does not redefine record-store revision or resolution semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Concurrent edits to one visit | Preserve each complete submission as an immutable revision; mark stale-base submissions unresolved for coordinator resolution | Field-aware three-way merge that automatically combines disjoint field edits and sends overlaps to review | A larger review queue is preferable to maintaining merge rules that can combine scientifically related edits without recognizing their relationship. Whole revisions also preserve the exact submitted observations and avoid treating field independence as scientific independence. |
| Current revision after a competing submission | Keep the previously current revision until explicit coordinator resolution | Promote the latest-arriving submission or choose a winner by merge rules | Receipt order does not establish scientific authority, and automatic promotion would hide which competing revision was selected. |

## Open Questions & Future Decisions

### Resolved

1. Concurrent edits are represented as whole-visit revisions rather than automatically merged field changes.
2. A stale-base submission is retained and requires coordinator resolution; it does not replace the current revision on arrival.

### Deferred

1. Decide whether coordinator resolution may select only an existing complete revision or may also create a new complete resolution revision assembled from the reviewed submissions. In either case, original submissions remain immutable and attributable.

## References

- [High-Level Design](../../high-level-design.md)
- [Site Catalog design](../site-catalog/site-catalog-design.md)

---

### Edge-case probe for your review

Please triage these gaps: should each be resolved in this LLD now, or deferred?

1. **What can a coordinator resolve to?** Selecting an existing submitted revision keeps resolution simple and its provenance direct, but cannot capture a reviewed result that differs from every submission. Allowing a new, coordinator-authored full revision preserves that option, but requires explicit attribution and a link from the resolution to its source revisions. Which belongs in this contract?
2. **Submissions arriving during review:** The draft keeps accepting them into the unresolved work. Should a resolution have to account for the exact revision set it reviewed—and fail if that set changed—or may it resolve a known subset while later submissions remain for another review?
3. **Two initial submissions with the same visit ID:** The draft rejects the second because an existing visit requires a base revision. Should a second no-base submission instead be retained as a competing initial revision?
4. **Archived plots:** The catalog retains archived plot references for history and excludes archived plots from the default picker. Should the record store accept revisions to existing visits on archived plots, and should it reject creation of new visits on them?

The HLD and LLD are coherent at the architecture level. The current EARS specs cover retention, unresolved-state indication, and resolution provenance, but need a follow-up update to capture the approved contract. Please review the LLD and triage the four questions above; I’ll continue the cascade after your response.