The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store Decisions table. Nothing is committed.

## What it says

- **Why revisions won:** the two biggest criteria pull in opposite directions (records combined without anyone looking, versus coordinator review workload). The doc picks the failure you can see: a long queue is countable and fixable with coordinator time, while a wrongly combined visit looks like a normal record until the science partner contradicts it.
- **Why merge is still credible:** it wasn't eliminated, it lost on a weighing that a season of use could change. The doc names three triggers to reopen it:
  - the queue regularly outruns what two coordinators clear before Friday;
  - coordinators keep resolving unrelated-field pairs the same mechanical way;
  - the visit format gains a way to mark values that belong together.
- **Switching later loses nothing:** every revision is stored complete with its base revision ID, so each worker's changes and their common starting point can be derived from history. A later merge could run over the same records without tablets changing what they send.
- **What tablet-sync must accommodate:**
  - keep the base revision ID for each local visit and send complete visits;
  - show "saved but waiting for a coordinator" as distinct from both "accepted" and "rejected", alongside the competing revisions;
  - let work continue on a visit that is in review.
- **What review-export must accommodate:**
  - a whole-visit comparison screen;
  - a queue that will include pairs differing only in unrelated fields;
  - holding unresolved visits out of the CSV, and making them visible before Friday;
  - handling a visit that was exported in an earlier week and has since gone back into review.

## Please check

- **Criterion weights are mine.** I rated undetected combination and review workload as major, maintained rules and explainability as moderate, and tablet storage and submission size as minor. Change any that don't match how you'd weigh them.
- **No conflict-rate numbers.** I had no data on how often concurrent corrections happen, so the reopening triggers are qualitative. If you have a figure, or a queue size you'd treat as the threshold, I'll add it.
- **One commitment depends on an open item.** The "exported earlier, now back in review" commitment holds as long as a late tablet can reopen a visit. That is item 6 from my last message; if you rule for a durability rule there, I'll adjust that line.

## Still open on the design

Items 1–12 from my last message still need your rulings before I update the REC specs. The ones that change behavior most are:

- **5:** whether another worker's edit can take a competing revision's place in review.
- **6:** whether stale tablets can reopen a resolved visit indefinitely.
- **7:** whether a visit's plot can change between revisions.

For the rest, "go with your recommendations" is enough.