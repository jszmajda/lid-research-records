**Phase 1 — HLD check**

Updated `docs/high-level-design.md`: the record-store row is now `Drafted` rather than `Drafted; concurrency choice open`, and the downstream note now says tablet-sync and review-export follow record-store’s submission/revision contract. No architectural change was needed; concurrency remains owned by record-store.

**Phase 2 — Record-store LLD**

Drafted `docs/intent/record-store/record-store-design.md`. It now defines:

- **Immutable revision tree per visit** — every accepted submission creates one complete revision with a parent revision, author, submission ID, and receipt time. Revisions are never merged, overwritten, or deleted.
- **Submission envelope** — `visit_id`, `base_revision_id` (omitted only for the first submission), `idempotency_key`, and the complete visit payload. Validation covers field types, plot reference, base ownership, missing/unknown bases, and retry conflicts.
- **Acceptance behavior** — a base equal to the current revision advances it; any other known revision creates a competing candidate. Stale bases are accepted into review rather than rejected.
- **Unresolved-work model** — candidate revisions are undismissed leaf revisions; a visit is unresolved when more than one exists. While unresolved, the current revision is an operational base but not scientifically authoritative.
- **Retrieval** — current state returns the current payload, unresolved flag, and full candidate set; history returns revisions with parent links, original submission envelopes, and resolution records; unresolved-visit listing supplies the review queue.
- **Resolution** — a coordinator selects one existing candidate; the reviewed set must exactly match the live candidate set. Stale reviews are rejected, and resolution is atomic and idempotent.
- **Decisions table** recording whole-visit revisions against field-aware merge, plus stale-base handling, provisional current state, resolution semantics, and retry protection.

**Edge-case probe**

A cold probe against the LLD alone surfaced ten gaps. I settled these in the draft: the contradictory base-revision requirement; which fields count as payload for idempotency; whether retries replay the original or live state; idempotency precedence over the stale-review check; resolution of an already-resolved visit; resolution atomicity against concurrent submissions/resolutions; error shapes and validation order; non-leaf bases; unknown visit IDs; and revision-history shape and ordering.

Four items remain deferred in the LLD:

1. Recovery when two tablets submit a first revision for the same visit ID; the second is rejected and tablet-sync must fetch and resubmit.
2. Revision-history retention and compaction.
3. The source of coordinator-role membership.
4. Whether a visit’s `plot_id` may be corrected between revisions.

**Review**

1. Approve this LLD, or give numbered feedback.
2. Should the concurrency choice be recorded as a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or is the Decisions table row sufficient?
3. Are the four deferred items acceptable as written?

I’ll stop here before drafting the EARS specs.