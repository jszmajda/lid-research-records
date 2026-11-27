Decision doc written at `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked from the record-store LLD’s Decisions table and References.

It covers:

- **The full tradeoff**, with whole-visit revisions and field-aware three-way merge each described at its strongest. The field-aware option stays explicitly credible: lower review volume, smaller submissions, fewer review items, and field-level provenance — but it loses here on merge-rule maintenance and the risk of silently combining scientifically related edits.
- **The selection and its basis**, including why the larger review queue is accepted, which tenets it turns on, and what would reopen the decision.
- **What tablet-sync must accommodate**: retaining base revision IDs, submitting complete visits, idempotency keys, pending competing revisions, unresolved status without a current revision, and explaining later resolutions. It does not need retained base snapshots.
- **What review-export must accommodate**: complete-revision comparison with lineage, baseline and competing revisions, candidate selection, keeping unresolved visits out of the CSV, state-version checks before export, and resolution provenance.

The three edge calls from the previous stop are still as drafted in the LLD: arrival order versus current state, non-selected revisions as later bases, and export staleness. If your “Yeah” covers those and the coordinator-selection write path, say so and I’ll move to Phase 3 and update the EARS specs. Also, `docs/intent/site-catalog/site-catalog-design.md:24` still calls the choice pending; want me to update that sentence too?