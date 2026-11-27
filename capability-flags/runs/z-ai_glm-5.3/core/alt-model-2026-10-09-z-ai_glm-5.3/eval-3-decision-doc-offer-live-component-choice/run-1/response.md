Phase 2 (record-store LLD) is complete around your selection. Here's the stop for your review.

**What changed**
- `docs/intent/record-store/record-store-design.md` — rewritten as a complete design around **whole-visit revisions**. The open-choice section is gone; the contract tablet-sync and review-export will build on is now defined.
- `docs/high-level-design.md` — record-store's status cell no longer says "concurrency choice open", and the dependency paragraph now says the two downstream designs *build on* record-store's contract (the mechanism itself stays recorded in record-store, per the HLD's own rule).

**The design in brief**
- Every accepted submission creates one immutable revision (server-assigned ID, author, receipt time, base revision pointer). A visit has exactly one *current* revision and is either `clean` or `unresolved`.
- `clean` + base=current → the ordinary correction path, becomes new current. `clean` + older base → pending competing revision, visit goes `unresolved`. While `unresolved`, **every** new submission joins the pending set — the state is deliberately sticky so a third edit can't slip past a dispute.
- Resolution: coordinator picks exactly one candidate (current or any pending); losers are closed but retained in history. No field composition, ever — leftover corrections are resubmitted from the new current revision. Coordinator identity + contributing submission IDs are recorded.
- Retrieval returns state + pending list; history returns every submission with its resolution outcome — the inspectable path.
- Four decisions recorded in the Decisions & Alternatives table, including the rejected three-way merge with your rationale (merge rules can silently combine scientifically linked edits — species ID and cover are field-disjoint but related).

**Edge-case probe — gaps for you to triage** (fix in the LLD now vs. defer as open questions):

1. Two workers submit an initial visit for the same new UUID near-simultaneously — the loser's entire first observation is rejected with nothing stored. Retryable? Discard vs. pending-set protection?
2. A submission arriving while a resolution is in flight — is resolution atomic against concurrent submissions? Could a coordinator close a revision they never saw?
3. Two base=current submissions on a clean visit arriving near-simultaneously — is the base check atomic, and does the arrival-order outcome sit right with "arrival order is not authority"?
4. Can a "correction" change the visit's plot UUID and migrate the visit to another plot? No invariant forbids it.
5. Is the pending set bounded while a visit sits unresolved? Any aging/escalation, or is "stable, bounded dispute" overstated?
6. Idempotency key scope is unstated (per-visit, per-author, or global) — "reuse with a different payload" means different things under each.
7. Resolution input errors are unspecified (already-clean visit, revision not in the candidate set, closed revision).
8. No error taxonomy for validation rejections (auth vs. type-invalid vs. unresolvable plot vs. unknown base) — consumers can't tell retryable from permanent.
9. A submission naming a base revision under a visit UUID that doesn't exist at all — distinct from the covered cases.

(Inspector found the sticky-unresolved rule, idempotency-on-both-paths, and the closed-revision lifecycle solid.)

**Decision doc?** The concurrency choice clears the bar for a standalone decision doc — downstream nodes are about to be sized around it, and a cold reader would be tempted to re-litigate toward three-way merge for review-volume reasons. I've recorded it as a Decisions & Alternatives row; want a full decision doc at `docs/intent/record-store/decisions/`?

**One cross-segment note:** site-catalog's design says "Tablet-sync's visit submission and reconciliation behavior remains pending that choice" — now stale. It's a one-line edit in a sibling segment, so I'm asking rather than touching it: shall I update it?

Number your triage on gaps 1–9 (fix / defer / your ruling), answer the decision-doc and site-catalog questions, and I'll proceed to Phase 3 (EARS update) on your approval.