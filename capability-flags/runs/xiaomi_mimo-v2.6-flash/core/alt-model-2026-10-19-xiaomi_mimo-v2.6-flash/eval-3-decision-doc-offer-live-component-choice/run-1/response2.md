**Decision doc written** at `docs/intent/record-store/decisions/whole-visit-revisions.md`. Stopping for your review before Phase 2.

```markdown
# Decision: Concurrent visit edits resolved as whole-visit revisions

## Context

Field workers edit the same visit offline on shared tablets; updates can arrive days
after their starting state was fetched. The record store must define what a current
visit means when independently edited copies compete, without treating arrival order as
evidence of authority. Original submissions must always be retained. The shape of
tablet submission state, the coordinator review interface, and export eligibility all
hang on this choice: a wrong pick either corrupts scientific records in ways nobody
notices, or saddles two coordinators and future maintainers with a system they cannot
safely operate.

## Decision Elements

### Gates

- **Retain every original submission** *(inherited — HLD tenet "Do not silently discard
  a submitted edit")*: the policy must keep both contributing submissions intact
  regardless of how a current state is reached. Both options pass.
- **Preserve offline capture** *(inherited — HLD tenet "Let field workers continue
  collecting observations without connectivity")*: the policy must work when the tablet
  has been disconnected for up to 48 hours and only learns of competition at the next
  sync. Both options pass.

### Weighted criteria

- **Silent scientific corruption risk — major** *(tenet: Keep the path from a submitted
  observation to an exported value inspectable; HLD non-goal: automated botanical
  validation or inference of scientific intent)*: how likely is the policy to produce a
  current record whose combined values no human judged as a pair?
- **Operable by two coordinators without a systems administrator — major** *(tenet:
  Prefer workflows two coordinators can operate without a dedicated systems
  administrator)*: what ongoing maintenance does the policy impose once the first
  release ships?
- **Review volume at Friday-export scale — moderate**: with ~6,000 visits per season and
  independent corrections of the same visit, how much coordinator work does each
  concurrent edit generate?
- **Tablet submission complexity — moderate**: what must a worker's tablet retain and
  send so the server can apply the policy?
- **Export readiness — moderate**: what fraction of submitted visits can reach the
  export set without human resolution?
- **Whole-visit fidelity — minor**: does the current record preserve each worker's
  visit as the unit they actually submitted?

## Options in the Domain

### Whole-visit revisions

Each submission names the base revision it was edited from and carries a complete visit
payload. When a submission's base revision is no longer current, the server stores it
as a competing revision rather than combining it. A coordinator compares complete
revisions side by side and picks or hand-applies a resolution; only then does the visit
become current again. Tablets need only remember a base revision ID (a short token)
alongside each draft. Review work is whole-record comparison; export admits only visits
with no unresolved competition.

- **Silent scientific corruption risk — strong**: no value enters the current record
  without a human seeing the competing visits together; scientifically related fields
  can never be stitched by a rule that does not know they are related.
- **Operable without a systems administrator — strong**: there are no field-combination
  rules to maintain as species lists, observer-list semantics, or cover-estimate formats
  evolve; the resolution interface is a comparison view, not a rule engine.
- **Review volume — weak**: even edits to disjoint fields (an observer-name fix and a
  missing species) each open a resolution task; coordinator workload grows with every
  concurrent edit.
- **Tablet submission complexity — strong**: the tablet stores a base revision ID and
  sends a full payload; no base snapshot diffing or structured change log.
- **Export readiness — weak**: any visit with a competing revision is held out of the
  CSV until resolved, so last-minute edits before Friday shrink the export set.
- **Whole-visit fidelity — strong**: what the worker submitted is exactly what a
  revision contains.

Summary: maximal human judgment and minimal merge machinery, paid for with a larger
review queue and more visits waiting on a coordinator before export.

### Field-aware three-way merge

Each submission carries its base snapshot plus the structured changes the tablet
applied. The server auto-combines changes that touch disjoint fields and surfaces only
true overlaps for review. Observer lists and species entries need maintained
combination rules; scalar fields merge trivially. Tablets retain base snapshots and
transmit change sets. Review sees field-level provenance on overlapped fields; export
can admit auto-merged visits once policy says whether auto-merges need approval.

- **Silent scientific corruption risk — partial**: disjoint scalar edits combine safely,
  but species identification and its cover estimate — or any pair of fields the rule
  treats as independent when science links them — can be auto-joined with no one
  noticing; field-level provenance shows what happened after the fact, not that the
  combination is scientifically coherent.
- **Operable without a systems administrator — weak**: combination rules for observer
  lists, species entries, and future field types are permanent surface area; each schema
  change risks a rule that merges wrong.
- **Review volume — strong**: unrelated concurrent edits (the common case in
  independent corrections) never reach a coordinator; only overlaps do.
- **Tablet submission complexity — partial**: the tablet must retain base snapshots for
  the offline period and emit a structured change log, larger and more failure-prone
  than a revision ID plus payload.
- **Export readiness — strong**: most concurrent edits auto-combine, so more visits are
  export-ready by Friday without coordinator action.
- **Whole-visit fidelity — partial**: each submission still stores its original payload,
  but the current record may be a blend no worker ever submitted as a visit.

Summary: less review work and faster export, paid for with merge-rule maintenance and
auto-combinations that can cross scientific relationships without detection.

The field-aware approach remains a credible future option. It would win if review
volume at scale forced automation, or if a later requirement demanded a high
auto-export rate and the team could fund ongoing rule maintenance. It is rejected for
this release because the project has no administrator to own the rules and because the
cost of a wrong auto-merge — an export the science partner cannot trace — is worse than
the cost of an extra comparison task.

## Selection

**Whole-visit revisions.** The two major criteria decide it: merge rules are a standing
maintenance burden the two-coordinator team is explicitly not staffed to own, and
auto-combination is the one failure mode that violates the inspectability tenet
silently — the tablet and export sides cannot tell a safe disjoint merge from a
scientifically entangled one. Review volume and export readiness are real losses and
are accepted knowingly: the system ships with a bigger coordinator queue and holds
unresolved visits out of the CSV.

Committing to this option obligates downstream nodes. **Tablet-sync** must retain a
base revision ID per draft, send it with each full-payload submission, and explain to
the worker when their edit has landed as a competing revision awaiting review.
**Review-export** must provide a side-by-side revision comparison for resolution and
apply an export rule that admits only visits with no unresolved competition. Both nodes
implement against this contract rather than re-opening the concurrency policy.
```

Any changes to the doc? Otherwise, approve and I'll start Phase 2 — finishing the record-store LLD around whole-visit revisions (submission envelope with base revision IDs, competing-revision representation, resolution operation, Decisions table linking this doc, plus an LLD-level edge-case probe).