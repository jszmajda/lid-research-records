## Phase 1 — HLD check

The architecture is unchanged; the concurrency mechanism remains owned by record-store. I updated `docs/high-level-design.md` so the record-store row and the dependency paragraph reflect whole-visit revisions rather than an open choice.

One sibling-segment note: `docs/intent/site-catalog/site-catalog-design.md:24` still says tablet-sync's reconciliation behavior is pending the concurrency choice. That is a cross-segment cascade, so I left it untouched. Want me to update that sentence now or when we return to the catalog?

## Phase 2 — LLD draft

The revised design is at `docs/intent/record-store/record-store-design.md`. The open-choice section is gone; the contract now defines:

- Each accepted submission is one immutable complete-visit revision carrying a client-supplied base revision. The first revision becomes current; a submission based on the current revision advances it.
- Any submission based on anything else opens a review episode. The baseline is the previous current revision; every revision accepted until resolution joins the candidate set. An unresolved visit has no current revision.
- A coordinator resolves by selecting one candidate — selecting the baseline rejects all competing revisions. Non-selected candidates remain in history and are recorded as non-selected for that episode.
- Submission envelope, current-state retrieval, submission-history retrieval, and resolution are specified, including idempotency scope, payload-equality rules, episode IDs, a per-visit state version, and stale-resolution rejection.
- The Decisions & Alternatives table records the policy choice, the episode candidate-set shape, the coordinator write path, and the no-current-state-while-unresolved rule.

I also ran a blind LLD edge-case probe. It found 16 gaps; the draft now closes 13 of them (resolution/submission race, non-selected candidate disposition, idempotency scope and equality, rejected-key handling, zero-revision retrieval, history ordering and resolution disposition, divergence by base rather than content, retry response semantics, contributing candidate set, and revision ordering/identity).

Three gaps remain for your triage:

1. **Arrival order and current state.** The first accepted revision becomes current; a later same-base submission opens review. That means a visit can be exported between the two submissions. My recommendation is to keep this: arrival order never decides the review, and the later revision is never discarded. Do you agree, or should the record store treat any independent correction as review-worthy from the moment it is accepted — including holding the first revision out of the export set once a second base-sharing submission is known?
2. **Non-selected revisions as later bases.** The draft allows a non-selected revision to be named as the base of a later submission, so offline edits built on it re-enter as new revisions in a later episode. Confirm that, or should such revisions be forbidden as bases after their episode closes?
3. **Export staleness.** The draft exposes a per-visit state version so a consumer can detect a change, but how review-export uses it is review-export's design. Is that signal enough, or should record-store define a conditional export operation that requires an unchanged state version? That may cross into review-export territory, so I left it as a deferred item.

Also, the draft forbids coordinator-authored corrections during resolution: a coordinator selects an existing candidate, and any combined correction is submitted afterward as an ordinary revision. Confirm that write path.

**Decision doc offer:** this choice will stay live for tablet-sync and review-export, and a cold reader could re-litigate it without the tradeoffs laid out. Would you like a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or is the Decisions & Alternatives row enough?

If this reads correctly, I will move to Phase 3 and update `docs/intent/record-store/record-store-specs.md` for the revision, episode, retrieval, and resolution behavior.