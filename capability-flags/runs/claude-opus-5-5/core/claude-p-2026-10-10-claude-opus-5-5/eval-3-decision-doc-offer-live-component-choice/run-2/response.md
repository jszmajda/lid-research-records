The record-store design is drafted around whole-visit revisions and is ready for your review. I stopped at the design: the EARS specs, tests and code are untouched until you approve it, and nothing is committed.

## What changed

- **`docs/intent/record-store/record-store-design.md`**: rewritten. The open-choice section is gone and the contract is defined.
- **`docs/high-level-design.md`**: two small edits. The record-store row no longer says "concurrency choice open", and the paragraph beneath it says the two downstream designs build on the contract rather than wait for it. The mechanism itself stays out of the HLD.

## The contract in brief

- **Revisions**: every accepted submission is a complete visit with a tablet-generated revision ID and the revision it was edited from. The revision ID doubles as the idempotency key.
- **Visit state**: a revision is superseded once another names it as a base. One unsuperseded revision means the visit is `current`; more than one means `unresolved`, with no current revision.
- **No payload comparison**: the store never compares or combines payload contents, and arrival order carries no authority.
- **Stale edits**: a worker's edit is never refused for being stale. It is accepted and competes with whatever replaced its base, including a coordinator's resolution.
- **Unknown base**: an edit whose base the store hasn't received is rejected until the base arrives, so tablets submit queued edits oldest first.
- **Resolution**: a coordinator submits a complete visit, either one competitor's payload or one they composed. It must name exactly the current competing revisions, or it is rejected with the new set.
- **Downstream obligations**: tablet-sync and review-export each get a short list of obligations in the design, noted as cascades and not designed here.

## Decisions I made that you should rule on

1. **Coordinators may compose a resolution**, not only pick one competitor. Pick-only would drop the other worker's edit even when the two are unrelated.
2. **Identical competing payloads still go to review.** Auto-settling them would be the store's only content comparison. It is cheap to flip if you would rather not review no-op conflicts.
3. **A late edit reopens a resolved visit.** A tablet syncing after a resolution makes the visit `unresolved` again, so it can drop out of a later Friday export.
4. **Revision IDs are generated on the tablet.** This is what lets a worker edit a visit twice offline.

## Gaps from the cold-read probe

A reader given only the HLD and this design found these unanswered. Tell me which to fix now and which to defer; my lean is in each.

1. **Broken chains**: if queued edit A is rejected as invalid, B and C built on it are "unknown base" forever, and the design can't tell "not yet" from "never". Fix now.
2. **Processing order**: nothing says submissions for one visit are processed one at a time, which the "competitors changed" check relies on. Fix now.
3. **Retried resolution**: a retry of an accepted resolution matches both "repeat" and "competitors changed". Fix now by checking for a repeat first.
4. **Malformed resolutions**: no outcome is defined for a resolution naming one base or another visit's revisions, a worker edit naming two bases, or a second coordinator resolving an already-resolved visit. Fix now.
5. **Author on shared tablets**: is the author the worker who made the edit or whoever is signed in at sync? This one needs your answer.
6. **Changed draft after a lost response**: the retry carries the same revision ID with a different payload and is refused. I'd fix now by stating that a changed draft is a new revision.
7. **Plot reference**: can it differ between revisions of one visit, and which catalog version is a 48-hour-old edit validated against? This one needs your answer.
8. **Who may do what**: may any worker read or edit any visit, and may a coordinator resolve a set containing their own revision? This one needs your answer.
9. **Unreviewed first submissions**: is a `current` visit no coordinator has seen exportable in the "reviewed CSV"? I'd defer this to review-export.
10. **Minor shapes**: unknown-visit retrieval and listing order and bounds are unspecified. Defer.

The probe also caught an error in my decisions table, which overstated the review queue; I corrected it to "any two edits made from the same revision".

## Questions for you

1. **Do you want a decision doc for the concurrency choice?** It is currently one row in the Decisions table. Three-way merge remains credible and two more designs are about to be sized around this, so a full doc at `docs/intent/record-store/decisions/` would let a later reader re-run the judgment.
2. **May I update the site-catalog design?** It still says tablet-sync's reconciliation behaviour "remains pending that choice". That is a different segment, so I left it alone.
3. **Should the terms "revision", "base revision", "competing revisions" and `current`/`unresolved` stay defined in record-store?** Both downstream designs will use them; the alternative is moving them up to the HLD.

Once you approve the design with your triage, the next step is the EARS specs. REC-004 and REC-005 still speak of an unchosen policy, and the revision, state and resolution rules need new spec lines.