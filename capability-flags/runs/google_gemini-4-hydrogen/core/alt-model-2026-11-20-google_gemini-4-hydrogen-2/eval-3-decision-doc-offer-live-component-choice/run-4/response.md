I have updated `docs/intent/record-store/record-store-design.md` to settle on **whole-visit revisions** and define the downstream contract (`Submission Envelope and Validation`, `Current-State Retrieval and Unresolved Work`, `Resolution Operation`, and `Decisions & Alternatives`), and updated the `record-store` status to `Drafted` in `docs/high-level-design.md`.

Before moving to Phase 3 (EARS spec updates in `docs/intent/record-store/record-store-specs.md`), please review two items:

### 1. Decision Doc Offer
Because both concurrency options were credible against multiple criteria and `tablet-sync` and `review-export` will be sized around this choice, would you like me to record this decision as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from `record-store-design.md`), or is the current row in `Decisions & Alternatives` sufficient?

### 2. LLD-Level Edge-Case Probe (for triage: fix in LLD vs. defer)
1. **Extending an active competing head:** What happens when a submission's `base_revision_id` points to one of the active `competing_revisions` (or to `current_revision` while the visit is already `unresolved`)—does it replace that branch head or add another parallel head?
2. **Simultaneous per-visit requests:** What concurrency/serialization invariant prevents two simultaneous requests for the same `visit_id` (e.g., two `base_revision_id: null` creates, or a concurrent submission and a resolution) from racing?
3. **Resolution retry idempotency:** `Resolution` has no `idempotency_key`; if a coordinator's resolution request times out after succeeding, a retry will get `409 Conflict` once `competing_revisions` is cleared.
4. **Invalid resolution targets:** What status codes/behaviors apply when a coordinator resolves a non-existent `visit_id`, an already-`resolved` visit, or a `selected_revision_id` not in `contributing_revision_ids`?
5. **Coordinator-authored payload validation & `plot_id` immutability:** Does `mode: "author"` run the same field/catalog validation as worker submissions, and is `plot_id` immutable across revisions of a `visit_id`?
6. **Error payload schema and status codes:** Multiple distinct failures map to `409 Conflict` (idempotency mismatch, duplicate `base_revision_id: null`, stale `contributing_revision_ids`), and auth/GET/validation error shapes are not yet specified.
7. **Idempotency key scoping & canonicalization:** Is `idempotency_key` scoped per `author_id`, what happens if a key is reused after a *rejected* request, and how is payload equality defined (e.g., JSON key/array order, optional `notes`)?
8. **New visit on an archived plot:** Can a brand-new `visit_id` (`base_revision_id: null`) reference an archived `plot_id` (e.g., a tablet with a stale cached catalog), or is archival only allowed for edits to existing visits?
9. **History ordering & resolution schema:** What deterministic tie-breaker orders `GET /visits/{visit_id}/history` if timestamps match, and what exact fields appear on a resolution record?
10. **Field-level validation bounds:** Can `species_cover` be empty (zero-cover plot), what value formats/ranges are valid, and is `notes` optional/nullable?

Let me know:
1. Whether you want a standalone decision doc or just the `Decisions & Alternatives` row.
2. Which probe items (if any) to fold into `record-store-design.md` vs. defer.
3. Whether you approve `record-store-design.md` to proceed to Phase 3 (EARS specs).