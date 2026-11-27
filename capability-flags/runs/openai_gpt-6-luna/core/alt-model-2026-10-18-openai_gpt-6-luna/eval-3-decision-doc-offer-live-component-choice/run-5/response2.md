I expanded the record-store LLD with the field-aware merge’s strongest case—less review for independent edits—and why its ongoing rules could still combine scientifically related fields without recognizing the relationship. The downstream obligations now say tablets retain and submit base revision IDs with complete visits, while review/export compares competing revisions and holds unresolved visits out of the CSV.

Please review the updated LLD below. The six record-store edge cases remain open; let me know which to resolve in this design and which to leave deferred.

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

The record store accepts field visits from workers whose tablets can remain offline for up to 48 hours. Independent edits to one visit can therefore arrive after their starting state is no longer current. Arrival time does not establish which observation is scientifically authoritative.

The store preserves each accepted submitted visit as a complete, immutable revision. When submissions compete, it retains each revision and exposes the visit as unresolved rather than combining fields or silently choosing a winner. This favors preserving the workers' submitted records and making conflicts explicit over reducing review volume with automatic merge rules.

A visit has a client-generated UUID and a stable catalog plot UUID. Its scientific fields include observation date, observer names, species cover estimates, and notes. The catalog owns plot identity and metadata; the record store retains the plot UUID carried by each submitted visit.

## Architecture

The record store has three related records:

| Record | Meaning | Mutability |
|---|---|---|
| Submission | An authenticated worker's complete visit payload, idempotency key, base revision reference, author, and server receipt time | Immutable once accepted |
| Visit revision | A complete visit snapshot created from one accepted submission, identified by a server-issued revision ID and linked to its base revision when present | Immutable |
| Resolution | A coordinator's decision about the competing revisions, including coordinator identity, contributing submission IDs, and the resulting visit state | Append-only history |

Submission history is retained independently of the visit's current resolved state. A revision always contains the entire visit payload; the server does not calculate a field-level merge. A retry is matched by its idempotency key and payload and returns its original acceptance result.

## Revision and Conflict Model

The first accepted submission for a visit has no base revision and creates its initial revision. Each later submission names the revision from which the worker made the edit. The referenced revision must exist and belong to the same visit.

When a submission is based on the visit's sole current revision, it creates a new complete revision and advances that revision. When a submission is based on a known revision that is no longer the sole current revision, the store accepts it as a competing complete revision and marks the visit unresolved. It does not compare fields, merge payloads, or select a winner by receipt time. Every competing revision remains available for review.

A visit with one current revision has a usable current state. A visit with competing revisions has no single current state until a coordinator records a resolution. Retrieval returns the current revision when one exists and indicates whether unresolved work exists. Submission-history retrieval returns the immutable submissions and revision relationships needed to inspect how the visit reached its state.

The record store accepts a resolution operation and retains its actor, contributing submissions, and outcome. The exact resolution outcomes and how they create the post-review current revision are an open design question pending coordinator workflow design.

## Submission and Retrieval

Submission requires an authenticated worker, visit UUID, idempotency key, complete visit payload, and either no base revision for the first submission or a base revision ID for an edit. The store validates field types and that the plot UUID is recognized by the catalog contract before acceptance. It records the author and server receipt time with the original payload.

Repeating an accepted idempotency key with the same payload and base revision returns the original acceptance result without creating another submission or revision. Reusing that key for a different payload or base revision is rejected without changing the accepted submission.

Retrieval distinguishes a visit with one current revision from a visit with unresolved competing revisions; it never represents an unresolved visit as though receipt order selected a winner. Submission-history retrieval exposes the accepted submissions and their base/revision links. These are record-store semantics; tablet request transport and coordinator presentation remain owned by their respective design nodes.

## Downstream Contract Obligations

The tablet-sync contract must retain the server revision ID associated with the local visit snapshot and include that base revision ID with a complete visit payload on each edit. It must preserve the worker's submitted revision when the server accepts it as a competitor, report that review is needed, and avoid presenting the server as having silently combined or selected the competing edits. Retry state must retain the same idempotency key and submitted payload so an interrupted request can be repeated safely.

The review-export contract must let coordinators compare the complete competing visit revisions, with each revision's submitting worker and server receipt time available as provenance. It must keep a visit with unresolved competing revisions out of the partner CSV until a coordinator records a resolution. The record store supplies the competing revisions, their submission history, and the unresolved/resolved state; the coordinator screen, export workflow, and exact presentation are owned by review-export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Reconcile edits based on the same visit state | Preserve complete, competing visit revisions and send conflicts to review | Field-aware three-way merge using each edit's base snapshot and structured changes; combine edits to fields judged independent and send overlaps to review | Field-aware merging remains attractive because independent edits can be combined automatically, reducing review volume and helping coordinators keep the weekly export moving. It also avoids treating clearly unrelated changes as conflicts. However, scientific relationships can span fields—for example, species identification and its cover estimate—so merge rules could create a composite visit that neither worker submitted while failing to recognize a meaningful relationship. Those rules require continuing design, validation, and maintenance across visit field types. Preserving whole revisions accepts a larger review queue in exchange for retaining each worker's complete submission and avoiding automatic combinations whose scientific relationship the store cannot determine. |

The selected policy has concrete downstream costs: tablet-sync must retain and submit base revision IDs with complete visit snapshots, and review-export must present competing revisions for comparison and exclude unresolved visits from CSV export. Those obligations are preferable to maintaining server-side merge rules that may combine scientifically related edits without recognizing their relationship.

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrent edits use whole-visit revisions; the store does not automatically combine fields.

### Deferred

1. Define the resolution outcomes: whether a coordinator selects one submitted revision, records a complete coordinator-authored revision, or may do either. This determines how the post-review current revision is represented.
2. Define behavior for a new submission based on a competing revision while that visit is already unresolved, including how it appears in the set of revisions presented to review.
3. Define how simultaneous initial submissions for the same new visit UUID are handled, since neither can name a starting revision.
4. Define the idempotency-key scope and the result of simultaneous requests reusing one key.
5. Define rejection behavior for a missing or wrong-visit base revision and invalid visit data.
6. Define how a submission racing with a coordinator's resolution is ordered and represented.
7. Define the precise catalog validation boundary and failure shape with the catalog interface when the record-store integration contract is designed.
8. Define the tablet-facing request and response transport and the coordinator-facing comparison screen and export workflow in their respective design nodes. The required base-revision handling, conflict indication, revision provenance, comparison, and unresolved-visit export hold are the record-store contract obligations above.

## References

- [High-Level Design](../../high-level-design.md)
- [Site Catalog design](../site-catalog/site-catalog-design.md)
```

The unresolved record-store edge cases are: resolution outcomes; submissions arriving during an unresolved conflict; simultaneous initial submissions; idempotency scope and simultaneous retries; rejection behavior for invalid bases or payloads; and submissions racing with resolution. The HLD reflects the selected policy. The EARS specs remain unchanged pending LLD approval.