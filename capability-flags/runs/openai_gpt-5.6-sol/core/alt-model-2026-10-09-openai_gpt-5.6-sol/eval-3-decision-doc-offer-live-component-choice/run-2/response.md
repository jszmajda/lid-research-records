**Phase 2: Record-Store Design**
The whole-visit revision design is drafted in `docs/intent/record-store/record-store-design.md`. It now defines:

- Immutable complete revisions with base revision IDs.
- A stable canonical revision while competing revisions await review.
- At most one open review case per visit.
- Atomic submission, idempotency, case-version, and race semantics.
- Coordinator-authored resolution revisions with complete provenance.
- Explicit tablet-sync and review-export contracts without designing those components.
- Rejection and retry behavior for invalid bases, unavailable catalog validation, and stale resolutions.

`docs/high-level-design.md` now records that the whole-visit contract was selected; its architecture remains unchanged.

The delegated edge-case probe focused on concurrent case creation, resolution retries, late submissions, and provenance. Those mechanical gaps were incorporated into the draft. One domain question remains:

1. Under the same visit UUID, may a revision correct the plot UUID and observation date, or do either of those fields become immutable after the first accepted revision?

The draft also needs your ruling on:

2. Do you approve the Phase 2 design, particularly keeping the previous canonical revision current during review, adding every later submission to the open case, and creating a new complete revision for coordinator resolutions?
3. This concurrency choice remains credible to re-litigate and determines two downstream designs. Should it receive a full decision document, or is the existing Decisions & Alternatives row sufficient?
4. `site-catalog-design.md` still says reconciliation is pending this choice. May I update that cross-segment status sentence when proceeding?

No EARS specifications have been changed yet; that begins after Phase 2 approval.