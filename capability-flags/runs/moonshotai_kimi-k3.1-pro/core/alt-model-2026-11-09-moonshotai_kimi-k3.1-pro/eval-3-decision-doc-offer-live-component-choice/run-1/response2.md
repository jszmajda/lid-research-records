Expanded the record-store design and drafted its complete EARS coverage.

The LLD now explicitly documents:

- Why field-aware three-way merge remains worth reconsidering if review workload becomes the dominant cost.
- The scientific risk of automatically combining related observations.
- Tablet-sync obligations: base revision IDs, complete payloads, globally unique keys, exact retry envelopes, review-set reconciliation, and base refresh after resolution.
- Review-export obligations: whole-revision comparison, unresolved-visit exclusion, stale-set refreshes, growing queues, and resolution provenance.
- Deterministic idempotency, concurrent-key handling, snapshot-consistent retrieval, history ordering, resolution retries, error precedence, and review-set ordering.

`record-store-specs.md` now contains 32 active requirements covering submission, concurrency, retrieval, resolution, errors, and provenance.

Consistency check:

- **Coverage:** All behavioral sections of the LLD have corresponding requirements.
- **Contradictions:** None found; resolution retries preserve the original outcome while later submissions follow normal concurrency rules.
- **Scope:** Initial submissions, ordinary edits, pending-review edits, and coordinator-only operations are explicitly distinguished.
- **Cold reading:** Each requirement stands alone; export eligibility is expressed through the record-store contract without designing review-export itself.

Please review the expanded LLD and EARS draft. Once approved, I’ll run the cross-spec intent-narrowing audit before any implementation work.