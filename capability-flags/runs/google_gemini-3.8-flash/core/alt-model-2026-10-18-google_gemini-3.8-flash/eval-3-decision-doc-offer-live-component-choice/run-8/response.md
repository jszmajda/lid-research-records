### Phase 2: Record Store LLD Update

`docs/intent/record-store/record-store-design.md` has been updated to specify the **whole-visit revisions** concurrency model, define the submission envelope and API contracts, and establish downstream obligations for `tablet-sync` and `review-export`. `docs/high-level-design.md` was updated to reflect that `record-store` is drafted.

#### Key Updates in `docs/intent/record-store/record-store-design.md`
- **Data Model & Envelope**: Visits are identified by `visit_id` referencing a `plot_id`. The submission envelope requires `idempotency_key`, `base_revision_id` (`null` for creation), and the complete visit payload (`observation_date`, `observers`, `species_records`, `notes`).
- **Concurrency & Lifecycle**: Linear edits fast-forward `current` state. Submissions referencing superseded base revisions trigger branch detection, retaining all submissions intact and placing the visit into `in-review`.
- **API Operations**: Specified contracts and idempotency behavior for `Submit Revision`, `Get Current Visit`, `Get Revision History`, and `Resolve Conflict`.
- **Downstream Contracts**: Formulated obligations for `tablet-sync` (tracking base revision IDs, preventing silent local merges) and `review-export` (side-by-side comparison, coordinator resolution, holding `in-review` visits out of the Friday CSV export).
- **Decisions & Alternatives**: Added rationale recording the selection of whole-visit revisions over field-aware 3-way merge.

---

### LLD Edge-Case Probe (Gaps for Triage)

The following edge cases were identified for `record-store`. Please indicate which should be specified now in the LLD versus deferred:

1. **Submissions against an `in-review` visit**: When a submission arrives whose `base_revision_id` points to one of the competing revisions (or an older ancestor) while the visit is already `in-review`, does the server append it to the competing set, or reject it until the conflict is resolved?
2. **Concurrent submission during conflict resolution**: If a worker submission is accepted while a coordinator is resolving an existing conflict, does the resolution fail with HTTP 409 Conflict (requiring re-review), or partially resolve while leaving the visit in `in-review` with the new submission?
3. **Duplicate creation with `base_revision_id: null`**: If a new submission with `base_revision_id: null` arrives for an existing `visit_id` under a new idempotency key, should it be rejected (HTTP 409) or treated as a competing root branch?
4. **Invalid or foreign `base_revision_id`**: If a submission supplies a non-existent `base_revision_id` or one belonging to a different `visit_id`, should the API return HTTP 400 Bad Request, 404 Not Found, or 422 Unprocessable Entity?
5. **Edits against resolved/superseded ancestors**: When a delayed offline tablet submits against an ancestor revision that was already resolved in a prior cycle, does the visit re-enter `in-review`, or is the submission rejected as a stale branch?
6. **Reconciled resolution lineage**: When a coordinator authors a new reconciled payload rather than picking an existing revision, should the new revision's `base_revision_id` reference the common ancestor, or should the model explicitly support multi-parent provenance linking all contributing revision IDs?

---

### Decision Doc Option

The concurrency choice (Whole-visit revisions vs. Field-aware three-way merge) has been recorded in the LLD's Decisions & Alternatives table. Because this decision shapes both `tablet-sync` and `review-export`:
- Would you like a dedicated decision doc created under `docs/intent/record-store/decisions/` laying out the criteria and analysis, or is the Decisions & Alternatives table row sufficient?

---

*Awaiting your feedback on the LLD design, gap triage, and decision doc preference before proceeding to Phase 3 (EARS specs).*