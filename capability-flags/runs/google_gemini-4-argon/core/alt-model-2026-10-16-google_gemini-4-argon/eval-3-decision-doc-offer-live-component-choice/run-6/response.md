I have updated `docs/intent/record-store/record-store-design.md` (and marked `record-store` as `Drafted` in `docs/high-level-design.md`) to finalize the whole-visit revision design.

### 1. Decision Doc Offer

Because the concurrency choice between whole-visit revisions and field-aware three-way merge is a load-bearing trade-off across multiple criteria (scientific field coupling, coordinator review burden, maintenance of merge rules) that `tablet-sync` and `review-export` are sized around, a future cold reader could be tempted to re-litigate it.

Would you like to record this in a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD's `Decisions & Alternatives` table), or is the `Decisions & Alternatives` table row in `record-store-design.md` sufficient?

---

### 2. Updated `record-store` LLD (`docs/intent/record-store/record-store-design.md`)

- **Submission Envelope & Revision Graph**: Every submission supplies `idempotency_key`, `visit_id`, `base_revision_id` (`null` for initial creation), and full visit `payload`. Accepted submissions create immutable revisions with server-assigned `revision_id`, `author_id`, `received_at`, and `parent_revision_ids`:
  1. **Initial creation (`base_revision_id: null`)**: Creates the sole active head (`status: current`) if `visit_id` is new, or adds a competing root head (`status: needs_review`) if `visit_id` already exists.
  2. **Fast-forward update**: When `base_revision_id` matches the sole active head of a `current` visit, the new revision replaces it as the sole active head (`status: current`).
  3. **Concurrent / branched update**: When `base_revision_id` references an existing revision that is not the sole active head, the new revision is added to `active_heads` and the visit enters `status: needs_review`.
  4. **Unknown base revision**: Rejected if `base_revision_id` does not exist on that visit.
- **Current-State & Unresolved-Work Representation**: Visit retrieval and status-filtered listing return `visit_id`, `status` (`current` | `needs_review`), `current_revision` (the single active revision when `current`, or `null` when `needs_review`), and `active_heads`. Revision-history retrieval returns the full revision DAG ordered by `received_at` (with `revision_id` tie-breaker).
- **Coordinator Resolution**: Takes `visit_id`, `resolved_revision_ids`, reconciled `payload`, and optional `resolution_note`. Requires `resolved_revision_ids` to match the visit's current `active_heads` set so a newly arrived worker edit is never silently overwritten; creates a new revision with `parent_revision_ids = resolved_revision_ids` as the sole active head and transitions the visit to `status: current`.
- **Downstream Contract Obligations**: Captures the obligations cascading to `tablet-sync` and `review-export`.

---

### 3. Phase 2 LLD Edge-Case Probe

Please let me know which of these LLD edge cases you want to specify in `record-store-design.md` now vs. defer as open questions before we move to Phase 3 (EARS specs):

1. **Linear edit on top of one competing head**: If a visit is already in `needs_review` with `active_heads: [A, B]` and a worker submits `A'` with `base_revision_id: A`, should `A'` replace `A` in `active_heads` (yielding `[A', B]`), or remain additive alongside `A` (`[A, B, A']`) until coordinator resolution?
2. **Plot reference rules across revisions and archived plots**:
   - Should `record-store` accept submissions referencing an `archived` plot in `site-catalog` (since a tablet may have captured the visit offline before archival or be editing an older visit)?
   - Can a subsequent revision or coordinator resolution change a visit's `plot_id`, or is `plot_id` immutable once a visit is created?
3. **Coordinator resolution idempotency and preconditions**: Should the coordinator resolution request also carry an `idempotency_key` (or return idempotently if retried) and be restricted strictly to visits currently in `status: needs_review`?
4. **Idempotency key scope and retry response**: Should `idempotency_key` uniqueness be scoped globally or per worker, and if a retry arrives after a later edit has transitioned the visit to `needs_review`, should the retry response return the visit status at original acceptance time or current status?
5. **Payload validation boundaries**: Beyond basic field types and `plot_id` existence in `site-catalog`, should `record-store` enforce structural constraints on `payload` (e.g., non-empty `observers`, `species_cover` percentages in `0..100`, non-duplicate species entries), or leave domain checks out of the store?

Once you let me know your preferences on the decision doc and how you'd like to triage items 1–5, I will incorporate your feedback and proceed to Phase 3 (`record-store-specs.md`).