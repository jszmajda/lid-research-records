Added `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the record-store LLD.

The decision document now records:

- Why whole-visit revisions are selected.
- Why field-aware three-way merge remains a credible alternative.
- The specific scientific-risk tradeoff: field names cannot safely express all relationships between observations.
- Tablet-sync obligations: retain base revision IDs, retry with idempotency keys, preserve local submissions, and show competing-revision outcomes.
- Review/export obligations: compare complete revisions with provenance, record coordinator outcomes, and exclude unresolved visits from the reviewed CSV.

Phase 2 remains open pending these record-store decisions:

1. May a coordinator create a new complete resolution revision, or must they select an accepted revision?
2. Are idempotency keys unique globally, per authenticated worker, or per tablet?
3. May a correction change an existing visit’s plot UUID?
4. Must a review outcome cover every currently open competitor, rejecting stale or partial outcomes?

Please approve the updated LLD and decision document, and answer those four questions before I draft the `REC-*` EARS specifications.