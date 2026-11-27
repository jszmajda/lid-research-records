Written up as a full decision document:

- `docs/intent/record-store/decisions/whole-visit-revisions.md`

It records:

- The scientific-coherence, review-workload, maintenance, provenance, and offline-sync tradeoffs.
- The strongest case for field-aware three-way merge.
- Concrete conditions under which we should reconsider it: recurring Friday export delays, mostly disjoint conflicts, or coordinator effort outweighing merge-rule maintenance.
- Detailed tablet-sync obligations: base revision IDs, complete payloads, persistent idempotency keys, stale-base branches, unresolved states, and post-resolution bases.
- Detailed review/export obligations: complete-candidate comparison, exact-set resolution, stale-review handling, resolution provenance, and withholding unresolved visits from CSV.

The LLD now links to that decision and records the two accepted choices: plot UUIDs are correctable through later revisions, and every authenticated worker may read and edit every visit.

`git diff --check` passes. Please review the decision document and revised LLD; once approved, I’ll proceed to the Phase 3 EARS updates, leaving tablet-sync and review-export design for later.