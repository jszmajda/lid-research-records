Added [the decision document](docs/intent/record-store/decisions/whole-visit-revisions.md) and linked it from record-store’s Decisions & Alternatives table.

It covers:
- Why scientific integrity and merge-rule maintenance favor whole-visit revisions.
- Why field-aware merging remains credible if review volume becomes impractical.
- The tablet’s base-revision, complete-snapshot, retry, and reconciliation obligations.
- Revision comparison, provenance, stale-review handling, and unresolved-visit exclusion for review/export.

`git diff --check` passes.

Does this capture the trade-off accurately? To finish the resolution contract, should coordinators **only select an existing revision**, or **also be able to author a complete replacement snapshot**?