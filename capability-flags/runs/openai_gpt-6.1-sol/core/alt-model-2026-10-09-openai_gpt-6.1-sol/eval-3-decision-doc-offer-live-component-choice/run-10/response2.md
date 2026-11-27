Created `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the record-store design.

It records:
- Why preserving whole-visit scientific intent outweighs the larger review queue.
- The strongest case for field-aware merging: fewer reviews and better Friday export coverage, balanced against scientific dependencies and ongoing rule maintenance.
- What would justify reconsidering that approach.
- Tablet obligations: base revision IDs, complete snapshots, stable retry keys, and distinguishing acceptance from clearance.
- Review/export obligations: whole-revision comparison, stale-review protection, outcome lineage, and excluding unresolved visits from CSV.

`git diff --check` passed.

To finish the resolution contract, **may coordinators author a complete corrected revision, or must they select an existing candidate?** For example, one submission might have the correct species identification while another has the correct cover estimate. An explicit coordinator-authored revision could capture both while retaining the original submissions.