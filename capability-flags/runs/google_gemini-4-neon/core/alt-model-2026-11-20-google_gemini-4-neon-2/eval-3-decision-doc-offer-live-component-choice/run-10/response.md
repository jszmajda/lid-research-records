Updated `docs/intent/record-store/record-store-design.md` around whole-visit revisions.

### Summary of `record-store-design.md`
- **Immutable revisions & visit states:** Every worker submission and coordinator resolution is stored as an immutable revision (`revision_id`, `visit_id`, `base_revision_id`, `origin`, `author_id`, `received_at`, `idempotency_key`, `payload`, plus resolution provenance). Visits derive two states from active heads: `current` (single active head, export-eligible) and `needs_review` (two or more competing heads, held out of the Friday CSV).
- **Concurrency rules:** Fast-forward edits matching the sole active head advance `current_revision_id`; stale-base or duplicate-creation submissions become active competing heads in `needs_review`; edits based on a competing head advance that branch while keeping `needs_review`; unknown `base_revision_id` values are rejected.
- **Operations contract:** Defines `submit_revision`, `get_visit`, `list_visits`, `get_visit_history`, and `resolve_visit` (which requires an exact `contributing_revision_ids` match so a newly arrived offline edit is never silently closed out).
- **Downstream obligations:** Records the contract obligations for `tablet-sync` and `review-export` without crossing into their design docs.
- **Decisions & Alternatives:** Records whole-visit revisions, optimistic head-set matching on resolution, and immutable revision persistence.

*(Left `docs/intent/record-store/record-store-specs.md`, `docs/high-level-design.md`, and sibling nodes untouched pending Phase 2 review.)*

---

### Decision Doc Offer
Whole-visit revisions vs. field-aware three-way merge trades multiple criteria (review volume vs. merge-rule maintenance and preserving whole-visit scientific intent), `tablet-sync` and `review-export` will be sized around it, and a cold reader seeing manual review triggered by disjoint field edits could plausibly question or try to reverse it.

Would you like me to record this as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from `record-store-design.md`), or keep just the `Decisions & Alternatives` table row?

---

### Phase 2 Edge-Case Probe (`record-store`)
Please triage which of these gaps should be specified in `record-store-design.md` now vs. deferred to Open Questions:

1. **Idempotency key scoping and replays:** What is the scope of `idempotency_key` (global, per-author, or per-visit), and if an accepted `submit_revision`/`resolve_visit` is replayed after the visit's state has moved on, should it return the original acceptance snapshot or current visit state?
2. **Concurrent write races:** Should per-`visit_id` mutations be serialized so simultaneous submissions on the same `base_revision_id` (or a `submit_revision` racing `resolve_visit`) deterministically fork into `needs_review` or reject with a conflict?
3. **`plot_id` mutability and archived plots:** Can a subsequent revision change a visit's `plot_id`, and should submissions referencing an archived catalog `plot_id` be accepted (e.g., delayed edits to older visits) or rejected?
4. **`resolve_visit` input edge cases:** What happens if `resolve_visit` is called on a `current` visit, supplies both or neither of `selected_revision_id` and `payload`, or points `selected_revision_id` outside `contributing_revision_ids`? Also, should `base_revision_id` on a `coordinator_resolution` be `null`?
5. **Role authorization boundaries:** Which roles can call each operation (e.g., coordinators only for `resolve_visit`, any authenticated worker for `get_visit`/`get_visit_history`/`list_visits`)?
6. **Payload validation constraints:** Which fields of `VisitPayload` are required vs. optional (e.g., empty `observers`, empty `species_cover`, duplicate species, `notes`), and does a custom coordinator `payload` in `resolve_visit` use the exact same validation rules as `submit_revision`?
7. **Ordering and pagination:** How should `get_visit_history` break ties on identical `received_at` timestamps or branched lineages, and how should `list_visits` order/paginate when visits transition between `current` and `needs_review`?
8. **Rejection error shapes:** Should the LLD define structured error codes/payloads for each rejection path (e.g., returning current `competing_revision_ids` on a `resolve_visit` head-set mismatch)?

---

**Phase 2 stop:** Please let me know:
1. Any edits to `docs/intent/record-store/record-store-design.md`,
2. Whether you want the decision doc or just the Decisions & Alternatives row, and
3. Your triage on probe items 1–8.

Once approved, I'll move to Phase 3 (updating `docs/intent/record-store/record-store-specs.md` and clearing the open-choice note in `docs/high-level-design.md`).