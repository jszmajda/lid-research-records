The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the concurrency row in the record-store Decisions table. Nothing is committed, and the specs are still untouched.

## What the doc says

- **Why whole-visit revisions**: a merge rule that combines two related edits produces a plausible visit nobody recorded, and nothing flags it. That is the same silent failure as the spreadsheet overwrite. A long review queue is visible and countable.
- **Why merge is still worth considering**: it is plainly better on coordinator workload and export completeness. The doc names three triggers for revisiting:
  - unresolved visits regularly remain at the Friday export because of review backlog;
  - coordinators find most resolutions are unrelated edits they combine mechanically;
  - the visit's fields settle into groups whose independence the team is willing to state and own.
- **Cost of switching later**: every submission is stored whole with its base revision, so a later move to merge changes the contract and both dependent designs but needs no data migration.
- **What tablet-sync must accommodate**:
  - generate revision IDs and remember each local copy's base revision across restarts and offline edit chains;
  - submit queued edits of one visit oldest first;
  - tell a worker their edit was accepted but now competes with another, without implying it was lost;
  - expect a settled visit to reopen when another tablet syncs late.
- **What review-export must accommodate**:
  - a side-by-side comparison of complete competing revisions, with a resolution that is either one of them or a composed visit;
  - a resolution naming exactly the revisions compared, and showing the new set when the store says it changed;
  - unresolved visits held out of the CSV, with the held count visible before Friday;
  - a visit exported one week and reopened by a late edit the next.

## Things in the doc you should check

- **Criterion weights are my judgment.** I rated scientific coherence, inspectability and review workload as major, maintenance as moderate, and tablet storage as minor.
- **Auto-settling identical payloads appears as a possible later step.** The doc mentions it as a narrower move that would not abandon this decision; the design as drafted still sends identical competitors to review.
- **The obligations lean on design choices you haven't ruled on.** Coordinator-composed resolutions and late edits reopening a visit are both in the downstream lists. If you reverse either, the doc changes with the design.

## Still open from the design review

1. **Probe gaps**: which of the ten to fix now and which to defer. Three need your answer rather than my lean:
   - **Author on shared tablets**: the worker who made the edit, or whoever is signed in at sync?
   - **Plot reference**: can it differ between revisions of one visit, and which catalog version validates a 48-hour-old edit?
   - **Permissions**: may any worker read or edit any visit, and may a coordinator resolve a set containing their own revision?
2. **Site-catalog**: may I update its line saying tablet-sync's reconciliation "remains pending that choice"? It is a different segment, so I have left it.
3. **Terms**: should "revision", "base revision", "competing revisions" and `current`/`unresolved` stay defined in record-store, or move up to the HLD?

Once the design is approved with your triage, I'll draft the EARS specs.