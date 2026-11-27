I've updated `docs/intent/record-store/record-store-design.md` with the **whole-visit revisions** design and am stopping here at **Phase 2 (LLD review)** before updating `record-store-specs.md` (Phase 3). `tablet-sync` and `review-export` remain untouched, with their downstream obligations noted in the LLD.

### Summary of `record-store-design.md`
- **Data model**: Immutable append-only `submissions`, immutable `revisions` with at most one `current_revision_id`, and a per-visit `pending_submissions` review queue.
- **Submission envelope & acceptance**: `{ idempotency_key, visit_id, base_revision_id, payload }`. Checks idempotency first, validates fields/`plot_id`/`base_revision_id`, persists the submission, and either fast-forwards (`accepted_as_current` when `base_revision_id == current_revision_id` and no review is pending) or queues for review (`accepted_pending_review`).
- **Retrieval & export eligibility**: Returns `has_unresolved_review`, `current_revision`, and `pending_submissions`; a visit is export-eligible only when `has_unresolved_review` is `false` and `current_revision` is non-null. History retrieval returns all submissions and resolved revisions.
- **Review resolution**: Coordinator supplies `expected_pending_submission_ids` (optimistic guard against late tablet uploads), `contributing_submission_ids`, and `resolved_payload`.
- **Decisions & Alternatives**: Records whole-visit revisions vs. field-aware three-way merge, the `expected_pending_submission_ids` guard, and `idempotency_key` deduplication.

---

### LLD-Level Edge-Case Probe (for Triage)
A blind probe of `record-store-design.md` surfaced these internal gaps. Please let me know which to **fix in the LLD now** vs. **defer as open questions**:

1. **Unreachable `null` `current_revision` with pending submissions**: Under the fast-forward rule, the first initial submission (`base_revision_id: null`) always creates `current_revision`, so two colliding initial submissions would never leave `current_revision` as `null` unless the rule is adjusted.
2. **Per-visit serialization**: Whether Check 3 (checking `current_revision_id`/pending queue and fast-forwarding or queueing) is serialized per `visit_id` to prevent two concurrent submissions from both fast-forwarding.
3. **`idempotency_key` scoping**: Whether `idempotency_key` is scoped globally or per `author_id`, and whether `author_id` is part of the equivalence check.
4. **Retry after state change**: Whether repeating an `idempotency_key` after the visit is resolved/superseded returns the original acceptance response or reflects current visit state.
5. **Canonical payload comparison**: What canonicalization rules apply when comparing retried payloads (e.g., list order in `observers`/`species_cover`, whitespace, omitted vs. empty fields).
6. **Error shapes & rejection codes**: HTTP status codes / error shapes for idempotency conflicts, validation failures, and auth errors.
7. **Domain invariants on `payload`**: Whether Check 2 validates domain rules (e.g., non-empty `observers`, non-future `observation_date`, `species_cover` bounds, duplicate species) or only types and `plot_id` existence.
8. **`plot_id` mutability**: Whether `plot_id` is immutable for a `visit_id` after creation or can be changed in a later revision/resolution.
9. **Resolving an empty pending queue**: Whether `expected_pending_submission_ids: []` is rejected or allowed as a direct coordinator edit.
10. **`contributing_submission_ids` invariants**: Whether `contributing_submission_ids` must be non-empty, duplicate-free, and a subset of `expected_pending_submission_ids` (plus `current_revision` if applicable).
11. **Resolution retry idempotency**: Resolution has no `idempotency_key`, so a coordinator retry after a network timeout will fail the `expected_pending_submission_ids` check.
12. **`resolved_payload` validation**: Whether coordinator-supplied `resolved_payload` undergoes the same validation as worker submissions.
13. **Role boundaries**: Explicit enforcement rules separating worker permissions from coordinator-only resolution permissions.
14. **Unknown `visit_id` & sort order**: Not-found behavior for unknown `visit_id` on retrieval, and tie-breaking/sort order for `pending_submissions` and history entries.

---

### Decision Doc Offer
Because the **whole-visit revisions vs. field-aware three-way merge** choice trades competing criteria (review workload vs. merge-rule maintenance and preserving coupled scientific edits) and sizes both `tablet-sync` and `review-export`, I can record it as a standalone decision doc at `docs/intent/record-store/decisions/concurrency-policy.md` linked from the LLD's table—or keep it solely as the `Decisions & Alternatives` table row.

**Next**:
1. Review `docs/intent/record-store/record-store-design.md` and triage items 1–14 (fix now vs. defer).
2. Let me know whether you want the standalone decision doc at `docs/intent/record-store/decisions/concurrency-policy.md` or just the table row.
3. Confirm when you're ready to proceed to **Phase 3 (`record-store-specs.md`)**.