## Phase 2: Record-Store LLD Review

Rewrote `docs/intent/record-store/record-store-design.md` with the selected whole-visit revision design.

The design now specifies:

- Immutable complete revisions with server-generated revision IDs, client visit IDs, base revision IDs, author, receipt time, and idempotency key.
- `resolved` visits with one current revision and `needs_review` visits with competing retained revisions.
- A stale-base submission creates review work; arrival order never selects a winner.
- A coordinator resolves a visit by selecting one existing candidate. Resolution neither edits nor merges revisions.
- Submission, retrieval, history, and resolution contract contents.
- Tablet-sync obligations: retain base IDs, send complete payloads, preserve accepted review-pending submissions, and avoid retrying them as failures.
- Review/export obligations: compare full candidate revisions, expose provenance, resolve by selecting a candidate, and withhold `needs_review` visits from CSV export.
- The rationale for retaining field-aware three-way merge as a considered alternative: it would reduce review volume, but maintained merge rules cannot safely recognize scientifically related field changes.

The LLD edge-case probe found these decisions still need your direction before the contract is fully pinned:

1. **Concurrent resolution:** If a coordinator opens a review set and another submission or resolution arrives before they select a candidate, should the resolution reject as stale and require the coordinator to reload, or can it select from the earlier candidate set?
2. **Candidate lifetime:** Should every revision submitted while a visit is `needs_review`, including the previous current revision, remain selectable until that review is resolved? After resolution, should a previously selected revision remain available only as history, not as a candidate for later resolution?
3. **New-visit and base validation:** Should the store reject all of these: a known visit ID with no base revision, an unknown visit ID with a base revision, and a base revision belonging to a different visit?
4. **Idempotency scope and equality:** Should an idempotency key be scoped to the authenticated worker, and should an identical retry mean the same visit ID, base revision ID, and structured payload after canonical serialization?
5. **Result and error contract:** Should the record store expose stable machine-readable error codes for invalid payloads, unknown plots, invalid bases, idempotency mismatch, unavailable candidates, and stale resolution attempts?
6. **Review-pending response:** When a submission creates or joins a review set, should its acceptance response include the current revision ID and the full current candidate ID list, or only identify the stored revision and state?
7. **History consistency:** Should history retrieval return a server-defined chronological order with a stable pagination cursor or snapshot token, so a review screen compares one consistent candidate set?
8. **Authorization boundary:** Should record-store enforce coordinator authorization for resolution and history retrieval, or should review-export be responsible for authorization while record-store accepts an authenticated caller identity?
9. **Historical plot references:** Should a revision remain valid when its plot is later archived, relying on the catalog’s stable UUID rule?

Please approve the LLD and answer these points, or indicate which should remain deferred.