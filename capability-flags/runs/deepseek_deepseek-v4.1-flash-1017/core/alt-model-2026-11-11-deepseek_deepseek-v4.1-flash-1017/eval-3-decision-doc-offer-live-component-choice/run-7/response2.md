Wrote `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the LLD’s decisions table and references.

It covers:

- Why whole-visit revisions win on scientific integrity and merge maintenance, and why the larger review queue is the accepted cost.
- Why field-aware three-way merge remains credible: it is the fallback if the queue persistently exceeds coordinator capacity, or if the science team establishes stable validated merge rules. Switching later would require base snapshots and structured changes in the envelope, tablet-side snapshot retention, and field-level export provenance.
- What downstream work must accommodate: tablet-sync retains base revision IDs, submits complete visits, uses idempotency keys, displays unresolved status, and recovers rejected duplicate first submissions; review-export compares whole revisions, resolves with the reviewed candidate set, excludes unresolved visits from the CSV, and retains resolution provenance; record-store keeps immutable revisions and resolution records.

Two checks before I draft the EARS specs:

1. Approve the LLD and decision doc as written, or give numbered changes?
2. Are the four deferred items still acceptable: duplicate-first-submission recovery, revision retention/compaction, coordinator-role source, and `plot_id` correction between revisions?