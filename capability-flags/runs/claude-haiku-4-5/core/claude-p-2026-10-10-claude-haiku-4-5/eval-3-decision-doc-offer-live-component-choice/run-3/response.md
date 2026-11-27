## Phase 2: LLD Update — Whole-Visit Revisions Design

I've updated the record-store design with the whole-visit revisions choice fully specified. Here's what's now defined:

**Submission Envelope** — A submission carries: visit_id (UUID), base_revision_id (what state the worker was editing), submitted_state (complete visit), author_id, idempotency_key, and submitted_at. Each submission gets a unique generated revision_id.

**Current-State Response** — Retrieval returns: current_revision_id, current_state, unresolved_flag (true if competing submissions exist), and competing_revision_ids with full metadata so coordinators can compare.

**Resolution** — A coordinator selects one competing submission as the winner. That selection is immutable and records which revisions it supersedes. Future submissions on a resolved visit create new conflicts.

**Storage** — All submitted revisions are kept; nothing is discarded. A visit progresses from submission → possibly unresolved → resolved, and can return to unresolved if new submissions arrive.

### LLD-level edge-case probe

Before you review, here are questions an implementer might hit:

1. **Invalid base reference** — What if a submission names a base_revision_id that doesn't exist? Reject or accept as a fresh submission?
2. **Ordering of competing revisions** — When returning competing_revision_ids, should they be sorted by submission time, author, or left in storage order?
3. **Coordinator role model** — How does "coordinator" authenticate, and is it a separate identity type from workers, or a privilege check on a worker ID?
4. **Single-submission unresolved state** — By design, can a visit be marked unresolved by one worker submitting twice? (Current design requires two submissions from the same base — so no.)
5. **Lifecycle of unresolved visits** — Is there a retention or auto-resolution window, or do unresolved visits persist until manually resolved?
6. **Post-resolution new submission** — If a new submission arrives with base_revision_id matching a superseded revision, the visit becomes unresolved again. Is that the right behavior, or should late submissions be rejected?

Does the design read clearly? Any of these edge cases need an explicit answer before specs are finalized?