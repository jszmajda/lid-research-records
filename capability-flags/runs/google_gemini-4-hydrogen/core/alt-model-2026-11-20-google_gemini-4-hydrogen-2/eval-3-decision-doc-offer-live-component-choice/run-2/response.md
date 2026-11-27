I updated `docs/intent/record-store/record-store-design.md` to complete the `record-store` design around **whole-visit revisions**, and updated `docs/high-level-design.md` to reflect that the concurrency contract is now defined.

### Summary of Changes
- **`docs/intent/record-store/record-store-design.md`**:
  - Defined the whole-visit revision model (initial creation, fast-forward edits, and concurrent edits producing `pending_review` competing revisions).
  - Defined the submission envelope (`visit_id`, `idempotency_key`, `base_revision_id`, `payload`), validation sequence, and acceptance outcomes (`accepted_current` / `accepted_competing`).
  - Defined visit retrieval, submission history, and the unresolved-work query (`current_revision` + `competing_revisions`).
  - Defined the coordinator resolution operation (selecting a competing revision or supplying a coordinator-authored `resolved_payload` with `contributing_revision_ids`).
  - Recorded downstream contract obligations for `tablet-sync` and `review-export`, and added `Decisions & Alternatives` entries for whole-visit revisions and coordinator resolution shape.
- **`docs/high-level-design.md`**: Updated `record-store` status to `Drafted` and updated the architecture note to reference the whole-visit revision contract.

### Decision Doc Offer
Because whole-visit revisions vs. field-aware three-way merge trades multiple criteria (review queue size, merge-rule maintenance, and preserving scientifically coupled fields) and both `tablet-sync` and `review-export` will be sized around this contract, would you like me to record it as a standalone decision doc (`docs/intent/record-store/decisions/whole-visit-revisions.md`), or is the `Decisions & Alternatives` row in `record-store-design.md` sufficient?

### Phase 2 LLD Edge-Case Probe
Please triage which of these internal `record-store` gaps to address in `record-store-design.md` now vs. defer:

1. **Concurrent initial creations**: What happens when two requests with `base_revision_id: null` arrive concurrently for the same new `visit_id` with different `idempotency_key`s?
2. **In-flight idempotency races**: What happens when two requests with the same `idempotency_key` arrive concurrently before the first commits?
3. **Idempotency key scoping & failed validations**: Is `idempotency_key` scoped globally or per `author_id`/`visit_id`, and does a rejected submission burn its key?
4. **Error shapes & status codes**: What HTTP status codes and error shapes apply to auth failure, field-type validation failure, unknown `plot_id`, invalid `base_revision_id`, or unknown `visit_id` on reads?
5. **Payload domain invariants**: What structural/boundary rules apply to `VisitPayload` (e.g., empty `observers`, negative or >100% `species_cover`, `null` vs. empty `notes`)?
6. **Partial resolution with concurrent arrivals**: When a coordinator resolves `contributing_revision_ids` while another competing revision arrived concurrently, does `current_revision_id` advance to `winning_revision_id` (while `review_status` stays `pending_review`) or stay at the prior revision?
7. **Concurrent / retried resolutions**: Does the resolution operation need its own `idempotency_key` and a concurrency check when two coordinators resolve the same visit simultaneously?
8. **Keeping `current_revision_id` on resolution**: Can a coordinator resolve a conflict by keeping `current_revision_id` as-is and dismissing the competing revisions, or must they select a competing revision / author a `resolved_payload`?
9. **Resolution input invariants**: What happens if `contributing_revision_ids` includes revisions from another `visit_id`, already-resolved revisions, or omits `selected_revision_id`?
10. **Coordinator-synthesized revision metadata**: How are `base_revision_id`, `author_id`, and `idempotency_key` populated when a coordinator's `resolved_payload` is stored as a new revision?
11. **Authorization boundaries**: Can any authenticated worker edit any `visit_id`, and is the resolution operation restricted to coordinator roles?
12. **Ordering ties & multi-branch ancestors**: What tie-breaker orders revisions with identical `received_at` timestamps, and how is the common ancestor/base revision chosen when 3+ competing revisions branch from different ancestors?

**Phase 2 Review:** Please review `docs/intent/record-store/record-store-design.md`, let me know your preference on the decision doc and edge-case triage, and confirm when you're ready to proceed to Phase 3 (`record-store-specs.md`).