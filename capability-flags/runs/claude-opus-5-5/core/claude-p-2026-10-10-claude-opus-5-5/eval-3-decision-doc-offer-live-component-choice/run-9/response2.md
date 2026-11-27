The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store design's Decisions row and References.

## What the doc says

- **Why whole-visit revisions won.** The two major criteria pull in opposite directions: coherence of a visit's scientific content favours revisions, and coordinator workload favours merge. A big review queue is a visible cost you can count every week; a merge that pairs related edits wrongly reaches the partner with nothing flagging it. The doc states plainly that this is taken against the "visible before the Friday export" goal to the extent the queue outgrows two coordinators.
- **Why merge stays live.** Merge is the better policy if both of these turn out to be true after a season:
  - unresolved visits routinely miss the Friday export, and
  - a large share of those are pairs whose edits touch different fields.

  The stored history can measure both, since every competing pair is kept with its base. A cheaper intermediate step is a merge computed as a proposal the coordinator still approves.
- **What tablet-sync must accommodate.**
  - Keep one base revision ID per local copy, with no base snapshots or structured changes.
  - Generate revision IDs and keep them stable across retries and restarts.
  - Submit offline chains oldest first, and send the complete visit on every edit.
  - Tell the worker when their edit was accepted as a competing revision instead of the current one.
  - Cope with a visit that was resolved while the tablet was offline; the late edit is accepted and reopens it.
- **What review-export must accommodate.**
  - Compare complete competing revisions against the revision they diverged from.
  - Expect, and make fast to clear, review work for edits to unrelated fields.
  - Hold unresolved visits out of the CSV and show before Friday which are withheld.
  - Carry no field-level provenance.
  - Account for a visit that was exported and later became unresolved.

## Things to check in the doc

- **Criterion I added.** "Cost of changing policy later" (moderate) did not come from you. It favours revisions, because complete revisions plus bases are exactly what a later merge would need. Strike it if you don't weigh it.
- **No conflict-rate numbers.** I have no data on how often edits compete, so the doc gives revisit conditions, not thresholds.
- **Open items kept out.** The doc avoids anything still awaiting your ruling, such as the coordinator "replace" outcome and identical payloads. The one exception is the last review-export bullet, which touches item 3.

## Still open before I move to the EARS specs

From my last message:

- **Items 1–7** are your calls: identical payloads, coordinator replace, unbounded reopening, editing an unresolved visit, shared-tablet authorship, a rejected link in an offline chain, and a listing operation.
- **Items 8–12** are defects I'll fix as described unless you object.
- **Site catalog.** OK to update the stale "remains pending that choice" sentence in `site-catalog-design.md`?