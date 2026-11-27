**Decision doc written** — `docs/intent/record-store/decisions/concurrent-visit-edits.md`, owned by record-store, linked from the Decisions & Alternatives row.

How it's built so a cold reader can re-run the judgment:

- **Context** — the domain facts that force the decision (24 workers, 12 shared tablets, 48-hour offline windows, workers comparing notes), and what's at stake in *both* directions: a permissive answer ships cover estimates nobody approved, a restrictive one hands two coordinators a queue they clear by rubber-stamping.
- **Decision Elements** — one gate (no submitted edit discarded, which eliminates arrival-order overwrite outright) and seven weighted criteria. Two are major: the risk of combining scientifically related edits unnoticed, and review volume before the Friday export. Each names the tenet, goal, or non-goal it turns on. Two criteria cut *against* the choice we made, and they're in there as such — review volume is scored **weak** for whole-visit revisions and **strong** for the merge.
- **Options in the Domain** — three, each argued as its advocate would. The merge option gets a full case: disjoint edits never reach a coordinator, more visits are export-ready on Friday, review attention concentrates on genuine same-field disagreement, smaller submissions — with a worked example of the observer-name/missing-species pair sailing through. Overwrite is there because it's today's behavior, and it's shown being eliminated by the gate rather than argued down.
- **Selection** — the two major criteria pull opposite ways, so it turns on which failure is recoverable: an oversized queue is visible, countable, and fixable later; a merge that pairs a revised identification with a stale cover estimate is plausible, unflagged, and reaches the partner as agreed data.

**Why we'd still consider the merge** — the doc closes with what would reopen it, as a measurement rather than an argument: if the Friday queue is consistently dominated by disjoint-field pairs *and* coordinators are clearing it faster than they could be reading it, review volume has begun defeating the protection it buys. It also names the narrower reversal to weigh first — automatic combination limited to fields with no botanical dependency (observer list, notes), with observation date and all species entries still going to review.

**What the downstream work must accommodate** — in the doc's Selection section, and mirrored in the LLD's Downstream Contract Work:

- *tablet-sync* — store the base revision ID of every visit it fetches, send complete payloads rather than change sets, retry on the idempotency key, show a worker that a submitted visit is *awaiting resolution* rather than reporting it filed, and handle a rejected base revision with a re-fetch.
- *review-export* — a revision comparison screen, resolution called with the exact tip set displayed, handling of the stale-tip-set rejection when a late submission lands mid-review, unresolved visits held out of the CSV, and queue size visible before Friday. Export eligibility becomes a function of resolution state.
- Coordinator-authored resolution is the *only* path by which related edits get combined, so review-export treats authoring one as a first-class weekly action, not a fallback.

Two things from the last stop are still open, and I've left both untouched:

1. **Which probe items to fix in the LLD.** My suggestion stands: the revision state machine (status on linear extension, per-visit serialization of same-base submissions, whether `competing_tips` includes the current revision) and resolution's edges (all-tips vs subset, the authored revision's base tip, validation parity, resolution on an already-resolved visit), plus resolution idempotency — with error shapes and the remaining idempotency details landing as EARS lines in Phase 3.
2. **The stale line in `site-catalog-design.md`** — "Tablet-sync's visit submission and reconciliation behavior remains pending that choice." Different segment, so it needs your go-ahead.

Say yes to those (or give me numbered changes to the decision doc) and I'll close Phase 2 and move to Phase 3.