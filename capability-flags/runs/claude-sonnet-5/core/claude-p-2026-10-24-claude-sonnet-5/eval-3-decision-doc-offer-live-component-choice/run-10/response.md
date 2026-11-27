I finished the record-store LLD update for whole-visit revisions. Here's what changed:

**docs/intent/record-store/record-store-design.md**
- Resolved the "Open Design Choice" section into a concrete design: visits are a chain of server-assigned revisions, each naming a base revision ID. A submission whose base matches current advances the chain; a submission whose base is already superseded becomes a **competing revision** alongside the one that beat it — both retained, neither merged.
- Added a **Resolution operation**: a coordinator picks exactly one competing revision as the new current revision; the resolution records the coordinator's identity, all considered submission IDs, and which was selected. No field-level combination — if a coordinator wants to blend detail, they do it by submitting a further edit afterward.
- Added a **Decisions & Alternatives** table row recording the choice and your rationale (review-queue size traded against the risk of silently recombining scientifically related fields).
- Added two **Deferred** open questions (resolution-note field, chain pruning/archival) and a **Downstream Contract** section pointing at what tablet-sync and review-export will size against.

**docs/high-level-design.md** — updated record-store's status from "Drafted; concurrency choice open" to "Drafted," since the choice is now made.

I did not touch tablet-sync, review-export, or the REC-* specs — per your note, those come later, and spec updates are the next phase anyway.

Two things need your call before I call this phase done:

**1. Decision doc?** This choice trades review-queue size against implementation burden and against the risk of a merge rule silently combining scientifically related fields — and tablet-sync/review-export will both be sized around it. That combination is usually worth a full decision doc rather than just the table row above. Want me to write one (`docs/intent/record-store/decisions/concurrency-policy.md`), or is the table row enough?

**2. Edge-case probe** — a blind reader of the updated LLD surfaced these gaps in the revision/resolution model itself (not cross-component, just internal to this doc). Please triage which to fix in the LLD now vs. leave as open questions:

1. A submission's base revision ID matches nothing in the chain (garbled/fabricated) — no defined handling.
2. A submission claims "no base" (first submission) on a visit that already has a chain — undefined.
3. A coordinator resolves against a competing set that's gone stale (a new submission landed on the same base mid-review) — is resolution a snapshot, and what happens to the late arrival?
4. A resolution names a submission ID that isn't actually among that visit's current competing set — nothing validates the selection is drawn from the live set.
5. A third submission bases itself on the old current revision after competition already exists — third competitor, or rejected?
6. Two submissions with the same base arrive effectively simultaneously — no tie-break rule for which becomes current vs. competing.
7. A resolution picks a competing revision whose own base was itself superseded elsewhere — can resolution create a branch deeper in history than the model assumes is linear?
8. A retry (same idempotency key, same payload) replays "the original acceptance result" — but the chain has moved on since (original is now competing or superseded). Does retry return stale status?
9. A non-first submission has a missing/malformed base revision ID — validation-time rejection, or falls through to unmatched-base handling (gap #1)?
10. A coordinator tries to resolve a visit with no competing revisions (already resolved, or never had any) — idempotent, rejected, or undefined?