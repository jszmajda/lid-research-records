I expanded the record-store design to explain why whole-visit revisions were chosen, why field-aware merging remains attractive, and what each approach would require from tablet-sync and review-export. I also clarified that a resolution may produce a new revision, but left that choice open for your review. The HLD now shows the revision policy as selected and resolution details as open. `git diff --check` passes.

## Updated `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
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

A coordinator resolves an unresolved visit with an explicit resolution operation. The operation records the coordinator ID, resolution time, the complete revision designated as current, and the IDs of the submitted revisions considered in that resolution. The designated complete revision becomes current and the visit returns to `clear`. If the resolution creates a new complete revision, the store retains it separately and links it to the source submissions; whether coordinators may create such a revision remains an open choice. Revisions not selected remain in history and the resolution records which revision was chosen; the store does not delete or silently overwrite their submissions.

The resolution operation must be atomic with the review-state transition. It rejects a revision that does not belong to the visit and rejects a resolution if the visit is no longer unresolved. A successful resolution is idempotent by resolution key, so retrying after a lost response returns the original resolution result.

## Persistence and Consistency

The store persists accepted revisions, idempotency results, current-revision pointers, and resolution records durably. Accepting a submission, advancing the current revision or opening review, and recording idempotency outcome occur as one atomic operation. A failure cannot leave a revision accepted without the corresponding current/review state, or update the state without retaining the revision.

The store retains original revisions after resolution. The active current pointer and review state are derived operational state; they do not replace the immutable submission history. The storage technology and physical schema are implementation choices as long as these invariants hold.

## Downstream Contracts

Tablet-sync stores the base revision ID with each local visit draft and submits the complete visit snapshot with that base ID. It retains the submitted snapshot until the server confirms its outcome, then tells the worker whether that revision became current or is awaiting review. A competing revision must remain available on the tablet while unresolved so a later refresh does not silently replace the worker's submission.

Review-export consumes current-state and revision-history retrieval, presents competing complete revisions for coordinator comparison, and excludes unresolved visits from CSV eligibility. Its design owns the comparison interface and export workflow; it does not redefine record-store revision or resolution semantics.

## Concurrency Decision and Alternatives

Whole-visit revisions are selected because the record store cannot reliably infer whether two field changes are scientifically independent. For example, changing a species identification and changing its cover estimate may be coupled even though the edits occupy separate fields. Preserving each complete submitted snapshot avoids combining those changes without review and leaves an inspectable record of what each worker submitted.

Field-aware three-way merge remains a credible alternative because workers often make unrelated corrections, such as fixing an observer name while adding a missing species. Given the team's small coordinator group and recurring weekly export, automatically combining genuinely independent edits could reduce review volume and make more visits export-ready. That benefit would require the system to retain each tablet's base snapshot, accept structured field changes, and maintain merge rules for scalar values, observer lists, and species entries. The rules would have to recognize relationships among fields and keep field-level provenance for automatically combined results; a rule that treats fields as independent could produce a plausible-looking but scientifically inconsistent visit.

With whole-visit revisions, tablet-sync must retain the base revision ID and full local snapshot, and it must explain when a stale submission is preserved for review rather than becoming current. Review-export must compare complete revisions, record the coordinator's resolution, and keep unresolved visits out of the partner CSV. If field-aware merging were selected instead, tablet-sync would retain base snapshots and send structured changes; review-export would need field-level provenance, a view for overlapping changes, and export eligibility based on whether any overlaps remain unresolved.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Concurrent edits to one visit | Preserve each complete submission as an immutable revision; mark stale-base submissions unresolved for coordinator resolution | Field-aware three-way merge that automatically combines disjoint field edits and sends overlaps to review | Field-aware merging could reduce coordinator workload when edits are truly independent, which matters for a small team preparing a weekly export. It is not selected because the field model cannot reliably establish scientific independence: related edits such as species identity and cover can cross field boundaries. Whole revisions accept a larger review queue in exchange for preserving submissions without automated combinations that could alter their meaning. Downstream obligations are detailed in Concurrency Decision and Alternatives. |
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
```

The edge-case probe still needs your triage before I proceed to the EARS update:

1. Should coordinator resolution select only an existing submitted revision, or may it create a new complete revision?
2. If submissions arrive while a visit is unresolved, should resolution fail and refresh when its revision set changes, or may it resolve a known subset while later submissions remain for review?
3. Should a second no-base submission for an existing visit ID be rejected, as drafted, or retained as a competing initial revision?
4. For archived plots, should the store accept revisions to existing visits and reject new visits? Or should this catalog/record-store interaction be deferred?

Which of these should be resolved in this design now, and which should remain deferred?