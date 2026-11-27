Updated `docs/intent/record-store/record-store-design.md` for **whole-visit revisions** (and updated `docs/high-level-design.md` to mark `record-store` as drafted rather than open).

### Summary of `docs/intent/record-store/record-store-design.md`
- **Concurrency model**: Append-only immutable submissions (`submission_id`, `visit_id`, `base_revision_id`, `idempotency_key`, `author_id`, `received_at`, `payload`). Initial creation (`base_revision_id: null`) and fast-forward edits (`base_revision_id == current_revision_id` while `current`) advance `current_revision_id`. Mismatched `base_revision_id` or edits arriving while `needs_review` are stored as competing revisions and set/keep `visit_status: needs_review`.
- **Public contract**:
  - `submitVisit`: validates worker auth, field types, and `site-catalog` `plot_id`; enforces `idempotency_key` (`409 Conflict` on payload mismatch); returns `{ submission_id, visit_id, outcome: accepted_current | accepted_competing, current_revision_id, visit_status }`.
  - `getVisit`: returns `visit_status`, `has_unresolved_review`, `current_revision`, and `competing_revisions` (`needs_review` visits are excluded from CSV export).
  - `getVisitHistory`: returns all immutable submissions in receipt order and all resolution records.
  - `listPendingReviews` / `resolveVisitReview`: lists `needs_review` visits for comparison; coordinator resolution records `coordinator_id`, `resolved_at`, `contributing_submission_ids`, and `resulting_revision_id` (from `selected_revision_id` or `resolved_payload`), clears listed competing revisions, and returns the visit to `current`.
- **Cascade obligations**: Documented for `tablet-sync` (persist `base_revision_id` and `idempotency_key`, surface `needs_review` outcomes) and `review-export` (revision comparison view, `resolveVisitReview` invocation, exclude `needs_review` from CSV).
- **Decisions & Alternatives**: Recorded whole-visit revisions vs. field-aware three-way merge.

---

### Phase 2 LLD-Level Edge-Case Probe (for triage: fix in LLD vs. defer)

1. **`base_revision_id` validity**:
   - What happens when `base_revision_id: null` arrives for an already-existing `visit_id` (rejected vs. competing revision)?
   - What happens when a non-`null` `base_revision_id` arrives for an unknown `visit_id`, or cites a revision ID that does not exist / belongs to a different `visit_id`?
2. **Resolution invariants & concurrency (`resolveVisitReview`)**:
   - What happens if a new competing revision arrives concurrently with `resolveVisitReview` (reject with conflict if `contributing_submission_ids` doesn't match the full current pending set, or transition anyway)?
   - What happens if `contributing_submission_ids` omits an existing competing revision, is empty, has duplicates, or includes IDs from another visit?
   - What happens if `resolveVisitReview` is called on a `current` visit, supplies both or neither of `selected_revision_id` / `resolved_payload`, or picks a `selected_revision_id` that is `current_revision_id` / already resolved / from another visit?
   - What happens if `resolved_payload` has invalid fields, an unknown `plot_id`, or changes `plot_id` from the visit's prior revisions?
3. **Idempotency & retry semantics**:
   - Is `idempotency_key` scoped globally, per-`author_id`, or per-`visit_id`?
   - Does a validation-rejected submission consume the `idempotency_key`?
   - On `idempotency_key` replay after later edits/resolutions, do `current_revision_id` and `visit_status` reflect the original receipt snapshot or current state?
   - How are `resolveVisitReview` retries handled after a transient network failure (no `idempotency_key` is currently specified)?
4. **Concurrency, ordering, & auth**:
   - What serialization/locking invariant prevents lost updates on simultaneous `submitVisit` calls for the same `visit_id`?
   - What are the role/authorization boundaries for `listPendingReviews`, `getVisit`, `getVisitHistory`, and coordinator use of `submitVisit`?
   - What error codes/payloads apply for not-found, unauthorized, forbidden, validation, and state-conflict errors (only `409 Conflict` for idempotency mismatch is specified)?
   - How are `getVisitHistory` ties broken, are submissions and resolutions interleaved or separate, and what fallback applies in `listPendingReviews` when competing revisions have different `base_revision_id`s?
   - What domain constraints apply to scientific fields (e.g., empty `observers`/`species_cover`, duplicate species, cover range, `observation_date` bounds)?

---

### Decision Doc Offer

Because the **whole-visit revisions vs. field-aware three-way merge** choice trades credible options against multiple criteria and sizes both `tablet-sync` and `review-export`, would you like me to record it as a full decision doc (`docs/intent/record-store/decisions/concurrent-visit-edits.md`) linked from the LLD's table, or keep it as the `Decisions & Alternatives` table row?

---

**Next**: Please triage which edge cases above to resolve in `record-store-design.md` vs. defer, let me know your preference on the decision doc, and confirm if we can proceed to **Phase 3 (EARS spec updates)**.