Decision doc written to `docs/intent/record-store/decisions/whole-visit-revisions.md`, and the record-store LLD's Decisions & Alternatives row now links to it.

---

```markdown
---
node: record-store
---

# Decision: Whole-Visit Revisions for Concurrent Visit Edits

## Context

Visits are captured on shared, often-offline tablets and submitted to the record store days after their starting state was fetched. Two workers can correct the same visit independently, and each correction is a full set of scientific field values. The record store must turn independently edited copies into one current record without treating server arrival order as evidence that one worker's observations are more authoritative.

The concurrency policy decides how concurrent edits relate. It determines the submission envelope tablet-sync must produce, the shape of the review work two coordinators must clear before the Friday export, and which record states may enter that export. Getting it wrong either emits a scientifically wrong value silently or buries the coordinators in review.

A standing constraint applies to every option: no submitted edit may be discarded, and every exported value must remain traceable to the submission it came from (HLD tenets *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable*). This is background, not a discriminating element — both options below satisfy it.

## Decision Elements

No option fails a binary gate; the decision turns on the weighted criteria below.

- **Scientific integrity of the current record — major.** Turns on the HLD non-goal against inferring scientific intent: the store must not produce a combined value whose parts were scientifically related but combined without a human noticing.
- **Coordinator review workload — major.** Turns on the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. Two coordinators must clear review between submissions and the Friday export.
- **Export readiness — moderate.** The fraction of submitted visits that can enter the Friday export without manual coordinator work; the partner expects a reviewed CSV weekly.
- **Implementation and maintenance burden — major.** The recurring engineering effort to keep correct behavior as the domain evolves. Merge rules the store itself must maintain are the specific concern.
- **Submission size and offline cost — moderate.** The bytes each tablet sends per edit and the local state it must retain while disconnected, measured across 24 workers on 12 shared tablets during 48-hour disconnections.
- **Field-worker rework and clarity — minor.** Whether a worker's accepted edit can be silently overridden by another's, and whether the worker can understand what happened to their submission.

Latent criteria probed and eliminated: tablet battery and network budget are dominated by submission size and add nothing above it; review-screen usability is a downstream design concern, not a property of the policy.

## Options in the Domain

### Whole-visit revisions

Each edit names the revision it started from. The store retains every submitted revision as a complete visit. An edit submitted against a revision another edit has already advanced past becomes a competing branch tip; the visit is unresolved until a coordinator selects one tip as the current state. A submitted visit is never split, and no two submissions are ever combined.

*Demonstration:* workers A and B both hold visit `V` at revision `r7`. A fixes an observer's name and submits against `r7`; the store records `r8` as the new tip. B adds a missing species, also against `r7`. Because `r7` is no longer the tip, B's revision `r9` competes with `r8`, and `V` enters the review queue. A coordinator compares `r8` and `r9` and selects one entire visit as current.

*Analysis:*
- Scientific integrity of the current record — **strong.** No value is ever composed from two submissions, so a species re-identification can never be paired automatically with a cover estimate from a different worker.
- Coordinator review workload — **weak.** Every edit made against a superseded revision forks, including edits to unrelated fields; the queue is as large as the number of stale-base submissions.
- Export readiness — **partial.** Visits with a fork wait for a coordinator; an unrelated-field fork is held out even though there is no scientific conflict.
- Implementation and maintenance burden — **strong.** The store compares and selects whole payloads; it maintains no field-aware merge rules.
- Submission size and offline cost — **weak.** Each submission is the full visit, and the tablet must hold the base revision ID it is editing against.
- Field-worker rework and clarity — **partial.** A worker's accepted revision can be superseded by the coordinator's selection, though their submission is never discarded and remains visible in history.

*Summary:* the store that is cheapest to build and safest to be wrong in, at the price of the largest review queue.

### Field-aware three-way merge

Each edit supplies the base state it started from and the changes it made, as structured field-level changes. The store combines changes that touch disjoint fields automatically and sends only overlapping changes to review. Combining rules cover scalar fields, observer lists, and species entries, and the read side exposes field-level provenance so an exported value can be attributed to its contributing edits.

*Demonstration:* with the same `r7` base, A's observer-name fix and B's added species touch disjoint fields, so the store emits a single current visit combining both with no review. Had both revised the same species' cover estimate, that field alone would go to review while the rest auto-merged.

*Analysis:*
- Scientific integrity of the current record — **weak.** Disjoint fields are combined by rule, not by meaning; a species identification corrected in one edit and its cover estimate in another are combined automatically even though they are one scientific decision. The rules cannot see that relationship.
- Coordinator review workload — **strong.** Review is limited to genuine field overlaps, a small fraction of concurrent edits.
- Export readiness — **strong.** Most visits auto-merge and reach the export without a coordinator, provided the rules keep pace with the domain.
- Implementation and maintenance burden — **weak.** The store must maintain and evolve merge rules for every structured field as the domain grows, and a rule error is a silent scientific error.
- Submission size and offline cost — **strong.** Tablets send structured changes rather than full visits and keep base snapshots to compute them.
- Field-worker rework and clarity — **partial.** Most edits survive untouched, but an auto-combined result can attribute a value to a worker who did not write it, and a combined record is harder to explain.

*Summary:* the smaller review queue and higher export throughput, paid for with merge rules that can silently cross scientific relationships.

## Selection

Whole-visit revisions is selected. It is the stronger option on the two criteria the team cannot absorb a failure in — scientific integrity and maintenance burden — and its two weak criteria are costs the team accepts.

- **Scientific integrity lands with the tenet against inferring scientific intent.** A merge rule that pairs a re-identified species with a cover estimate from a different edit produces a current record no worker ever submitted. Whole-visit revisions never combine two submissions, so this class of error cannot occur; the cost moves to the review screen, where a human sees both whole visits.
- **Maintenance burden becomes a one-time cost instead of a standing one.** Whole-visit revisions need no merge rules to maintain as the domain changes, matching *Prefer workflows two coordinators can operate without a dedicated systems administrator* — no engineering effort is required to keep review behavior correct.
- **The weak criteria are the accepted trade.** Review workload and export readiness are worse: every stale-base edit, including an unrelated one, creates review work and holds the visit out of the export until a coordinator resolves it. With two coordinators and a weekly cadence, the team takes the larger queue over the risk of a silently wrong automatic combination.

This decision deliberately forecloses automatic combination of concurrent edits. Field-aware merge remains the credible alternative: it is worth revisiting if review volume outgrows what two coordinators can clear before the export, or if the domain's merge rules can be brought to the point where combining disjoint fields cannot cross a scientific relationship. The decision must then be remade on scientific-integrity grounds, not reversed for the convenience of a smaller queue.

**What this obligates downstream:**

- **Tablet-sync.** Cache the base revision ID with every cached visit and submit each edit against that ID as a complete visit. The local draft and retry state machine must expect that an accepted submission may land as a competing revision rather than becoming current, and must retain the base revision until the server accepts. Submissions carry the full visit, and the tablet stores the base revision ID rather than a base snapshot.
- **Review-export.** Present competing whole revisions side by side for a coordinator to compare — a revision comparison screen, not a field-merge editor. Read the unresolved-work flag and submission history from the record store, and hold any visit with unresolved work out of the partner CSV. Field-level provenance is not required; provenance is whole-revision.
```

---

Still open from the Phase 2 stop, which you didn't address:

1. **Gap triage.** Which of the edge-case gaps I listed should I close in the LLD now, and which become deferred open questions? (Item 3 already defers unknown/foreign base-revision validation — say if that should instead be closed.)
2. **Phase 3 approval.** Once the gaps are triaged, may I move to Phase 3 and draft the record-store EARS specs, or do you want changes to the LLD/decision doc first?