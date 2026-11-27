The record-store low-level design (`docs/intent/record-store/record-store-design.md`) has been updated with the whole-visit revisions concurrency architecture, including revision lineage rules, submission envelopes, state models (`clean`, `conflicting`, `resolved`), coordinator resolution workflows, and downstream obligations for `tablet-sync` and `review-export`. The architecture table in `docs/high-level-design.md` has been updated accordingly.

---

### Decision Doc Selection

The concurrency model decision has been recorded in the `Decisions & Alternatives` table of `record-store-design.md`. Because this choice traded competing architectural approaches against multiple criteria and directly sizes downstream contracts (`tablet-sync` and `review-export`), would you like this memorialized as a standalone decision doc (`docs/intent/record-store/decisions/concurrency-model.md`), or does the LLD table row suffice?

---

### Phase 2 Edge-Case Probe (Gaps for Triage)

An internal component probe surfaced the following edge cases and underspecified behaviors within `record-store`. Please indicate which should be incorporated into the LLD before Phase 3 versus deferred to implementation:

1. **Root collisions & invalid parentage**:
   - What status code/error is returned if an initial submission (`base_revision_id: null`) arrives for an already existing `visit_id`?
   - How should the server reject submissions referencing nonexistent `base_revision_id`s or a `base_revision_id` belonging to a different `visit_id`?
2. **Post-resolution branching & late edits**:
   - If a tablet submits an edit whose base revision is a superseded competing branch after a coordinator has resolved the visit, does the visit re-enter `conflicting` status, or is the submission rejected?
   - When a new submission builds directly on a `resolved` revision (`base_revision_id == resolved_revision_id`), does visit status stay `resolved` or transition to `clean`?
3. **Partial resolution & coordinator races**:
   - If a third concurrent revision arrives while a coordinator is reviewing two competing revisions, does resolving the first two leave the third competing, or must `POST /visits/{visit_id}/resolve` require an exact match against all active leaves?
   - Should `POST /visits/{visit_id}/resolve` accept an `idempotency_key` to guard against duplicate resolution submissions on connection drop?
4. **Domain validation rules**:
   - Should the LLD explicitly constrain species records (e.g. unique `species_id` per visit, cover percentage bounds $0 \le x \le 100$) and observer lists (non-empty)?

---

Please provide your feedback and guidance on the decision doc offer and gap triage to approve Phase 2 before proceeding to Phase 3 (EARS update).