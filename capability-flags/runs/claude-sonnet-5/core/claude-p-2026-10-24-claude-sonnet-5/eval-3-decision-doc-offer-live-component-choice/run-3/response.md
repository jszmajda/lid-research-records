Updated `docs/intent/record-store/record-store-design.md` to finish the record-store LLD around whole-visit revisions, and synced `docs/high-level-design.md`'s architecture table to reflect the choice is no longer open. Here's what landed and what needs your call before I move to EARS.

**What the design now specifies**
- **Revision lifecycle**: every accepted submission is an immutable revision. A submission is **clean** (becomes current) if its `baseRevisionId` matches the visit's current revision and no competing revision is already pending; otherwise it's **competing** (retained, doesn't change current, sets the visit's unresolved flag).
- **Submission envelope**: `visitId`, `plotId`, `baseRevisionId`, `idempotencyKey`, `authorId`, `payload`.
- **Current-state retrieval**: current revision + payload + an unresolved-review boolean (REC-005).
- **Review-queue retrieval**: current revision plus every competing revision (author, receipt time, base revision, payload) — the data a future revision-comparison screen needs.
- **Resolution operation**: coordinator selects one existing revision (current or competing) as the new current; records coordinator ID, selected revision, and all contributing revision IDs (REC-006). Never constructs a new payload — only selects among what was submitted.
- Added a Decisions & Alternatives row for the concurrency-policy choice itself, and logged two deferred questions (coordinator-authored resolution revisions; long-term revision retention) that don't block this.

**One design choice I made that you should confirm, not just inherit:** once a visit has any unresolved competing revision, I made *every* later submission against it competing too — even one whose base revision matches current — until a coordinator resolves it. This keeps a review's comparison set stable instead of letting a late clean submission silently advance "current" mid-review. The alternative (let clean submissions still fast-path while review is pending) is equally defensible and changes what a coordinator sees. Which do you want?

**Decision doc or table row?** The whole-visit-vs-merge choice is the kind tablet-sync and review-export are about to size real work around, and a cold reader might reasonably ask "why not merge disjoint fields?" six months from now. I recorded it as a Decisions & Alternatives row in the LLD for now — want it promoted to a full decision doc under `docs/intent/record-store/decisions/`, or is the row enough?

Once you're settled on both, I'll treat this as the Phase 2 stop cleared and move to drafting the EARS updates (Phase 3) for the revision/resolution behavior above — that's a separate stop, so I won't start it without your go-ahead.