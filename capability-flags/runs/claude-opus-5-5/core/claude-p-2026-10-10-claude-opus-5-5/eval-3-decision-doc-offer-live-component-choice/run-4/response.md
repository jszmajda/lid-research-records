The record-store design is drafted around whole-visit revisions and has been through a cold-read gap probe. It needs your rulings before I write the specs.

## What changed

- **`docs/intent/record-store/record-store-design.md`**: the open choice is replaced by the full contract (terms, submission envelope, acceptance rules, rejections, retrieval, resolution, obligations on tablet-sync and review-export, decisions table).
- **`docs/high-level-design.md`**: two wording fixes only, so it no longer says the concurrency choice is open.
- **Not touched**: `record-store-specs.md`. REC-004 still says "regardless of the concurrency policy's outcome"; that gets fixed in the spec phase.

Nothing is committed.

## The contract in brief

A visit is either `current` (one current revision) or `unresolved` (two or more competing revisions and no current revision). The store never compares contents; the outcome depends only on the base revision a submission names.

| Visit on arrival | Base named | Effect |
|---|---|---|
| Doesn't exist | none | Becomes current |
| `current` | the current revision | Becomes current; the old one stays in history |
| `current` | anything else | Visit becomes `unresolved`; the former current and the new revision compete |
| `unresolved` | one of the competing revisions | Takes that revision's place |
| `unresolved` | anything else | Joins the competing revisions |

A coordinator resolves by naming every competing revision they reviewed. The resolution is rejected if that set has changed since they looked.

## Choices I made that are yours to rule on

1. **No current revision while unresolved.** The first-arrived revision stops being current when a stale-based edit shows up, because keeping it would rank by arrival order. The consequence is that a value exported last Friday can later become unresolved.
2. **Coordinators can select or replace.** They may pick one competing revision as-is, or author a complete replacement visit. The alternative is select-only, which is stricter but forces a fresh submission when each worker is right about different parts.
3. **Identical competing revisions still go to review.** The store has no rule for when two visits are "the same". Auto-settling exact duplicates would shrink the queue, but it is the first step towards content rules.
4. **Archived plots are accepted.** Tablets with a 48-hour-old catalog can still submit, and historical visits can still be corrected.

## Gaps the probe found

A zero-context reader found these; I have not applied any of them. My recommendation is fix 5–10 now and defer 11–12.

5. **Edit based on someone else's competing revision.** As written, worker B's edit based on worker A's competing revision takes A's place in review. That is fine when B is A, but otherwise A's version leaves the coordinator's view (it is still in history). Should replacement apply only for the same author, with others joining as an additional competitor? I lean same-author only, given the "do not silently discard" tenet.
6. **Stale tablets can reopen a resolved visit indefinitely.** Any edit based on a set-aside revision makes the visit unresolved again, even on a Thursday night. That follows from never discarding, but coordinator decisions then have no durability. Do you accept this, or do you want a rule here, such as attaching such an edit to the visit as a flagged late revision without removing the current one?
7. **Can a visit's plot change between revisions?** It can as written. Should the plot be fixed at creation, with a mismatch rejected?
8. **Simultaneous arrivals.** The design needs to state that submissions and resolutions for one visit are applied one at a time. I'll add it.
9. **Resolution rejections and replacement lineage.** I'd add a rejection table (not a coordinator, selected revision not in the set, invalid replacement visit) and record all resolved revisions as the replacement's bases.
10. **Idempotency key scope.** I propose one key space across all authors, covering both submissions and resolutions. A key reused by a different worker on a shared tablet would be rejected, and rejected keys would not be remembered.
11. **Smaller items.** Deferrable or quick fixes: which fields are required and whether empty lists are valid, precedence when several rejection reasons apply, whether history records state transitions or leaves them to be derived, and the not-found response.
12. **Coordinator who is also a competing author.** Whether a coordinator may resolve a visit where they authored one of the competing revisions is unstated.

## Decision record

13. The revisions-versus-merge choice is one a future reader will be tempted to reverse (the review queue is the visible cost), and two more designs are about to be sized around it. It currently has a row in the Decisions table. Do you want a full decision doc at `docs/intent/record-store/decisions/` with both options and the criteria, or is the row enough?

Reply by number. Once the design is approved I'll update the REC specs and stop again for your review.