**Phase 2: Record-Store Design**

Updated `docs/intent/record-store/record-store-design.md` with the whole-visit revision design:

- A submission creates an immutable, complete visit revision with its base revision, author, receipt time, and idempotency identity.
- A submission based on the selected current revision becomes current only while the visit has no unresolved review work.
- A stale-base submission, or any submission while review is already pending, is retained as a complete competing revision and places or keeps the visit in `needs-review`.
- A coordinator resolves review by selecting one retained revision as current. The store retains all alternatives and the resolution provenance; it never synthesizes a field-level composite or uses receipt order as authority.
- `tablet-sync` must retain and submit base revision IDs, preserve idempotency keys for retries, and surface review-required outcomes.
- `review-export` must compare complete revisions, submit selection-based resolutions, preserve resolution provenance, and exclude every `needs-review` visit from the reviewed CSV.

The LLD records field-aware three-way merge as the credible alternative: it could reduce review volume by automatically combining unrelated edits, but would require maintained rules for scalar fields, observer lists, and species entries. Those rules could combine scientifically related changes without recognizing the relationship, so whole-visit preservation takes priority.

**LLD Edge-Case Probe**

Please triage these design gaps before I turn the LLD into EARS requirements:

1. **Initial-create race:** If two tablets first submit the same client-generated visit UUID concurrently, should one create the visit and the other become a competing revision, or should the second be rejected?
2. **Submission classification race:** Should submission acceptance and coordinator resolution serialize per visit, so an incoming revision is classified against one atomic current/review state?
3. **Review scope:** Does a resolution select a current revision and clear all competing revisions known at that moment, or may it resolve only selected alternatives while keeping the visit in review?
4. **Resolution concurrency:** Should a resolution require the reviewer to name the review state they inspected, rejecting it if new competing revisions arrived or another coordinator resolved it first?
5. **Resolution retries:** Should resolutions have idempotency keys like submissions, and should a retry return its original resolution result?
6. **Revision eligibility:** May a coordinator select any retained revision for that visit, including the previously current one, but never a revision from another visit?
7. **Review-cycle audit:** When a later stale submission creates review work after an earlier resolution, should the store create a distinct review cycle with its own complete set of contributing revisions?
8. **Idempotency scope and duration:** Is a submission idempotency key unique per authenticated worker, per tablet, or globally; and must it remain usable indefinitely for the season?
9. **Retry result:** When a submission retry happens after later activity, should it return its original acceptance-time result, or also return the visit’s latest state separately?
10. **Record validation:** Which scientific constraints belong in the store beyond types and a valid plot ID: required observer names, unique species entries, cover-estimate bounds, or others?
11. **Retrieval contract:** Must retrieval expose a consistent visit-and-history snapshot/version when submissions or resolutions may arrive concurrently?
12. **Authorization and errors:** Which roles may retrieve revision history and resolve review, and do tablet-facing API errors need a stable machine-readable code taxonomy now or can that wait for tablet-sync?