I finalized the record-store LLD around whole-visit revisions and ran the two required Phase-2 checks. Here's where things stand:

## Record-store design updated

`docs/intent/record-store/record-store-design.md` now resolves the concurrency choice instead of leaving it open:

- A visit's history is a chain of **revisions**; at most one is the **head** at a time.
- A submission names its base revision. Base matches current head → becomes the new head, no review work. Base doesn't match (another edit landed first, or the base was superseded) → becomes a **competing revision** stored alongside the head; the visit has no head until a coordinator resolves it.
- Resolution: a coordinator picks one competing revision as the new head. The outcome records the coordinator's identity and the full set of competing submission IDs. Coordinators pick among existing submissions — they don't author replacement content; a correction goes back through the normal submission path.
- Added a **Decisions & Alternatives** table with your rationale (bigger review queue accepted in exchange for never silently combining scientifically related fields), plus a second row on coordinators-can't-author-content.

I also updated the HLD's record-store status cell from "Drafted; concurrency choice open" to "Drafted," since that's what was tracking the open choice.

## Decision doc?

This choice has multiple real criteria (review workload vs. implementation burden vs. risk of silently combining scientifically related edits) and two sibling nodes (tablet-sync, review-export) are about to size their contracts around it — that clears the bar for a full decision doc rather than just the table row I added. Want one at `docs/intent/record-store/decisions/concurrency-policy.md`, or is the table row enough?

## Edge-case probe (delegated, blind to our conversation)

The probe found real gaps in the revision model itself. The ones that look implementation-blocking rather than minor:

1. **Race on the same head** — nothing states head-assignment is atomic; two submissions against the same head could both think they won.
2. **First submission, base = none, racing another first submission with the same UUID** — doesn't map cleanly onto the match/no-match rule.
3. **Stacked competitions** — if a new submission arrives based on an already-competing (not head) revision while a competition is unresolved, does it join that competition or start a second one?
4. **Late arrival during/after resolution** — a submission based on the pre-resolution head that wasn't part of the recorded competing set: folded in, rejected, or a new competition against the new head?
5. **Idempotency key scope** — per-visit, per-worker, or global? Also: does a key "used" by a validation failure block future legitimate retries with that key?
6. **Resolution isn't idempotent** — submissions have a retry-safe key; resolution has no stated guard against double-resolving or resolving a stale competing set.
7. **Does promotion to head mint a new revision ID**, or does the competing revision keep its ID once promoted? This affects what the next submission's base ID actually refers to.
8. **Coordinator authorization** — submission is explicitly authenticated; resolution's authorization is never stated.

(Full list has 18 items; the rest are minor wording/clarification gaps, not correctness blockers.)

Which of these do you want resolved in the LLD now, and which should I carry forward as Open Questions for later? And — does the decision-doc question above need settling first, or in parallel?