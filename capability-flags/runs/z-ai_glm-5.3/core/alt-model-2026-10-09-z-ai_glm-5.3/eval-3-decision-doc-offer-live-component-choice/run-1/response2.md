The decision doc is written at `docs/intent/record-store/decisions/visit-concurrency-policy.md` and linked from the LLD's Decisions table. It covers:

- **Decision elements**: the no-silent-discard gate, plus five weighted criteria — with "no inferred scientific independence" (anchored to the HLD's non-goal on inferring scientific intent) and "operable by two coordinators" as major.
- **All three options in the domain** given their strongest honest reading, including last-write-wins (eliminated by the gate) and field-aware three-way merge.
- **Selection**: whole-visit revisions wins on the non-inference criterion, with the larger review queue named as a deliberately accepted price.
- **What tablet and export work must accommodate**: tablet-sync retains base revision IDs, submits complete visits, and explains non-current outcomes (pending revisions, stale-state edits, post-resolution re-entry); review-export gets a revision comparison screen, holds unresolved visits out of the CSV, and sizes its workflow for the larger queue.
- **Why the other approach stays credible**: its weaknesses are contingent, not fundamental — if the pre-export unresolved backlog grows while disputed edits are dominated by field-disjoint pairs, the trade flips and the decision should be re-run, not defended. The weekly export backlog is the measurable trigger.

Still open from the last stop before I proceed to Phase 3 (EARS update):

1. **The nine probe gaps** — triage each: fix in the LLD now, or defer as an open question? The ones I'd flag as most consequential: #1 (racing initial submissions discard a first observation), #4 (a correction can silently migrate a visit to another plot), and #6 (idempotency key scope is unstated).
2. **The site-catalog one-liner** — "Tablet-sync's visit submission and reconciliation behavior remains pending that choice" is now stale. OK to update it?