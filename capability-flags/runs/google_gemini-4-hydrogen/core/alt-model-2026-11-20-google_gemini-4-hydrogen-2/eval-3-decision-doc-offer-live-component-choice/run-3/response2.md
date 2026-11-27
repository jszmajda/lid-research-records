Recorded the decision doc at `docs/intent/record-store/decisions/concurrency-policy.md` and linked it from `docs/intent/record-store/record-store-design.md`. It covers:
- The decision criteria tied to TidePlot's HLD tenets (scientific integrity, two-coordinator simplicity without a sysadmin, review queue volume, and client/review surface complexity).
- Both options analyzed against those criteria, including why field-aware three-way merge remains a credible alternative if concurrent edit volume makes the coordinator queue a bottleneck.
- What `tablet-sync` and `review-export` must accommodate (`base_revision_id` and `idempotency_key` tracking on tablets; whole-visit comparison UI and `unresolved` export exclusion in review-export).

Before moving to Phase 3 (`record-store-specs.md`), please triage the Phase 2 LLD edge-case probe items (which to fix in `record-store-design.md` vs. defer):
1. **Invalid `base_revision_id` transitions** (non-null base for a new `visit_id`, `null` base for an existing `visit_id`, or `base_revision_id` belonging to another visit/unknown UUID).
2. **`plot_id` immutability** across edits to an existing `visit_id`.
3. **Idempotency key scoping & equivalence** (global vs. per-author/visit, whether envelope fields must also match, and list-order sensitivity).
4. **Consolidated revision representation** (`base_revision_id`, `author_id`, and whether it appears in submission history).
5. **Concurrent, partial, or stale resolutions** (two coordinators resolving at once, empty/foreign `contributing_submission_ids`, or a new competing revision arriving mid-review).
6. **Resolution idempotency & role checks** (`idempotency_key` on resolution retries; coordinator authorization).
7. **API error shapes & not-found behavior** (unknown `visit_id` on retrieval/resolution, or resolving a `clean` visit).

Also let me know if you want me to update the `record-store` status note in `docs/high-level-design.md` now, and confirm when you're ready to proceed to Phase 3.