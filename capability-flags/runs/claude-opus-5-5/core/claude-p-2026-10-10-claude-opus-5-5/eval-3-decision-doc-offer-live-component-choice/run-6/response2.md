The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the concurrency row in the record-store design's Decisions table. Nothing is committed.

## What the doc says

- **Why the choice is close:** the two most important criteria point opposite ways. Whole-visit revisions guarantee a person wrote every exported visit. Field-aware merge keeps the review queue short and gets more visits into Friday's CSV.
- **Why revisions win:** a long queue is visible to the coordinators before Friday, while a merge that joined two related edits looks like any other row and is found, if at all, by the science partner. This accepts a cost against the "two coordinators can operate it" tenet, and the doc says so.
- **What tablet-sync must accommodate:** keep a base revision ID per visit, send complete visits, and show a worker when their visit is unresolved and what it competes with.
- **What review-export must accommodate:** a comparison of complete revisions in which a coordinator writes the resolved visit, unresolved visits held out of the CSV, and a queue visible early enough to clear before Friday.
- **Why merge stays on the table:** three observations would justify returning to it:
  - unresolved visits are regularly still queued at Friday's export;
  - resolutions are mostly mechanical combinations of unrelated edits;
  - someone can state which fields form one observation, so merge rules rest on stated relationships.
- **Cost of switching later:** no new data from the tablets, because every revision is a complete visit that names its base. The cost would be the merge rules and field-level provenance in review-export.

Two things to check in it:

- **Conflict rate is unknown.** The doc states that how often two workers edit the same visit concurrently has not been measured. If you have a number, it belongs in the Context section and may change how the workload criterion reads.
- **Criterion weights are mine.** I rated "no exported visit that nobody wrote" and "coordinator workload" as major, maintenance and explainability as moderate, and tablet storage as minor.

## Still open from the design review

I need these answered, plus your approval of the design, before I move to the EARS specs:

1. **Gap triage:** which of the cold-read gaps to fix now. The three weightiest:
   - whether coordinators can correct a settled visit;
   - a previously exported visit dropping out of the next CSV when it becomes unresolved;
   - rejected submissions living only on a shared tablet.
2. **Scope of review:** if coordinators approve every visit before export, not only resolve competing revisions, does that approval belong in the record store or in review-export?
3. **Site-catalog wording:** may I update the two sentences in `site-catalog-design.md` that still call the concurrency choice "pending"?