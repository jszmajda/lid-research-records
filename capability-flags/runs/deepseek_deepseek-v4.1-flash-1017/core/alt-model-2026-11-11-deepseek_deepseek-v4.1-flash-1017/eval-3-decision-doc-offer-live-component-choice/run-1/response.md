The record-store design is finished and ready for review.

**Changed**
- `docs/high-level-design.md` — record-store state now records whole-visit revisions; the dependency note points at the completed contract.
- `docs/intent/record-store/record-store-design.md` — replaced the open-choice section with the full contract.

**Design in brief**
- Every accepted submission is one immutable, complete visit revision: revision ID, visit ID, base revision ID, author, server receipt time, and the full visit payload.
- Base = current revision with no competing revisions → fast-forward. Base = current revision while review is open, or any other known non-competing revision → accepted as a competing revision. Base = a currently competing revision, an unknown revision, or another visit's revision → rejected. Disjoint field edits still conflict; no merge rules exist.
- An unresolved visit keeps the last resolved revision as its current state and exposes status plus competing revision IDs. It is not a provisional winner, and no competing payload is combined.
- Resolution selects one whole revision or retains the current one. It records the coordinator, time, chosen revision, and every contributing submission ID; nothing is deleted.
- Idempotency keys are scoped to the author. An identical retry returns the original revision; different content under an accepted key is rejected.
- Downstream obligations are recorded: tablet-sync tracks the base/current revision; review-export compares whole revisions and excludes unresolved visits from the CSV.

**Phase 2 edge probe** — settled in the LLD: stale-base edits are accepted as competing rather than discarded; resolution races are rejected once a visit is already resolved; archived plots remain valid references; submissions based on an active competing revision are rejected to keep the candidate set flat. Deferred: withdrawing a competing revision, post-season history retention, coordinator authorization, and whether an exact duplicate submitted under a new idempotency key should collapse instead of becoming review work. That last one is the only gap I would consider settling before the specs.

Existing `REC-001`–`REC-006` remain consistent and untouched; I have not yet updated EARS or written tablet-sync/review-export.

May I proceed to the EARS cascade (Phase 3)? Please reply with numbered feedback or approval. Also, this choice is likely to invite re-litigation by a cold reader — would you like a decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or is the Decisions table row sufficient?