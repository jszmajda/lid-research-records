I have authored the standalone decision doc at `docs/intent/record-store/decisions/concurrency-model.md` and linked it from the Decisions & Alternatives table in `docs/intent/record-store/record-store-design.md`.

### Summary of Additions
- **Context & Elements**: Evaluates whole-visit revisions against zero silent data loss, offline independence, scientific intent preservation, operational simplicity, review volume, and storage efficiency.
- **Why Field-Aware Merge Remains Credible**: Details the strong honest case for three-way merging (minimizing review queues and bandwidth) and sets explicit revisit triggers (e.g. scale expansion beyond coordinator capacity or decoupling into independent sub-surveys).
- **Downstream Accommodations**:
  - `tablet-sync`: Stores server-assigned revision IDs, captures immutable `base_revision_id` on local drafts, surfaces `in_review` status without local three-way merging, and maintains idempotency retries.
  - `review-export`: Implements side-by-side whole-visit revision comparison, resolution provenance capture (coordinator ID, notes, selected/composite revision), and gates Friday CSV export to exclude `in_review` visits.

The record-store LLD and decision doc are complete. Are you ready to proceed to **Phase 3 (EARS spec update)** to update `docs/intent/record-store/record-store-specs.md`, or would you like to incorporate any specific edge-case rulings from the probe first?