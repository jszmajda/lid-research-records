I've written the decision doc and linked it from the LLD's Decisions & Alternatives row. The 10-item edge-case gap list from before is still waiting on your triage, so I'm holding this phase open on that.

I wrote **docs/intent/record-store/decisions/concurrency-policy.md**. It covers:

- The gate and five weighted criteria (silent-miscombination risk, review workload, maintenance burden, two-coordinator operability, submission footprint), with silent-miscombination risk marked major since it ties to the "inspectable path" tenet.
- Both options analyzed per criterion, each given its strongest honest description.
- **Selection**: whole-visit revisions, with the reasoning tied explicitly to the tenet and the trade you named, accepted knowingly against the review-workload criterion.
- **Why field-aware merging stays worth reconsidering**: if the whole-visit queue actually overwhelms the two coordinators in practice, a narrower merge scoped only to fields with no plausible scientific relationship (e.g. observer-name corrections) could be revisited then — but that narrower version isn't designed here.
- **Downstream obligations**: tablet-sync must track base revision IDs and surface current-vs-competing outcomes to workers; review-export must build the competing-revision queue, full-revision comparison view, resolution call, and the export-exclusion rule — both cascade notes, not co-ownership.

Still outstanding from last time — please triage before I close this phase:

1. Unmatched base revision ID (matches nothing in the chain).
2. "No base" claimed on a visit that already has a chain.
3. Resolution racing a late arrival on the same stale base.
4. Resolution naming a submission ID outside the actual competing set.
5. A third submission based on the pre-competition current revision.
6. Two same-base submissions arriving simultaneously — no tie-break.
7. A resolution picking a revision whose own base was itself superseded elsewhere.
8. Idempotent retry after the chain has moved on — does it replay stale status?
9. Missing/malformed base revision ID on a non-first submission.
10. Resolving a visit with no competing revisions.

Which of these should I fix in the LLD now, and which should go to Open Questions & Future Decisions as deferred?