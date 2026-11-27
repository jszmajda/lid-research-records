Drafted the whole-visit revision design in `docs/intent/record-store/record-store-design.md` and refreshed the HLD’s record-store status. Tablet-sync, review-export, and the EARS specs remain unchanged pending this review.

The LLD now defines:

- Immutable, complete visit revisions with base revision IDs and idempotent submission.
- Settled versus unresolved visit states; unresolved visits expose no usable current revision.
- Branch-tip candidates grouped into one conflict per visit, including late submissions after resolution.
- Coordinator resolution by selecting one complete candidate—no merged resolution revision.
- Optimistic conflict versions so new submissions cannot be overlooked during review.
- Retrieval, history, review-queue, error, persistence, and atomicity contracts.

The edge-case probe found six gaps for you to triage before I update the EARS specs:

1. **Resolution retries:** If a resolution commits but its response is lost, should an identical retry return the original success, or an already-resolved error? I recommend returning the original success for that exact conflict ID, version, and candidate.
2. **Coordinator authorization:** Should only coordinator roles resolve conflicts? May a coordinator select a revision they authored themselves? The draft currently assumes coordinator-only resolution but no independent-review restriction.
3. **Historical revision content:** Should `GetVisitHistory` include complete scientific snapshots and original payloads for every non-current revision, or only metadata? I recommend complete snapshots and original payloads for auditability.
4. **Initial creation:** Should the first valid null-base submission become current and return `advanced_current`? I recommend yes.
5. **Unknown resources:** Should unknown visit, conflict, or resolution target IDs return a distinct not-found error without changing state? I recommend yes.
6. **Read consistency and ordering:** Should each retrieval return one coherent snapshot, with history ordered by server receipt time? I recommend both; review-queue presentation order remains deferred to review-export.

Please review the LLD and respond with any numbered changes or approvals. After your approval, I’ll incorporate the resolutions and stop again for review of the updated EARS specs.