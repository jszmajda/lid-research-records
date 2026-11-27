The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store Decisions table. Nothing is committed.

## What the decision doc says

- **Why revisions win:** a long review queue is a visible failure that coordinators can count and explain to the partner. A merge rule that joins a species identification with someone else's cover estimate fails silently, and the record is exported looking clean.
- **Why merge stays credible:** it answers exactly the weakness accepted here, which is the review workload and the visits held out of Friday's CSV. The doc names three signals for reopening it:
  - the queue regularly exceeds what two coordinators can clear before Friday;
  - most conflicts are unrelated-field edits that coordinators settle the same way every time;
  - the partner objects to the number of held visits.
- **What a later move to merge would cost:** the record store keeps every revision complete along with its starting revision, so merge could be adopted without re-collecting past submissions. It would add merge rules, field-level provenance and an overlap review view.
- **What tablet-sync has to accommodate:**
  - keep each visit's base revision ID across restarts and multi-day disconnection;
  - always send the complete visit;
  - treat "sent to review" as a normal outcome and show the worker the competing revisions;
  - take a coordinator's settled revision as the new starting point.
- **What review-export has to accommodate:**
  - a side-by-side comparison of complete revisions, with authors and receipt times;
  - a quick path for unrelated-field conflicts, which will be most of the queue;
  - holding unresolved visits out of the CSV, with a way to see before Friday which ones are held.

I kept the downstream obligations to what your choice already settles. They do not depend on the questions still open below.

One thing I added that you did not ask for: the doc mentions a narrower step short of full merge, automatically settling a small named set of cases the team has judged safe. It is offered as an option to reconsider later, not a commitment. Say if you want it removed.

## Still open before I can finish the design

These are the earlier questions, renumbered; the decision-record question is answered.

1. **Chained offline edits.** Should the tablet assign revision IDs so a queued edit can name a pending one as its base (my recommendation), or must the tablet collapse queued edits into one submission?
2. **Identical competing revisions.** Should they settle automatically or still go to a coordinator?
3. **Shared-tablet retries.** Keep rejecting a retry sent under a different login, return the original revision ID and author, and oblige tablet-sync to send under the login that made the edit?
4. **Changing plot or date.** May a later revision change them? I recommend yes.
5. **Validation scope.** Require plot, date and at least one observer; notes optional; species list may be empty; cover between 0 and 100; nothing else checked?
6. **Resolution note.** Add an optional free-text note on resolutions? I recommend yes.
7. **Rejected edits.** Accept that they live only on the tablet, with an obligation on tablet-sync to keep the draft?
8. **Site catalog.** Shall I update its stale "remains pending that choice" sentence?

The three design calls I made (no current revision while unresolved, coordinator may compose the settled visit, workers may keep editing an unresolved visit) and the list of smaller fixes also still need your approval or objection. Once those are settled I'll revise the design and move to the EARS specs.