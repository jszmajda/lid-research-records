Phase 1 (HLD check) and Phase 2 (LLD) are done for `record-store`. Phase 3 (EARS) is next and I've stopped before it.

**Pre-flight:** no tests or code exist yet, so the only live coherence question is specs↔LLD. `REC-001`–`REC-003` still trace cleanly. `REC-004`, `REC-005`, and `REC-006` are phrased around "the concurrency policy" as an unknown and now need Phase 3 rewording, plus new specs for divergence and resolution. No drift to repair first.

**HLD (two edits, no architectural change):** the `record-store` row's state is now `Drafted` rather than "Drafted; concurrency choice open", and the paragraph below the table now says tablet-sync and review-export are sized around record-store's contract instead of waiting on an unresolved choice. The architecture, tenets, and goals are untouched — the mechanism was always record-store's to pick.

**LLD — `docs/intent/record-store/record-store-design.md`**, rewritten around whole-visit revisions:

- **Revision model.** A revision is the immutable result of one accepted submission: complete payload, `baseRevisionIds`, author, receipt time, originating submission, and an `origin` of `field` or `resolution`. History is a DAG. A **head** is a revision nothing names as a base; one head means the visit is *settled* and that head is its current revision, more than one means *diverged*.
- **Submission.** Envelope is visit ID, base revision ID, idempotency key, complete payload, client capture time. Validated for field types, plot reference, and that the base exists and belongs to this visit; an unknown or wrong-visit base is rejected because the server can't place it in a lineage.
- **Divergence is never a reason to reject.** An edit from a stale base is accepted as an additional head. Rejecting it would discard field observations to save a coordinator a comparison.
- **A diverged visit has no current value.** Retrieval returns the competing heads plus the divergence point (their nearest common ancestor), labelled not current — so nothing downstream can read a provisional value past the unresolved state. That keeps unresolved visits out of the export set by construction rather than by an export-side rule.
- **Resolution.** A coordinator submits contributing head IDs and the payload that should stand — one head's payload unchanged, or one they compose. Either lands as a resolution revision naming every head as a base, collapsing the head set to one. Losing heads stay in the graph with their original authors. A resolution must name all current heads, and is rejected if a named revision is no longer a head, so a visit can't look settled while a submission is outstanding.
- **Decisions & Alternatives** carries five rows: the concurrency choice with three-way merge as the rejected alternative and your reason (merge rules can't see scientific relationships between fields), plus the diverged-visit value, stale-based submissions, all-heads resolutions, and resolution representation.

**Decision-doc offer.** The concurrency choice clears the bar for a full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`: both options stay credible, they trade against more than one criterion, and two nodes are about to be sized around the result. The Decisions row above is the alternative and is already written. Want the doc, or is the row enough?

**Edge probe.** I gave a subagent only the LLD and the HLD. Twelve findings; these are the ones I'd fix in the LLD now:

1. **Multiple divergence points.** With three or more heads, or multi-base resolutions, the nearest common ancestor isn't necessarily unique — the doc promises a single divergence point. Does the coordinator see one common ancestor for all heads, or per-head branch structure?
2. **Resolution atomicity.** Nothing states head-set computation and revision insertion are atomic. Two coordinators resolving the same head set concurrently, or a submission landing between a resolution's head check and its write, is unspecified.
3. **Error shapes.** No status codes or machine-readable reason codes anywhere in the contract, yet tablet-sync is obligated to distinguish unknown base from idempotency conflict from stale head set.
4. **Resolution idempotency.** The resolution request has no idempotency key, so a retried resolution fails the non-head check indistinguishably from a genuine race.
5. **Second base-absent submission** for a visit that already has revisions: duplicate-create rejection, or a second root with no common ancestor at all?
6. **Resolution payload validation and authorization** are both unstated — whether a resolution is validated like a submission, and whether posting one requires the coordinator role or any authenticated worker can self-settle.

Three I'd flag but not necessarily fix here: whether a resolution may name the single head of a *settled* visit (it overlaps deferred question 1, coordinator reopening); what "identical payload" means for idempotency and whether a replay reports the original or current visit state; and whether a payload byte-identical to its base still creates a revision — under the current rules two workers submitting the same correction manufacture a divergence with no scientific disagreement in it.

The remaining three probe items (completeness of an omitted field or empty observer list, per-head branch display, history retention) I read as already covered by the deferred questions or genuinely Phase 3 material.

Which of those do you want fixed in the LLD, and which deferred as open questions? And the decision doc — yes or row only?