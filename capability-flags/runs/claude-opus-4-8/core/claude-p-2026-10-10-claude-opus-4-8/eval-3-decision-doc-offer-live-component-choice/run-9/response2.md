Done. Written up at `docs/intent/record-store/decisions/concurrency-policy.md`, linked from the LLD's Decisions row.

## Decision doc — what it says

**Context & stakes** — independent offline edits of one visit arrive days apart; the choice sets submission metadata, review shape, and export eligibility. The stakes are scientific: fields aren't independent (an identification and its cover estimate carry one judgment), so the real trade is between *auto-combining a record no observer submitted* and *burying two coordinators in reviews before each Friday export*.

**Why the other approach stays credible** — field-aware merge is written in its strongest honest form and scores **strong** on the review-workload criterion: disjoint-field edits combine automatically, so far fewer visits reach a coordinator and more are export-ready. That criterion cuts against the recommendation, and the Selection says so plainly — whole-visit revisions are **weak** there, and the larger queue is accepted deliberately, not because review volume was judged unimportant.

**Why whole-visit wins** — the decision turns on two *major* criteria (scientific-relationship safety; reconciliation logic to build and maintain), and field-aware merge is **weak** on both: the fields its rules treat as independent are sometimes one judgment it can't see, and its maintained merge rules are exactly the standing burden the *two-coordinators-without-a-sysadmin* tenet resists.

**What the tablet and export work must accommodate** (recorded here as cascade obligations, since the substance is this node's choice):
- **tablet-sync** — retain the last-downloaded base revision ID per visit, submit full-payload edits against it, and handle three outcomes for the worker (clean extend / became competing / rejected). No structured change sets or base snapshots.
- **review-export** — present competing revisions, drive resolution (select or compose a reconciling revision, capturing coordinator identity + contributing IDs + outcome), and gate the Friday export to resolved visits only. It carries the review-volume cost, so its comparison UI is where per-conflict effort should be minimized.

I didn't touch the tablet-sync or review-export designs themselves — those are separate segments for later; only their obligations are recorded.

## Still open from the last stop

Your probe triage is still waiting — I held it rather than resolving anything. To move to Phase 3 (EARS specs) I need:

- **How to resolve the three incoherences** 1–3 (the two definitions of "competing"; the reconciler's single base pointer vs. "descends from the set"; submitting into an already-unresolved visit).
- **Which of 4–15 land in the LLD now vs. defer** — my earlier lean was to also settle 4, 5, 7, 11, 12 now because tablet-sync and review-export will size their state machines around those answers.

Give me those and I'll fold them into the LLD, then draft the EARS updates.