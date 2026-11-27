I've finished drafting the record-store LLD around whole-visit revisions (Phase 2). Here's what changed and what needs your call before I move to specs:

**record-store-design.md**
- Resolved the open design choice into a `## Concurrency Model: Whole-Visit Revisions` section: a submission whose base names the current revision becomes current directly; a submission with a stale base becomes a *competing revision*, routed to unresolved review rather than merged. A coordinator resolves by **designating** one competing revision as current — no merge operation exists.
- Added `## Submission and Response Shapes` defining the submission envelope, current-state response, and resolution operation.
- Updated `## Downstream Contract Work` to describe what tablet-sync and review-export will size against (deferred to later sessions, as you said).
- Added a `## Decisions & Alternatives` row recording the choice and why field-aware merging was rejected.

**high-level-design.md** — the record-store row and its narrative referenced an "unresolved choice"; since it's resolved now, I updated the State column to "Drafted" and reworded the sentence to describe the (now-defined) contract rather than an open question. No architectural change, just removing stale text caught in the coherence pre-flight.

The existing REC-001..006 specs are already written generically enough that they hold under this model unchanged — I haven't touched record-store-specs.md yet; that's Phase 3, next.

Two things before I proceed:

1. **Decision doc?** This choice has real competing options traded against more than one criterion, and tablet-sync/review-export are about to be sized around the result — it clears the bar for a full decision doc rather than just the table row I added. Want one (`docs/intent/record-store/decisions/concurrency-model.md`), or is the row enough?

2. **LLD-level edge probe** — gaps in this LLD worth your triage before I draft Phase 3 specs:
   - First submission has no base revision — is an explicit sentinel needed, or does "absent" suffice as the wire representation?
   - Resolution only mentions two competing revisions in the walkthrough — does it need to handle *three or more* submissions sharing the same stale base, or is that pairwise in practice given how workers correct visits?
   - Is a coordinator's resolution reversible (re-designate a different revision later), or final once recorded?
   - Does a tablet's retrieval during unresolved review see the same "unresolved + last-known-current" shape as a coordinator's, or does the worker need a different signal to keep editing without being blocked?

Let me know how you want these resolved (or to defer any as open questions in the LLD), and whether you want the decision doc — then I'll move to Phase 3 (EARS spec updates).