Updated `docs/intent/record-store/record-store-design.md` to resolve the open concurrency choice as whole-visit revisions, and ran a context-free edge-case probe on the draft. Here's the stop for your review.

## Updated LLD (Phase 2 output)

```
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot UUID (site-catalog). Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

This node resolves concurrent edits through whole-visit revisions (see *Concurrent Visit Edits* below). Tablet-sync and review-export are not yet designed; they size their contracts against the submission envelope, retrieval responses, and resolution operation this node now defines.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, and resolution operations. Persistence keeps every accepted submission, its author, and its server receipt time — a submission is never overwritten or discarded, only superseded. Each accepted submission is a **revision** of its visit; a submission's base revision ID records which revision it was edited from, and is absent only for a visit's first submission (its root revision). A submission carries an idempotency key so a connection failure does not create another edit on retry.

A visit's scientific fields are observation date, observer list, species cover estimates, and notes. Edits can be unrelated (correcting an observer name, adding a missing species) or scientifically coupled (revising a species identification together with its cover estimate) in ways the server cannot infer from field names alone — this is why the concurrency mechanism below treats a visit as a single indivisible unit rather than attempting to combine edits field by field.

## Submission and Retrieval

Authenticate the submitting worker and validate field types and plot references before accepting a submission. Preserve the original payload separately from any later resolved representation. A retry with the same idempotency key and identical payload returns the original acceptance result; reuse with a different payload is rejected.

Retrieval distinguishes a usable current state from unresolved review work (see *Current-State Response* below): a visit with exactly one head revision returns that revision as current; a visit with competing head revisions reports itself as unresolved and asserts no current payload.

## Concurrent Visit Edits: Whole-Visit Revisions

Each visit is a chain of revisions rooted at its first submission. A revision is a **head** when no other live revision names it as a base — nothing has been built on top of it yet. A visit has exactly one head in the common case, where each worker edited the most recently known state. A visit has **competing heads** when two or more submissions name the same base revision: two or more workers independently edited the same starting state before any of their submissions reached the server. Three or more submissions can name the same base, producing three or more competing heads.

Competing heads are not combined. They persist side by side, unresolved, until a coordinator resolves them. Because resolution operates on the whole visit rather than individual fields, a competing pair that touches entirely unrelated fields — an observer-name correction against a missing-species addition — still becomes review work; the mechanism does not inspect field names to decide such a pair is safe to combine automatically.

**Resolution.** A coordinator reviews a visit's competing head revisions and produces a new head by either: (a) selecting one competing revision outright, or (b) submitting a new revision, based on one of the competitors, that incorporates whatever the coordinator chose to carry forward from the others. The resolution record carries the coordinator's identity, the IDs of every competing revision it resolved, and the resulting head revision ID. Revisions that lose a resolution remain in the submission history; a visit's revision chain only ever grows.

## Downstream Contract

### Submission Envelope

| Field | Description |
|---|---|
| `visitId` | Client-generated UUID identifying the visit. |
| `plotId` | Catalog plot UUID (site-catalog). |
| `baseRevisionId` | The revision this submission edits from. Absent for a visit's first submission. |
| `idempotencyKey` | Caller-generated key for safe retry. |
| `authorId` | Submitting worker's identity. |
| `observationDate`, `observerList`, `speciesCoverEstimates`, `notes` | The visit's scientific fields. |

### Current-State Response

- **Single head**: `status: "current"`, the head revision's full payload, its revision ID, and its author and server receipt time.
- **Competing heads**: `status: "unresolved"`, no current payload asserted. The competing revisions themselves are retrieved through the unresolved-work representation below.

### Unresolved-Work Representation

For a visit with competing heads: `visitId`, `plotId`, the shared `baseRevisionId`, and one entry per competing revision carrying its revision ID, author ID, server receipt time, and full payload.

### Resolution Operation

- **Input**: `visitId`, the set of competing revision IDs being resolved, the coordinator's identity, and either the ID of the chosen existing revision or a new payload (with its own base revision among the competitors).
- **Output**: a resolution record with the coordinator's identity, the contributing (competing) revision IDs, the resulting head revision ID, and the resolution time.
- **Effect**: the resulting revision becomes the visit's sole head.

Tablet-sync sizes its local storage and retry state machine around the submission envelope. Review-export sizes its coordinator interface and export eligibility (excluding unresolved visits) around the current-state and unresolved-work responses. Both link back to this node rather than invent their own concurrency semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrency mechanism for competing visit edits | Whole-visit revisions: submissions sharing a base revision stay separate as competing heads until a coordinator resolves them | Field-aware three-way merge: auto-combine disjoint field edits, route only overlapping fields to review | Favors a larger review queue over any chance of silently combining edits that are scientifically related but land on different fields — a relationship field-aware merge rules cannot see from field names alone. Preserving every submitted visit as an indivisible unit also keeps the path from submission to export inspectable without maintaining a growing set of per-field-type merge rules. |
```

## Decision-doc offer

Tablet-sync and review-export are about to be sized around this choice, and a cold reader would plausibly re-litigate it ("why not merge, which cuts review volume?"). That clears the bar for offering a full decision doc (laying out gates/criteria/options in `docs/intent/record-store/decisions/`) instead of just the table row above. Want one, or is the table row enough?

## LLD-level edge-case probe (blind reader, record-store doc only)

1. Does a resolution's new revision (option b) go through the same auth/validation/idempotency path as an ordinary submission, or is it a distinct write path?
2. Must a resolution's input set of competing revision IDs exactly match the visit's current competing heads, or is partial resolution allowed?
3. If a resolution incorporates material from more than one competitor, what's the `baseRevisionId` of the resulting revision — the doc says "a base revision" (singular) but "the others" (plural)?
4. Can a new submission name a `baseRevisionId` that already lost a past resolution (is in history but not a head)? Accepted as a new competing head, rejected, or something else?
5. Is `baseRevisionId` validated against the visit's actual chain (existence/consistency with `visitId`), the way plot references are?
6. Is new submission still accepted while a visit sits unresolved (implied by "three or more" competing heads), or blocked?
7. What happens if two coordinators resolve the same visit concurrently, or a competing submission arrives after a coordinator fetched the unresolved-work view but before they submitted resolution?
8. Does the resolution operation have idempotency-key semantics like submissions, to prevent duplicate resolution records on retry?
9. When a coordinator selects an existing revision "outright" (option a), does the chain grow with a new record, or does the selected revision literally become the sole head with no new entry?
10. Can two first-submissions (no base revision) for the same `visitId` arrive from two tablets — are those competing heads, a rejected duplicate, or something else?
11. In the `"unresolved"` current-state response, is the payload field omitted, explicit `null`, or absent from the schema entirely?
12. For a resolution-produced head, is "server receipt time" the resolution time or the coordinator's submission time, and is "author" the coordinator or the original submitter?

Which of these do you want settled in the LLD now, and which should wait as open questions for tablet-sync/review-export to force an answer? Once you've triaged these (and answered the decision-doc question above), I'll fold the resolutions into the doc and move to Phase 3 (EARS specs) for this segment.