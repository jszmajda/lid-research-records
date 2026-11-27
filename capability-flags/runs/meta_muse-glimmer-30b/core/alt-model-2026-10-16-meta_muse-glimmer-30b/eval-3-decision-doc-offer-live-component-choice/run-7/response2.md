Updated `docs/intent/record-store/record-store-design.md` with a proper write-up of the whole-visit revisions choice and downstream impact.

**Why the alternative remains credible**
Field-aware three-way merge was still a credible option. It would reduce review volume by automatically combining disjoint field changes, get more visits ready for export sooner, and lower coordinator workload. Tablet-sync would retain base snapshots and send structured field-level changes; review-export would need field-level provenance and a review view only for overlapping changes.

It was not chosen because it requires maintained merge rules for scalar fields, observer lists, and species entries, and automatic combination can cross scientific relationships the rules do not understand — e.g., revising a species identification and its cover estimate together. The team prefers a larger review queue over maintaining rules that could silently combine scientifically related edits.

**Downstream accommodations now documented**

*Tablet-sync*
- Must retain `baseRevisionId` for each local draft and send it with every submission.
- Must surface pending competing revisions to the worker so they understand their submission is under review.
- Local storage and retry state machine must be sized around the submission envelope and idempotencyKey.
- Tablet UI must explain unresolved visits and pending coordinator review.

*Review-export*
- Must present a revision comparison screen showing two or more whole-visit revisions side by side with author, received time, base revision, and full payload diff.
- Export eligibility is governed by the unresolved-work signal: any visit with `pendingRevisions` is held out of the partner CSV.
- Friday export includes only visits with a resolved revision and no pending revisions.
- Must record coordinator identity and resolution time with the chosen revision.

**Decisions & Alternatives table updated**
Decision: Concurrent edit policy
- Chosen: Whole-visit revisions: each edit names its base revision; competing complete revisions await coordinator resolution.
- Alternatives Considered: Field-aware three-way merge with automatic combination of disjoint field changes and review for overlaps.
- Rationale: Whole-visit preserves submitted visit as an intact unit, avoids merge rules that could combine scientifically related edits without noticing, and matches user preference for a larger review queue over maintaining merge rules. Review work is visible and export eligibility is clear. Field-aware merge was credible because it would reduce review volume, get more visits ready for export, and reduce coordinator workload. It was not chosen because it requires maintained rules for scalar fields, observer lists, and species entries, and automatic combination can cross scientific relationships the rules do not understand.

The LLD now includes a `Downstream Implications` section covering tablet-sync and review-export, and the Decisions & Alternatives table records why the alternative was considered and rejected.

Please review the revised design and confirm:
1. The downstream accommodations for tablet-sync and review-export are accurate.
2. The rationale for rejecting field-aware merge captures the scientific-relationship concern.
3. Any adjustments to the submission envelope, current-state response, or resolution operation before we lock Phase 2 and move to Phase 3 EARS review.