I have written and linked the decision doc at `docs/intent/record-store/decisions/concurrency-model.md`.

It covers:
- **Core trade-offs**: Whole-visit revisions vs. field-aware three-way merging evaluated against TidePlot tenets (preserving submitted edits, explainable/inspectable lineage, and operation by two coordinators without dedicated admin support).
- **Reconsideration triggers**: Specific conditions under which field-aware merging would be reconsidered (scaling to 100+ field workers where revision volume exceeds coordinator triage capacity, shifting toward purely administrative/uncoupled edits, or introducing programmatic botanical validation).
- **Downstream obligations**:
  - `tablet-sync`: Storing and submitting `base_revision_id`, conflict detection on sync, pausing further local branching while a visit is under review, and managing UUID idempotency keys.
  - `review-export`: Enforcing the export eligibility gate (`status == "conflicting"` strictly excluded from the Friday CSV), side-by-side whole-visit revision comparison UI, and coordinator resolution submission to the record store.

The decision has also been linked in the `Decisions & Alternatives` table of `docs/intent/record-store/record-store-design.md`.

With the record-store design and its decision documentation complete, do you approve this Phase 2 artifact to proceed to Phase 3 (updating `record-store-specs.md` with the new EARS requirements)?