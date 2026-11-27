The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, and the Decisions row in `record-store-design.md` now links to it.

## What the doc covers
- **Context:** why a policy is needed, and what it sets for tablets, review, and export.
- **Gates:**
  - No original submission is discarded.
  - No scientific inference, from the HLD non-goal.
- **Weighted criteria:**
  - Major: preserving a worker's visit as submitted, and being operable by two coordinators. Both tie back to HLD tenets.
  - Moderate: review volume before Friday, and tablet/submission simplicity.
  - Minor: export readiness.
- **Both options:** each is described as its advocate would, then given a fit verdict per element.
- **Selection:**
  - Whole-visit revisions win on the two major criteria.
  - Three-way merge's main benefit is where its risk lies: the edits it combines automatically are the ones a coordinator would otherwise have seen.

## Why the other approach stays a candidate
It is stronger on review volume, export readiness, and queue size. The doc names when to revisit it:
- Unrelated-field edits dominate the queue and coordinators can't clear it before Friday.
- A reviewed list of field combinations the team treats as independent exists.
- Combined records still get manual approval, unless the team accepts the inference risk.

Whole-visit revisions are a sound base for that move. A merge policy could later *propose* a resolution revision, leaving the record-store contract in place.

## What downstream work must accommodate
- **Tablet-sync:**
  - Keep the base revision ID for each fetched visit.
  - Send complete visits, not deltas.
  - Size local storage and retry state for whole-visit payloads.
  - Show a worker that a visit is awaiting review.
- **Review-export:**
  - A comparison view of competing revisions.
  - A way to author a resolution revision.
  - An export set limited to settled visits.
  - A report of how many visits were held out. This is my addition, justified by the expected larger held-out set; strike it if you don't want it.

## Needs your confirmation
- **Selection on inference.** I marked three-way merge "eliminated unless approval is required" against the no-inference gate. I read the HLD non-goal ("inference of scientific intent") that way, and the original sketch said field-aware merging isn't ruled out if every combined record gets manual approval. If you'd rather it were scored as merely weak on that point, tell me.
- **Open questions 1–4 from the LLD.** These are still unanswered, and the decision doc doesn't depend on any of them:
  1. Whether a coordinator may only pick one head or also compose a payload.
  2. How tablets name a base across repeated offline edits.
  3. Whether identical competing heads need review.
  4. Whether concurrent resolutions should be blocked.

Once you've answered those (or deferred them) and approved the LLD and decision doc, I'll move to Phase 3 and revise the REC specs.