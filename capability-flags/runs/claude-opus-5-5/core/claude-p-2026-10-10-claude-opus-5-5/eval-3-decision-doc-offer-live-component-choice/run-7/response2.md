The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store design's Decisions table. The record-store design itself is still waiting on your answers from last time, so I haven't started the specs.

## What the decision doc says

- **Why revisions won:** a missed Friday is visible and recoverable, because the visit shows as in review and goes out the next week. A merged row that pairs one worker's species identification with another's cover estimate exports looking like any other row.
- **Reversibility:** this is a criterion I added. Each revision keeps the full visit and its base revision ID, which is everything a three-way merge needs, so merge can be adopted later and even replayed over history. Going the other way could not un-merge visits already combined.
- **When to reconsider merge:** both of these would have to hold, and both are measurable from the review listing and the resolution records:
  - coordinators regularly can't clear the review queue before Friday; and
  - the history shows most competing pairs touch different fields and get resolved by combining both unchanged.
- **A narrower step before full merge:** auto-combine only the field pairs that the resolution history shows coordinators always combine.
- **What tablet work must accommodate:**
  - keep a base revision ID with every draft across restarts and disconnection;
  - treat "accepted into review" as a normal outcome, distinct from rejection;
  - show a visit in review as pending competing revisions, not as any one of them;
  - expect a draft based on a losing revision to reopen review.
- **What export work must accommodate:**
  - a queue sized for every concurrent pair, with whole-visit comparison as the main screen;
  - fast paths for identical revisions and unrelated-field pairs;
  - resolutions that name the revisions shown, with a re-review if another arrived meanwhile;
  - settled-only export, with the held-out visits visible before the CSV is produced;
  - a stated behaviour for a visit that was exported and later returns to review.

The doc says plainly that nobody yet knows how often concurrent edits happen or how often they touch unrelated fields. If you have a feel for that from the spreadsheet days, it belongs in the Context section.

## Still open from last time

1. **Plot edits:** can a revision change the visit's plot? I lean yes.
2. **Editing on top of someone else's competing revision:** should it replace that revision in the comparison, or join as another competitor? The draft replaces; I lean towards replacing only for the same author.
3. **Duplicate visits:** two tablets creating the same real-world visit under different IDs. I'd defer this to review-export.
4. **Shared tablets:** a draft synced under another worker's login is recorded under that login. I'd make tablet-sync submit drafts only under the session that wrote them.
5. **The five gap fixes:** lost-response replay, one-at-a-time processing per visit, replace-outcome base and validation, rejection reasons, and idempotency key scope. I held these because you hadn't confirmed them. OK to apply?
6. **Site catalog:** `site-catalog-design.md` still says tablet-sync's behaviour "remains pending that choice". Should I update it?

Once those are settled and you approve the design, I'll draft the EARS specs.