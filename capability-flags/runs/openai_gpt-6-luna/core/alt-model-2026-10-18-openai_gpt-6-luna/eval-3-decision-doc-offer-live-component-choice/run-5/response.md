## Phase 2 — Record-store LLD draft

The HLD check is coherent: the revision policy belongs to the record-store node. I updated `docs/high-level-design.md` to record that whole-visit revisions are selected and that tablet-sync and review-export still depend on the record-store contract.

I drafted `docs/intent/record-store/record-store-design.md`. It defines immutable complete revisions, base revision references, competing revisions for review, and retrieval that does not pick a winner by receipt time. The draft leaves resolution outcomes and several boundary cases open for your review.

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

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Reconcile edits based on the same visit state | Preserve complete, competing visit revisions and send conflicts to review | Field-aware three-way merge that combines disjoint changes and reviews overlaps | A larger review queue is preferable to maintaining merge rules that could combine scientifically related edits without detecting their relationship. Whole-visit revisions preserve each submission as a unit and avoid automatic field-level combination. |

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
8. Define the tablet-facing request and response transport and the coordinator-facing review and export behavior in their respective design nodes after this record-store contract is settled.

## References

- [High-Level Design](../../high-level-design.md)
- [Site Catalog design](../site-catalog/site-catalog-design.md)
```

### LLD edge-case probe

Please decide which gaps to settle in this LLD now and which to leave deferred:

1. Can resolution select a submitted revision, create a complete coordinator-authored revision, or either?
2. What happens when another submission arrives during an unresolved conflict?
3. How are simultaneous initial submissions for the same new visit handled?
4. What is the idempotency-key scope, and how do simultaneous retries behave?
5. What rejection behavior is required for an invalid base revision or visit payload?
6. How is a submission ordered if it races with coordinator resolution?

The catalog validation contract crosses into the site-catalog segment, so I have left that boundary for follow-up. `git diff --check` passes. The EARS specs have not yet been updated. Please review/approve the LLD and triage the gaps; I’ll stop here for your direction before Phase 3.