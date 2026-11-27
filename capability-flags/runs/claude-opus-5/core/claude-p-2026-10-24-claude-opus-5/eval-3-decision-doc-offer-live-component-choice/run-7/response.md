**Phase 2 — record-store LLD, drafted around whole-visit revisions.** Coherence pre-flight first: REC-001–006 all trace to this node, the LLD matched the HLD's architecture, and no tests or code exist yet, so there was no drift to repair before drafting.

**What I wrote** (`docs/intent/record-store/record-store-design.md`)

- **Visit Revisions** — a visit is a tree of revisions, each with a single `base_revision_id`, full `fields`, author, receipt time, status. A tip is a childless revision; a visit is unresolved while more than one tip exists. Branching keys off the *base*, not arrival time: a late submission extending the current revision is still linear, and one tablet's repeated offline edits extend one branch instead of manufacturing a conflict.
- **Current state while unresolved = the last resolved revision.** A competing edit is never served as current before a coordinator rules.
- **Resolution** — coordinators only; either select a tip or author a resolving revision based on one. Authoring is deliberately there so scientifically related edits get combined by a person reading both visits. Resolution names the exact tip set it saw; a stale set is rejected with the real one, which also keeps your two coordinators from ruling at cross purposes.
- **Reopening** — a submission based on a superseded or non-current revision is accepted as a competing tip and the visit goes unresolved again. A tablet offline across a resolution still gets its worker's observations into review.
- **Decisions & Alternatives** — 7 rows, including the policy choice itself with field-aware merge as the rejected alternative and your reasoning as the rationale.

I also updated two stale lines in the HLD: the record-store State cell (dropped "concurrency choice open") and the paragraph saying tablet-sync and review-export must wait for the choice.

**Edge-case probe** (delegated to a subagent given only this LLD and the HLD). It returned 10 gaps; it pushed hardest on the status/state machine and on resolution's boundaries. Grouped, with my recommendation:

1. **Fix now — the revision state machine.** Three real holes: what status the previous current revision takes on a *linear* extension (`superseded` would stop implying "a resolution record exists"); whether concurrent same-base submissions are serialized per visit (if not, last-write-wins silently loses an edit, against your first tenet); and whether `competing_tips` in retrieval includes the current revision, which it is itself a tip of when a visit is reopened.
2. **Fix now — resolution's edges.** Must a resolution rule on *all* tips or may it rule on a subset (a 3-tip visit resolved between two, leaving a `current` revision alongside live `competing` tips — a state I never described)? Is the authored revision's own base tip superseded along with its siblings? Does a resolving revision go through the same plot/field validation a submission does? Is resolution legal on an already-resolved visit — i.e. may a coordinator edit current state directly?
3. **Your call — error shapes.** I wrote "each distinguishable by the caller" without defining codes or bodies. I'd keep concrete shapes out of the LLD and pin them as EARS lines in Phase 3; say if you'd rather see a table here.
4. **Your call — idempotency details.** Key scope (global/per-visit/per-author), whether "identical payload" tolerates a re-stamped capture time, and whether *resolution* carries idempotency too. The last one looks like a real omission to me.
5. **Defer or drop.** Identifying a coordinator-authored revision by author ID breaks if a coordinator also submits as a field worker — the resolution record pointing at it is the sufficient test, so I'd simply say so. "Contributing submission IDs" needs a definition for the Select outcome. Revision-history ordering is unspecified.

Three things to come back on:

- **Which probe items to fix in the LLD now** — my suggestion is 1, 2, and the resolution-idempotency half of 4, with 3 and the rest of 4 landing as specs in Phase 3, and 5 handled with one clarifying sentence each.
- **A decision doc for the concurrency choice?** This one clears the bar: two credible options traded against review volume, implementation burden, and the risk of combining related edits, and two nodes about to be sized around the result. A cold reader would be tempted to re-litigate it. The Decisions row is already written and is a fine alternative — say the word and I'll write `docs/intent/record-store/decisions/` instead, or leave it as the row.
- **One cross-segment flag.** `site-catalog-design.md` ends with "Tablet-sync's visit submission and reconciliation behavior remains pending that choice," which is now stale. That's a different segment, so I didn't touch it — want me to fix that line?

Approve or give me numbered changes, and I'll move to Phase 3 (EARS: extending REC-001–006 for the revision model, resolution, and the rejections).