## Phase 1: HLD Review

Updated `docs/high-level-design.md` to reflect the settled architectural contract:

- `record-store` now records whole-visit revisions as its selected concurrency approach.
- Submissions identify their base revision; competing complete revisions wait for coordinator resolution.
- `tablet-sync` and `review-export` remain intentionally deferred, with their eventual contracts defined by this record-store decision.

The existing HLD tenets support the choice: preserving every submitted edit and keeping the exported state inspectable take priority over automatically merging potentially related scientific changes.

Approve this HLD update to proceed to the record-store LLD design.