Pre-flight check first: HLD, the two drafted LLDs, and `record-store-specs.md` were mutually coherent — REC-001…006 trace to the record-store design, no tests or code exist yet, so there was no drift to repair before starting.

## Phase 2 — record-store design (finished)

`docs/intent/record-store/record-store-design.md` is rewritten around whole-visit revisions:

- **Model** — every accepted submission becomes an immutable revision of the whole visit naming the revision its author started from. A revision with no children is a head; one head = **settled** (that head is the current record), two or more = **contested** (the heads are competing revisions and the visit has no current record). Resolution is the only operation that reduces the head count.
- **Submission envelope** — `visit_id`, `base_revision_id` (absent on creation), `idempotency_key`, `plot_uuid`, complete `fields`, author from the authenticated session. No field-level change description, so a tablet retains a revision ID per visit rather than a base snapshot.
- **Retrieval** — settled returns the current values; contested returns every competing revision in full with authors and receipt times and designates nothing current.
- **Resolution** — a coordinator names the competing revisions reviewed and supplies either one revision's values verbatim or coordinator-authored values; the result is a new revision parented to all of them, recording coordinator identity, contributing submission IDs, form used, and decision time. Optimistic: naming a head set that no longer matches is rejected as stale, because a lock would have to survive a 48-hour disconnection.
- **Rejections** are distinguishable by reason (auth, validation, unresolvable plot, duplicate create, unknown base, idempotency-key conflict) since tablet-sync handles each differently. Archived plots are accepted — archival only removes a plot from the new-visit picker.
- **Decisions & Alternatives** has seven rows, including the concurrency choice with field-aware merge named as the rejected alternative and your reason for it. Cascade obligations for tablet-sync and review-export are recorded but not designed.

I also made one upstream edit: the HLD's record-store row said "concurrency choice open" and a paragraph said the two downstream designs must wait for the choice. Both now read as settled, with the mechanism named in one line and still owned by record-store.

## Edge-case probe

A blind subagent probed the design for its own internal gaps. Three are yours to rule on, not mine:

1. **Identical concurrent content.** I wrote a rule that a submission whose fields match an existing competing revision from the same base is retained but attached to that revision instead of creating a third head — two workers making the same correction generate no review work. Keep it, or should every concurrent submission produce a competing revision so a coordinator always sees that two people touched the visit? And if kept, is "identical" byte equality of the payload, or equivalence (observer list reordered, `2.0` vs `2`, note whitespace)?
2. **Resolution authority.** The design records the coordinator's identity but never says resolution is restricted to the two coordinators. Restrict it to a coordinator role, or let any authenticated worker resolve (no admin to manage roles, per the HLD tenet)?
3. **Plot reference on an edit.** A submission carries `plot_uuid`, and nothing says a visit's plot is immutable. Should a worker be able to correct a mis-keyed plot on an existing visit — which lets two competing revisions name different plots — or is the plot fixed at creation?

Nine more I can close in the LLD as proposed, if you agree:

4. A revision already consumed as a resolution's parent is closed to new children; a late submission naming it is rejected with a distinct reason rather than re-contesting a resolved visit.
5. The staleness check and the resolution write are one atomic operation.
6. Two coordinators resolving the same head set concurrently: the second is rejected as stale, rather than producing two resolution revisions.
7. A true race between two identical submissions resolves to one shared revision (the attachment rule applies on store, not on read).
8. A submission attached to an existing revision gets that revision's ID as its acceptance result and next base.
9. Retrieval reports a revision's authors and receipt times as lists, since attachment puts more than one submission behind one revision.
10. Resolution's own rejection catalogue: unknown revision in the named set, a non-head in the set, a settled visit, and coordinator-authored values failing the same validation as a submission.
11. `idempotency_key` uniqueness is scoped per visit, so two tablets colliding on a key for different visits is not a conflict.
12. Retrieval of an unknown `visit_id` is a not-found response; history ties on `received_at` break by submission ID so the order is total.

The probe's remaining questions were already answered in the document or belong to tablet-sync and review-export.

## One offer

The concurrency choice stays live for a cold reader — two credible options traded against review workload, implementation burden, and scientific correctness, with two more nodes about to be sized around the result. I can record it as a decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, laying out both options against the criteria so a future reader can re-run the judgment. The alternative is what is already in place: the Decisions & Alternatives row. Want the doc?

Tell me how to rule on 1–3, whether 4–12 land as proposed, and whether to write the decision doc. Then I'll take the record-store EARS specs (Phase 3) — revising REC-001…006 and adding the new ones — and leave tablet-sync and review-export for later sessions as you said.