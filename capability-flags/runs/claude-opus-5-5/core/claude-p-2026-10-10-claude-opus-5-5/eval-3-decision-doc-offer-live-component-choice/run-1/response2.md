The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store design's Decisions table and References. Nothing is committed.

## What the doc says

- **Why revisions:** a bigger review queue is visible and costs coordinator time. A wrong automatic combination passes validation and reaches the partner CSV as an observation nobody made. Merge rules would also need an owner the team doesn't have.
- **Why merging stays credible:** its whole case is the review queue, and nobody has measured how often two workers independently edit the same visit. The doc says to reopen the decision if any of these happen:
  - Unresolved visits regularly miss the Friday export because two coordinators can't clear the queue.
  - The queue is dominated by pairs that coordinators resolve by accepting both changes unaltered.
  - Someone can own merge rules, or the survey protocol states which fields form one observation.
- **Cost of switching later:** no data is lost, because every original submission is kept. The cost is the tablets' local format, the submission envelope and the review screen.
- **Tablet-sync must:**
  - record the revision each local copy started from;
  - send complete visits, not changes;
  - tell a worker when their edit is competing and what became of it.

  It needs no base snapshots or change tracking.
- **Review-export must:**
  - provide a whole-visit comparison and resolution screen;
  - expect queue entries whose edits don't conflict in any field;
  - hold unresolved visits out of the CSV;
  - show how many are held out before Friday.

  It needs no field-level provenance.

Two things in the doc are mine, not yours, so check them:

- **Criteria weights:** I rated scientific coherence, inspectability and review workload as major, maintenance as moderate, and tablet storage as minor.
- **Showing the held-out count before Friday:** I added this as a review-export obligation because of the HLD goal about making problems visible before the export.

## Still open on the design

The spec revision waits on your answers to the earlier list; the numbers below are the same ones.

- **My choices to confirm (1–3):** coordinator-composed resolutions, identical payloads still going to review, and resolutions covering every competing revision.
- **Gaps needing your call (4–9):** shared-tablet authorship, a broken offline chain, a visit reopened after export, editing an unresolved visit, plot and date rules, and coordinator starvation.
- **Mechanical fixes (10–15):** I'll apply these as recommended unless you object. For 11, I need to know whether species-list order counts when deciding that a retry is identical.
- **Vocabulary (17):** keep the terms in record-store, or move them to the HLD.
- **Site-catalog (18):** remove its stale "remains pending" sentence, or leave it.