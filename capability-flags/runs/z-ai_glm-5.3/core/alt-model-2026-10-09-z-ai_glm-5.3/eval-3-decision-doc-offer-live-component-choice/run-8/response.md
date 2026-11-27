Phase 2 (LLD) is drafted and stops here for your review per the linked-intent-dev workflow.

**What changed**

- `docs/intent/record-store/record-store-design.md` — finished around whole-visit revisions: every accepted submission is an immutable revision (visit ID, base revision ID, complete payload, author, receipt time); a visit's head advances automatically when base = head (sequential self-corrections create no review work); stale-base submissions fork the visit into an unresolved state with a competing-revision set; a coordinator resolves by choosing one competitor as head, and combines content by submitting a new revision through the normal path — the server never merges. The submission envelope, current-state response (head + unresolved indicator), resolution operation, and submission-history sections now define the public contract; the decision and its rationale are recorded in Decisions & Alternatives.
- `docs/high-level-design.md` — coherence update: record-store row no longer "concurrency choice open," and the dependency paragraph now states the selected policy rather than an open choice.

**LLD edge-case probe (delegated, fresh reader) — please triage fix-in-LLD vs. defer:**

1. Fork-time head advance: while a visit is unresolved, does a new base = head submission still move the head, or does unresolved state block advance until resolution?
2. Chained forks: is a revision based on a *competitor* (not the head) itself in the competing set, and is the set computed at submission time or recomputed?
3. Null base on a non-empty visit (two tablets both submitting the "first" record for the same visit UUID): rejected, or a null-base competitor?
4. Internal contradiction I should flag: I wrote that a coordinator's combine-revision can "land via the fast path" — but during a fork base ≠ head, so the fast path can't apply. The doc needs one reading chosen.
5. Idempotency-key scope: unique per visit, per author, or globally? And does an idempotent retry response reflect later unresolved status?
6. Two near-concurrent base = head submissions: first-wins/second-forks by receipt time — tie-break unstated.
7. Error shapes: no status codes or distinguishable error classes (bad plot vs. bad base vs. key reuse) are specified.
8. Resolution races: resolution validated against the competing set at call or commit time; can a resolved visit re-enter unresolved on a later fork (implied yes, never said)?
9. History anchoring: does history retrieval expose per-revision "was head" status so an export traces through a resolution that picked an older competitor?

One offer, once: the whole-visit-revisions-over-three-way-merge choice is one other design nodes (tablet-sync, review-export) are about to be sized around, traded on multiple criteria — I can record it as a standalone decision doc under `docs/intent/record-store/decisions/`, with the Decisions & Alternatives row (already written) as the alternative. Want the doc?

Give me your triage on the nine gaps (and a yes/no on the decision doc), and on approval I'll fold in the fixes and proceed to Phase 3 (EARS update).