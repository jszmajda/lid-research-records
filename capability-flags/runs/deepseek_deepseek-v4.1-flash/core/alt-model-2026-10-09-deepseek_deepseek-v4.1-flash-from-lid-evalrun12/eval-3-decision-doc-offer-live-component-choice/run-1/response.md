Phase 1 (HLD check) and Phase 2 (record-store LLD) are done. Stopping at the Phase 2 boundary for your review.

## Phase 1 — HLD
The concurrency choice belongs to record-store, as the HLD states, so no architectural change. I updated the HLD architecture row from `Drafted; concurrency choice open` to `Drafted`. Tenets unaffected — whole-visit revisions don't silently discard edits, keep offline capture open, and keep the value→submission→resolution path inspectable.

## Phase 2 — record-store LLD finished
Rewrote `docs/intent/record-store/record-store-design.md` around whole-visit revisions. Core model:

- **Visit** (visit_id, plot_id, current_revision_id, resolution_state), **Submission** (immutable original payload + author + receipt + idempotency + base revision), **Revision** (a whole-visit state node; origin is either a submission or a resolution), **Resolution** (coordinator, winning revision, contributing submission IDs).
- Linear continuation (base == current) advances the current revision, no review. Any other accepted revision is **competing** and flips the visit to `unresolved`.
- While unresolved, the current revision is **frozen** as the comparison anchor; further submissions still join the competing set.
- Resolution selects an existing revision **or** a coordinator-composed one, sets it current, clears the competing set, records coordinator + contributing submission IDs. Original submissions are never altered.
- Defined the submission envelope, acceptance result, current-state retrieval (returns the unresolved signal + competing candidates for tablet-sync/review-export), and the resolution operation.

Decisions recorded in the table: whole-visit over field-aware merge; frozen anchor over receipt-ordered; accept-as-competing over reject; compose-allowed over select-only; plot fixed at creation; idempotency scoped per (author, visit).

**Please confirm these three rulings**, since they shape the contract tablet-sync and review-export will build on:
1. A submission whose base is the frozen anchor while the visit is already unresolved still becomes competing (not treated as a clean continuation).
2. Resolution may compose a new revision, not only select an existing one.
3. Superseded revisions/resolutions are retained indefinitely for the first release (export/audit needs set the floor later).

## LLD-level edge probe (delegated)
A fresh subagent probed the LLD against its own gaps. 13 findings — please triage which to fix in the LLD vs. defer as open questions:

1. Two "creating" submissions (both base absent) race for the same visit — no rule for first-vs-competing.
2. Submission based on the frozen anchor while unresolved — is it competing? (relates to ruling 1)
3. Same author + visit with two different idempotency keys — allowed or rejected?
4. What makes a replayed payload "identical" — bytes vs normalized field set?
5. Rejection response shapes/codes unspecified (key conflict, plot mismatch, resolving a resolved visit, invalid types/reference).
6. `base_revision_id` of a coordinator-composed revision — undefined (draws on multiple states).
7. After a resolution, a late stale submission re-unresolves — which revision becomes the new anchor?
8. Whether submissions are accepted after a resolution at all.
9. Whether the winning revision may be a superseded, never-competing historical revision.
10. How `contributing_submission_ids` is derived (select path vs compose).
11. Two coordinators resolving the same visit concurrently — atomicity/ordering unstated.
12. "Graph order" for submission-history has no tie-break.
13. Competing-set member ordering (receipt vs acceptance) undefined.

## Decision-doc offer
The whole-visit-vs-field-aware choice will likely stay live for a cold reader (credible options, multiple criteria, and tablet-sync/review-export are about to be sized around it). Want me to write it up as a decision doc under `docs/intent/record-store/decisions/` (with the Decisions-table row as the alternative)? I'll only add it if you say yes.

**Do I have your approval to proceed to Phase 3 (EARS specs for the competing-revision, frozen-anchor, and resolution behaviors), and how do you want to triage the 13 gaps?**