I finished the record-store LLD around whole-visit revisions. Here's what changed, for your review before I go further (Phase 2 stop):

**`docs/intent/record-store/record-store-design.md`**
- Replaced the open choice with a **Concurrency Policy: Whole-Visit Revisions** section: each visit is a revision chain; a submission naming the current revision as its base becomes the new current revision; a submission naming a stale base becomes a competing revision and opens/joins a contest; retrieval always returns the last-agreed current revision plus a contested flag, so no one is shown nothing while review is pending.
- Added a **Tablet-Sync and Review-Export Contract** section fixing the submission envelope, current-state response, unresolved-work (competing-revision set) representation, and resolution-operation shape those two nodes will size their designs around.
- Added a **Decisions & Alternatives** row recording the choice and your stated rationale (bigger review queue over opaque field-combination).

**`docs/high-level-design.md`** — record-store's state is now "Drafted" (choice no longer open), and the architecture note describes the resolved policy instead of flagging it as pending.

Two things need your judgment before I consider this phase done:

1. **Decision doc?** This choice has multiple criteria (review workload, submission size, risk of silently combining related scientific edits) and tablet-sync/review-export are about to be sized around the result — it clears the bar for a full decision doc under `docs/intent/record-store/decisions/`. I can write one, or leave it as the Decisions-table row above. Which do you want?

2. **Edge-case probe** — four gaps the revision model doesn't resolve yet; please triage (fix now vs. defer as open question, already parked in the LLD's Open Questions section):
   - Three-plus competing revisions on one contest — must resolution pick exactly one, or can a coordinator reject the whole set and ask for a resubmission?
   - A new submission whose base names an already-superseded (losing) revision — does it join the existing contest or open a second one?
   - Is resolution strictly "pick one revision verbatim," or can a coordinator lightly edit the chosen revision (e.g., fix a typo) as part of resolving?
   - While a visit is contested, is its last-agreed revision export-eligible, or does any open contest hold the whole visit out regardless of which fields are actually in dispute?