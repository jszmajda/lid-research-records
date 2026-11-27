Coherence pre-flight passed for the `record-store` segment: the HLD deliberately delegates the concurrency mechanism here, the existing REC-001–006 specs are policy-neutral, and there is no code or tests yet to drift. The HLD's architecture table still said "concurrency choice open," so I refreshed that cell and the surrounding sentence; no architectural change to the HLD was needed.

## Phase 2 — Record Store LLD (updated)

I rewrote `docs/intent/record-store/record-store-design.md` around whole-visit revisions. The substance:

**Revision model.** A revision is a complete submitted visit state (plot reference + all scientific fields), authored by one worker, immutable once accepted. Every revision names its **base revision**; a visit's first revision has no base. The server assigns each accepted revision a revision ID and receipt time. A visit has at most one **current revision**.

**Conflict detection.**
- First submission becomes the current revision.
- A revision whose base equals the current revision is accepted as the new current revision (ordinary edit path).
- A revision whose base is *not* the current revision is retained as a **competing revision** and the visit is marked **unresolved**; it never silently replaces the current revision.
- While unresolved, all arriving revisions are retained as candidates and the current revision is **frozen** at the pre-conflict head.

The frozen revision plus all competing revisions form the visit's **candidate set** — each a complete, attributed visit a coordinator compares side by side.

**Submission envelope.** `visit_id`, `plot_id`, `base_revision_id`, `author_id`, `idempotency_key`, `payload` (complete fields). Server adds `revision_id`, `receipt_time`. Validation and idempotency behavior unchanged (REC-001–003).

**Retrieval.** Current-state retrieval returns the current revision plus an `unresolved` flag, and when unresolved the candidate IDs and a review-item ID (REC-005). History retrieval returns revisions in receipt order with author and base, so lineage is reconstructable.

**Review and resolution.** One **review item** per unresolved visit (`visit_id`, common `base_revision_id`, `candidates`, `state`). A coordinator resolves by **selecting one candidate** as current; the store does not compose revisions. Resolution records coordinator identity, selected revision, and every contributing submission ID (REC-006); losing revisions stay in history.

**Export boundary.** Eligibility is review-export's rule; this node supplies the current revision and the `unresolved` flag it needs.

**Decisions recorded:** (1) whole-visit revisions over field-aware three-way merge — preserves the submitted visit as a unit, accepts a larger review queue rather than maintaining merge rules that could combine scientifically related edits without understanding the relationship; (2) base-mismatch conflict detection over arrival-order last-write-wins; (3) frozen current revision while unresolved; (4) pick-one resolution over compose-a-merge.

## LLD edge-case probe

Gaps found — your triage on which to fix here vs. defer:

1. **Base-absent collisions.** Two workers each create the first revision of the same new visit offline; the second arrives base-absent against an existing current revision. Current rules make it competing — is that the intended first-contact behavior?
2. **Stale-base after resolution.** A worker submits against a *losing* revision of a resolved conflict. Under current rules it reopens a conflict. Intended, or should stale-base submissions be rejected?
3. **Resolving race.** Two coordinators resolve the same review item concurrently — unspecified.
4. **Archived plot at submission.** Catalog resolves archived plots for history, but should a *new* submission referencing an archived plot be accepted?

## Two judgment calls I made to complete the draft — please confirm or redirect

1. **Freeze vs. advance.** I froze the current revision while a visit is unresolved, so a later linear-looking submission cannot absorb the dispute. The alternative is to keep advancing the head and track candidates separately.
2. **Pick-one vs. compose.** I limited resolution to selecting a candidate, on the reading that your rationale rules out any manual merge. A coordinator needing a corrected visit would submit a new revision instead.

## Decision doc offer

This concurrency choice has credible alternatives traded against more than one criterion, and tablet-sync and review-export are about to be sized around it — a future reader could reasonably re-litigate it. I'd suggest recording it as a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md` (with the Decisions table row as the fallback). Say the word and I'll write it.

Please review: approve the LLD as drafted (confirming the two calls above), or tell me what to change. Once you approve I'll move to Phase 3 and draft the REC specs for the revision model, conflict detection, envelope, retrieval, and resolution.