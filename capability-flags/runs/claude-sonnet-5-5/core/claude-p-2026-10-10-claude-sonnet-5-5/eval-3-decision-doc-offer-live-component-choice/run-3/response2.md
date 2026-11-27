I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the Concurrent visit edits row in the record-store LLD's Decisions & Alternatives table.

## What the doc contains

- **Context:** why the choice sizes tablet-sync and review-export, and what goes wrong in each direction. A wrong merge pairs values no worker observed together. A wrong whole-visit choice gives two coordinators a queue too big to clear by Friday.
- **Decision elements:**
  - Two gates: no submitted edit is discarded, and no inference of scientific intent.
  - Weighted criteria, tied to your tenets where they apply: whole-visit intent and coordinator review load (both major), Friday export readiness, maintained rule surface and provenance (moderate), tablet complexity (minor).
- **Both options, described as their advocates would:**
  - Merge is strong on review load and Friday readiness.
  - Merge is weak on whole-visit intent and rule maintenance.
  - Whole-visit revisions are the reverse.
  - One finding I added: merge only passes the "no inferred scientific intent" gate with a manual-approval step, because its rules encode relatedness.
- **Selection:**
  - It states plainly that this choice is taken partly against the coordinator-capacity tenet, and that the larger queue is the accepted cost.
  - Silent wrong combinations were weighed against a visible, countable queue.
- **Obligations on tablet-sync:**
  - Keep each draft's base revision ID and send complete visits.
  - Explain unresolved outcomes without implying the edit was lost.
  - Define how a tablet chains successive offline edits.
- **Obligations on review-export:**
  - A revision comparison view.
  - A way for a coordinator to supply a resolved visit.
  - An export set that excludes unresolved visits.
  - Visibility of held-back visits before Friday.
  - A queue-size view, since review load is the principal risk.
- **When to reconsider merge:** if the queue routinely can't be cleared before Friday and many competing pairs turn out to edit unrelated fields. Switching later would change the envelope tablet-sync is built on, so it's cheaper to revisit before tablet-sync is designed.

## Still open

- **Hand-authored resolution.** I haven't resolved the question from last time: whether a coordinator may hand-author the resolved visit or must pick a head verbatim. The decision doc and LLD both assume hand-authoring is allowed. If you want pick-verbatim, I'll change both.
- **Probe gaps.** You haven't triaged the five gaps from the probe yet.
- **Remaining stop.** Neither the LLD nor the HLD state edit has been explicitly approved. Say the word and I'll move on to the REC specs.