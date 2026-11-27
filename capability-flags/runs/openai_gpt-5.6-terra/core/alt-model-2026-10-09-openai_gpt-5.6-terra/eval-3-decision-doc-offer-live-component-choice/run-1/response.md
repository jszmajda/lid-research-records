**Phase 2: Record-Store LLD Draft**

I updated:

- `docs/high-level-design.md` to record that `record-store` uses whole-visit revisions.
- `docs/intent/record-store/record-store-design.md` with the selected concurrency design.

The record store now defines:

- Immutable, complete visit revisions with provenance and base revision IDs.
- Automatic advancement only for an edit based on the current resolved revision when no review is open.
- Competing revisions for stale-base or review-open submissions, without changing the current resolved revision.
- Coordinator outcomes that select a revision, record the considered competitors, and cannot silently absorb a submission that arrives during review.
- Explicit `resolved` and `review-required` states.
- Requirements tablet sync and review/export will inherit later, without designing those nodes yet.

The LLD is consistent with the HLD. The existing `REC-*` specs are now incomplete relative to this design; I have not changed them because Phase 3 follows your approval of this LLD.

**LLD Questions To Resolve**

1. May a coordinator create a new complete resolution revision, or must they select one already accepted revision?
2. Should an idempotency key be unique globally, per authenticated worker, or per tablet?
3. Can a correction move an existing visit to a different plot UUID, or must a visit’s plot UUID remain fixed after its first revision?
4. When a coordinator resolves review work, must their outcome cover every currently open competing revision, rejecting a stale or partial outcome, or may they resolve a selected subset and leave the remainder open?

A full decision document is warranted because this policy shapes both future `tablet-sync` and `review-export` designs and a future reader could reasonably reconsider it. Should I add `docs/intent/record-store/decisions/whole-visit-revisions.md`, or retain the rationale only in the LLD’s Decisions & Alternatives table?

Please approve or revise the LLD and answer the questions above.