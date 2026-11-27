Updated `docs/intent/record-store/record-store-design.md` for **whole-visit revisions**, defining the revision model (`base_revision_id`, `current_revision_id`, `pending_revisions`, `review_status`), submission validation and idempotency, current-state and history retrieval, coordinator resolution (`select_existing` and `reconciled_payload`), and downstream cascade notes for `tablet-sync` and `review-export`.

Stopping at **Phase 2** for your review before updating `record-store-specs.md` (Phase 3).

### Decision Doc Offer
Because whole-visit revisions vs. field-aware three-way merge trades multiple criteria and sizes both `tablet-sync` and `review-export`, would you like me to record it as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the Decisions & Alternatives table), or is the table row in `record-store-design.md` sufficient?

### Phase 2 Edge-Case Probe (for triage: fix in LLD vs. defer)
A cold review of `record-store-design.md` surfaced these internal gaps:

1. **Idempotency key scoping & payload equality**: What happens when the same `idempotency_key` is used by two different workers, across two different `visit_id`s, or on a retry where list fields (`observer list`, `species cover estimates`) have identical elements in a different order?
2. **Stale `review_status` on idempotent retry**: When a submission is retried with an accepted `idempotency_key` after another edit or resolution changed the visit's `review_status`, should the response return the original `review_status` snapshot or the visit's current `review_status`?
3. **Concurrent initial creation (`base_revision_id: null`)**: If two submissions arrive for the same `visit_id` with `base_revision_id: null` and distinct `idempotency_key`s, is the second rejected (per `null` only valid when no revisions exist) or accepted into `pending_revisions`?
4. **`plot_id` mutability & "historical visits"**: Can a subsequent revision or coordinator `reconciled_payload` change a visit's `plot_id`, and does "historical visits" for archived `plot_id`s mean an existing `visit_id` or a past observation date on a new visit?
5. **Resolution selection & `contributing_submission_ids` invariants**: Can `select_existing` pick `current_revision_id` (e.g., to discard all pending edits) or only a revision in `pending_revisions`, and must `contributing_submission_ids` match `pending_revisions` exactly or also include `current_revision_id`?
6. **Reconciled revision metadata & resolution idempotency**: What values do `base_revision_id`, `author_id`, and `idempotency_key` take on a revision created by `reconciled_payload`, and how are retried resolution requests handled once the visit is `clean`?
7. **Ordering tie-breakers & unknown `visit_id`**: What breaks ties when two submissions share the same `received_at` timestamp, and what do current-state and history retrieval return for an unknown `visit_id`?

Please let me know:
1. Any changes to `docs/intent/record-store/record-store-design.md`.
2. Which of the 7 edge cases to specify in the LLD vs. defer.
3. Whether to add the decision doc or keep just the Decisions & Alternatives row.
4. Whether to proceed to Phase 3 (`record-store-specs.md`) after applying your feedback.