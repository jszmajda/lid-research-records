I updated `docs/intent/record-store/record-store-design.md` (and marked `record-store` as `Drafted` in `docs/high-level-design.md`) to complete the **Phase 2 (LLD)** design around **whole-visit revisions**:

- **Whole-Visit Revision Model**: Initial creation (`base_revision_id = null`) and fast-forward updates (matching `current_revision`) advance the resolved state; concurrent edits (mismatched `base_revision_id` or while `review_status = unresolved`) are preserved intact as competing revisions in `pending_revisions` without overwriting `current_revision`.
- **Contracts**: Defined the Submission Envelope (`visit_id`, `plot_id`, `base_revision_id`, `idempotency_key`, `payload` + server-assigned `submission_id`, `revision_id`, `author_id`, `received_at`), Current-State Response (`review_status`, `current_revision`, `pending_revisions`), Submission-History Retrieval, and Resolution Operation (`contributing_submission_ids`, `resolved_payload`, `coordinator_id`, `idempotency_key`).
- **Downstream Obligations & Decisions**: Recorded `tablet-sync` and `review-export` obligations as cascades, and logged the policy choice in `## Decisions & Alternatives`.

### Decision Doc Offer
Because this choice trades competing criteria (review queue size vs. avoiding silent cross-field merge errors) and both `tablet-sync` and `review-export` will be sized around it, would you like me to also record it as a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or is the `Decisions & Alternatives` table row sufficient?

### LLD-Level Edge-Case Probe (for triage: fix in LLD vs. defer)
1. **Unreachable `current_revision = null` state**: Current-State Response mentions `current_revision = null` for "unresolved competing initial submissions," but the revision model says the first `base_revision_id = null` submission immediately sets `current_revision` and `review_status = resolved`.
2. **Unknown or cross-visit `base_revision_id`**: Is a non-null `base_revision_id` that does not exist in that `visit_id`'s history rejected as invalid, or accepted into `pending_revisions`?
3. **`plot_id` mutability across revisions**: Is changing `plot_id` on a subsequent submission for an existing `visit_id` rejected, or allowed (and if allowed, where is current `plot_id` returned)?
4. **Submission validation and error shapes**: What error shapes/codes apply for auth failure, malformed fields, unknown `plot_id`, or invalid `payload`?
5. **`idempotency_key` scoping and envelope equality**: Is `idempotency_key` scoped globally, per `author_id`, or per `visit_id`, and does equality check the full envelope (`visit_id`, `plot_id`, `base_revision_id`, `payload`) or only `payload`?
6. **Idempotent retry after state advancement**: If an accepted `idempotency_key` + identical payload is retried after the visit's `current_revision` or `review_status` has moved on, does it return the original acceptance result verbatim?
7. **Concurrent fast-forward race**: What serialization invariant guarantees that two simultaneous submissions with the same matching `base_revision_id` result in one fast-forward and one `pending_revisions` entry?
8. **Non-existent `visit_id` on retrieval**: What response or error shape is returned by Current-State and Submission-History retrieval for an unknown `visit_id`?
9. **`pending_revisions` shape and timestamp ties**: What exact fields and ordering apply to `pending_revisions`, and how are `received_at` ties ordered in Submission-History?
10. **Resolution visibility in submission history**: Are coordinator resolutions included in Submission-History retrieval (so workers can trace a `base_revision_id` that came from a resolution) or stored separately?
11. **Partial `contributing_submission_ids` on resolution**: If a resolution addresses only a subset of `pending_revisions` (e.g., a new competing submission arrived during review), does `current_revision` advance while `review_status` stays `unresolved`, or is the resolution rejected?
12. **Invalid resolution preconditions**: What happens when a resolution targets a non-existent visit, an already-`resolved` visit, an empty/duplicate `contributing_submission_ids` list, an ID not in `pending_revisions`, an invalid `resolved_payload`, or a non-coordinator caller?
13. **Resolution `idempotency_key` and `current_revision` fields**: Does resolution share the submission `idempotency_key` space, and do `current_revision.author_id` / `received_at` reflect `coordinator_id` and resolution time?

Please review the updated `record-store-design.md`, let me know which probe items to fix in the LLD vs. defer, whether you want the decision doc, and whether we're approved to proceed to **Phase 3 (EARS spec updates in `record-store-specs.md`)**.