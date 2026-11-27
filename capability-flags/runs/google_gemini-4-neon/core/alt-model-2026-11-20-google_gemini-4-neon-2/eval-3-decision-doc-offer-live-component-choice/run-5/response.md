Updated `docs/intent/record-store/record-store-design.md` around **whole-visit revisions**.

### Summary of Updated `record-store` LLD

- **Whole-Visit Revision Model**: Every accepted submission is stored as an immutable revision (`revision_id`, `visit_id`, `author_id`, `receipt_time`, `base_revision_id`, complete payload). Visits are `clean` (single `current_revision_id`, export-eligible) or `unresolved` (competing revisions pending review, excluded from export). Initial creation (`base_revision_id: null`) and matching-base edits advance the head linearly; stale-base edits or edits arriving on an already `unresolved` visit are accepted intact as competing revisions without privileging arrival order.
- **Submission Envelope & Acceptance**: Takes `visit_id`, `base_revision_id`, `idempotency_key`, and complete `payload` (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`). Authenticates worker, enforces idempotency (exact match returns original result; mismatch rejects), validates payload and `site-catalog` `plot_id`, and returns `revision_id`, `visit_id`, `receipt_time`, `visit_status`, and `outcome` (`head_advanced` | `competing_revision`).
- **Retrieval**: Current-state retrieval returns `visit_id`, `status`, `current_revision` (head when `clean`, last clean head when `unresolved`), and `competing_revisions` (plus status filtering for the review queue and CSV export). History retrieval returns all immutable submissions and resolutions in receipt-time order.
- **Coordinator Resolution**: Authenticated coordinator submits `visit_id`, `contributing_revision_ids` (must match the exact current pending set, rejecting stale resolutions if a new competing revision arrived), `resolution_payload`, and `idempotency_key`. Stores an immutable resolution revision with `coordinator_id`, advances `current_revision_id`, transitions the visit to `clean`, and leaves original submissions intact.
- **Downstream Obligations & Decisions**: Captures cascade notes for `tablet-sync` and `review-export`, plus a Decisions & Alternatives table covering whole-visit revisions, idempotency, and resolution concurrency.

---

### Decision Doc Offer

The **whole-visit revisions vs. field-aware three-way merge** choice trades live criteria (review workload vs. merge-rule maintenance and whole-visit scientific integrity), could easily be re-litigated by a future cold reader, and sizes both `tablet-sync` and `review-export`.

Would you like to record this choice as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the Decisions & Alternatives row), or keep just the Decisions & Alternatives row in `record-store-design.md`?

---

### Phase 2 LLD Edge-Case Probe

An independent pass over `record-store-design.md` surfaced these internal gaps. Please triage which to settle in the LLD now vs. defer as open questions:

1. **Unknown or invalid `base_revision_id` on submission**: What happens when a submission arrives for an unknown `visit_id` with a non-null `base_revision_id`, or for an existing `visit_id` with a `base_revision_id` not in that visit's history — rejected, or accepted as a competing revision?
2. **`current_revision` vs. `competing_revisions` on multi-step divergence**: If a `clean` visit with history `R1 -> R2 -> R3` receives a competing submission based on `R1` (or `null`), does `current_revision` stay `R3` (duplicating an entry in `competing_revisions`), roll back to the shared base `R1`, or become `null`?
3. **Edits chained on top of a pending competing revision**: When a visit is `unresolved` with pending competing revision `R2` and a new submission arrives with `base_revision_id: R2`, does `R2` stay in `competing_revisions` alongside the new revision or does the new revision supersede `R2` in the pending set?
4. **Conflict reopening after coordinator resolution**: After resolution `R4` returns a visit to `clean`, if a late submission arrives based on an earlier revision (`R1` or a previously resolved `R2`), does `R4` enter `competing_revisions` alongside the late submission, and what does `current_revision` point to while unresolved?
5. **Idempotency key scoping and retry response staleness**: Is `idempotency_key` scoped globally, per authenticated actor, per operation type, or per `visit_id`? On an identical retry after the visit's status has changed, does `visit_status` return the original acceptance snapshot or the visit's current state?
6. **Equivalence rules for idempotency matching**: On retry, are differently ordered arrays (`contributing_revision_ids`, `observers`, `species_cover`) or duplicate IDs in `contributing_revision_ids` treated as identical or rejected as a mismatch?
7. **Concurrent operations on the same `visit_id`**: What per-visit serialization/atomicity invariant governs simultaneous submissions (e.g., two initial creations for the same `visit_id`), a submission racing a coordinator resolution, or two concurrent coordinator resolutions?
8. **`plot_id` mutability and payload boundary rules**: Is `plot_id` immutable after visit creation, or can a later revision/resolution change it? Which field boundary cases (empty `observers`, empty `species_cover`, null vs. omitted `notes`, out-of-range `observation_date`) trigger rejection?
9. **Resolution response shape, history fields, and timestamp ties**: What fields does an accepted resolution return, what value (if any) does a resolution revision store for `base_revision_id` in history, and how are identical `receipt_time` values ordered in history retrieval?

---

### Coherence Note

`docs/high-level-design.md` (Architecture table and concurrency paragraph) and `docs/intent/site-catalog/site-catalog-design.md` (Offline Distribution) still note the `record-store` concurrency choice as open/pending. Let me know if you want those status notes updated once this LLD is settled.

**Next step (Phase 2 stop):** Review `docs/intent/record-store/record-store-design.md`, let me know your answer on the decision doc offer and the 9 probe items above, and confirm when you're ready to cascade into Phase 3 (`docs/intent/record-store/record-store-specs.md`).