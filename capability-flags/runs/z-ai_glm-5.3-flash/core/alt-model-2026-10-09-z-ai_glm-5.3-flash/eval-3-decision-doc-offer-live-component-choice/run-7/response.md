Record-store design is finished on the whole-visit-revisions choice. Here is the phase output for your review (Phase 2 stop) — full revised LLD, then the edge-case probe findings for your triage.

## Revised LLD — docs/intent/record-store/record-store-design.md

**Model.** A **revision** is one complete, immutable copy of a visit's scientific fields (date, observers, species cover estimates, notes) plus metadata: server-assigned revision ID, visit + plot UUID, author ID, **base revision ID** (the revision the worker last saw; none for a first submission), idempotency key, server receipt time. Revisions are never modified or deleted, even when a resolution selects against one.

**Visit states.** Exactly two:
- **resolved** — one revision is current; a submission whose base is the current revision extends the chain and becomes current.
- **unresolved** — a stored submission's base is not the current revision (common starting state, or stale base). While unresolved, *every* arriving submission joins the competing set regardless of base, so nothing moves the record under review.

**Arrival order.** Of two same-base submissions, the earlier extends the chain cleanly; the later competes. Arrival order decides which revision stands as current when review begins — never which observation is kept.

**Submission and retrieval.** Validate worker, field types, plot references; invalid payloads are rejected unstored. A base revision that doesn't exist → out-of-date rejection; the client re-fetches and re-derives the edit. Edits are always complete visit payloads; no partial-update format exists. Same idempotency key + identical payload returns the original result; key reuse with a different payload is rejected. Retrieval returns: resolved visits with current fields + revision ID + resolved marker; unresolved visits with current fields + ID + unresolved marker + the competing set.

**Resolution.** A coordinator selects one revision from the competing set to carry forward — selecting the current revision dismisses challengers, selecting a challenger makes it current. Outcome records coordinator identity, selected revision, and all competing revision IDs. No field combination anywhere, including during resolution.

**Downstream contracts** (cascade notes only — those nodes remain yours to design later): tablet-sync tracks base revision IDs per draft and shows an unresolved outcome as a pending decision; review-export compares whole visits and exports only resolved visits.

**Decisions & Alternatives** rows: whole-visit revisions over field-aware merge (drops merge-rule maintenance and the risk of silently combining related scientific edits, at the cost of a larger queue); select-only resolution (no coordinator-authored combined revision); join-the-set while unresolved; server-assigned revision IDs.

The HLD's record-store row and dependency paragraph were updated to name the choice.

## Edge-case probe — please triage (fix in LLD / defer as open question)

1. A submission extending the current revision is mid-validation when a resolution lands — extend the old chain, join the set, or reject?
2. A first-style submission (base "none") arriving for a visit that already has revisions — accepted, rejected, or joins the set? The rejection rule only covers nonexistent bases.
3. Does a rejected submission consume its idempotency key, so a corrected retry with the same key hits key-reuse rejection?
4. Does the unresolved retrieval's competing set include the current revision itself?
5. A submission arrives during review basing on a *challenger*; if that challenger later wins, what happens to the derived submission?
6. A resolution names a revision not in the current competing set (stale coordinator view, double-submitted resolution) — what happens?
7. What does retrieval return for a never-submitted visit UUID?
8. Is an idempotency key scoped per visit, per tablet, or globally — and what if the same key arrives for two different visits?
9. What breaks a tie when two submissions carry identical server receipt times?
10. Can a resolved visit's resolution be amended, or does a second resolution fail?

## One offer

The concurrency choice clears the bar for a full decision doc (two credible options, multiple criteria, two nodes about to be sized around it): want it recorded as a standalone decision doc in `docs/intent/record-store/decisions/`, or does the Decisions & Alternatives row above suffice?

On your approval of the LLD (plus gap triage), Phase 3 follows: EARS updates for this segment — including rewording REC-004, which still says "regardless of the concurrency policy's outcome" — then the Phase 3 stop before tests.