I've finished the Phase 2 LLD update for `record-store` (`docs/intent/record-store/record-store-design.md`) using whole-visit revisions, and updated `record-store`'s status in `docs/high-level-design.md` from `Drafted; concurrency choice open` to `Drafted`.

### Updated `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence, revision lineage, and the definition of a current visit when independently edited copies arrive from offline tablets. A visit is identified by a client-generated UUID (`visitId`) and references a catalog `plotId` from `site-catalog`. Tablets can be offline for 48 hours or more, so the server cannot treat arrival order as evidence that one worker's observations are more authoritative than another's.

A visit's scientific fields—observation date, observer list, species cover estimates, and notes—are often scientifically coupled (for example, revising a species identification alongside its cover estimate). Rather than attempting automated field-level merging that could combine scientifically incompatible edits without notice, `record-store` treats each submitted visit as an atomic whole-visit revision. Every valid submission is preserved intact, and concurrent edits are routed to coordinator review.

## Architecture

The record store exposes five logical operations:
1. **Submit visit revision**: Authenticated submission of a new visit or an edit to an existing visit.
2. **Get visit current state**: Retrieval of a visit's current usable revision, review status, and any open competing revisions.
3. **Get visit history**: Retrieval of all preserved original submissions and coordinator resolutions for a visit.
4. **List unresolved visits**: Query for visits currently awaiting coordinator review.
5. **Resolve visit conflict**: Coordinator-authenticated resolution of an unresolved visit's competing revisions.

Persistence separates immutable original submissions (`revisions`) and coordinator decisions (`resolutions`) from the derived visit head state (`currentRevisionId`, `reviewStatus`). Original submitted payloads are never mutated or overwritten.

## Visit Data and Validation

Before accepting any submission, the server authenticates the submitting worker (deriving `authorId` from the authentication context) and validates:
- Required field types and structure: `plotId` (UUID), `observationDate` (ISO-8601 date), `observers` (non-empty list of observer identifiers/names), `speciesCovers` (list of species cover entries), and `notes` (optional string).
- Plot reference: `plotId` must resolve in `site-catalog`. Archived plots remain valid targets so offline workers can submit corrections to historical visits.

## Revision Model & Concurrency Policy

Every visit tracks a `currentRevisionId` (nullable only if an initial creation itself entered conflict) and a `reviewStatus` of `clean` or `unresolved`:

- **Initial creation (`baseRevisionId: null`)**: When no revisions exist for `visitId`, the submission is accepted as `currentRevisionId` and `reviewStatus` is set to `clean`.
- **Linear edit**: When `reviewStatus` is `clean` and the submission's `baseRevisionId` equals `currentRevisionId`, the submission advances `currentRevisionId` to the new `revisionId` and `reviewStatus` remains `clean`.
- **Concurrent / competing edit**: When a submission's `baseRevisionId` exists in the visit's revision history but does not match `currentRevisionId` (including a duplicate `baseRevisionId: null` submission for an existing `visitId`), or when the visit's `reviewStatus` is already `unresolved`, the submission is accepted and stored as a competing revision. `reviewStatus` becomes (or remains) `unresolved`, and `currentRevisionId` is left unchanged at the last clean or resolved revision.
- **Unknown base revision**: If `baseRevisionId` is non-null and does not match any revision of `visitId`, the submission is rejected (`422 Unprocessable Entity`) without storing a revision.

### Idempotency

Every submission carries a client-generated `idempotencyKey`:
- Repeating an accepted `idempotencyKey` with an identical `visitId`, `baseRevisionId`, and payload returns the original acceptance response without creating a new revision.
- Reusing an accepted `idempotencyKey` with a different `visitId`, `baseRevisionId`, or payload is rejected (`409 Conflict`) and leaves the original submission untouched.

## Submission & Retrieval Contracts

### Submission Envelope

Used by `tablet-sync` when uploading local drafts or edits:

| Field | Direction | Type / Description |
|---|---|---|
| `visitId` | Request | Client-generated UUID |
| `idempotencyKey` | Request | Client-generated UUID per logical edit |
| `baseRevisionId` | Request | `string \| null` (`null` for new visit; prior `revisionId` for edits) |
| `payload` | Request | `{ plotId, observationDate, observers, speciesCovers, notes }` |
| `revisionId` | Response | Server-assigned UUID for this stored revision |
| `authorId` | Response | Authenticated worker ID |
| `receivedAt` | Response | Server UTC receipt timestamp |
| `reviewStatus` | Response | `clean` \| `unresolved` |
| `currentRevisionId` | Response | `string \| null` |

### Current-State Retrieval

Retrieving a visit returns:
- `visitId`
- `reviewStatus`: `clean` | `unresolved`
- `exportEligible`: boolean (`true` iff `reviewStatus === 'clean'`)
- `currentRevision`: the full revision object (`revisionId`, `baseRevisionId`, `authorId`, `receivedAt`, `payload`) for `currentRevisionId`, or `null` if none exists
- `competingRevisions`: empty array when `clean`; ordered list of all open competing revision objects when `unresolved`

### Submission-History Retrieval

Retrieving history for a visit returns:
- `revisions`: all persisted original revisions in `receivedAt` order
- `resolutions`: all coordinator resolution records in `resolvedAt` order

## Review & Resolution Contract

### Unresolved-Work Listing

Used by `review-export` to populate the coordinator review queue. Returns all visits where `reviewStatus === 'unresolved'`, each with `visitId`, `currentRevision` (the common ancestor / last clean state, if any), and `competingRevisions`.

### Resolution Operation

A coordinator resolves an `unresolved` visit by submitting:
- `visitId`
- `expectedCompetingRevisionIds`: the exact set of competing revision IDs the coordinator reviewed
- Resolution choice: either `selectedRevisionId` (promoting one of the competing revisions as-is) or `editedPayload` (a coordinator-authored whole-visit payload stored as a new revision)
- `resolutionNote`: optional explanation

The server derives `coordinatorId` from the authentication context and verifies that the visit is `unresolved` and that the current open competing revision IDs match `expectedCompetingRevisionIds`. If a new competing revision arrived after the coordinator loaded the visit, the server rejects the resolution (`409 Conflict`) so the new revision is not silently bypassed.

On success, the server persists a resolution record (`resolutionId`, `coordinatorId`, `resolvedAt`, `contributingRevisionIds`, `resultingRevisionId`, `resolutionNote`), updates `currentRevisionId` to `resultingRevisionId`, and transitions `reviewStatus` to `clean`.

## Downstream Obligations

- **tablet-sync**: Must persist `baseRevisionId` (`null` for new visits, server `revisionId` for edits) and a stable `idempotencyKey` per submission attempt across retries and restarts. Must surface `reviewStatus: unresolved` outcomes clearly so field workers know their submission was preserved and queued for coordinator review.
- **review-export**: Must exclude visits with `reviewStatus === 'unresolved'` (`exportEligible: false`) from the partner CSV export. Must present `currentRevision` alongside `competingRevisions` for whole-visit comparison and pass `expectedCompetingRevisionIds` when submitting a resolution.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions with coordinator review | Field-aware three-way merge | Preserves each worker's visit as a coherent scientific unit and avoids silent cross-field merge errors (e.g., species ID vs. cover estimate) or maintaining per-field merge rules, trading a larger coordinator review queue for simpler semantics and safer scientific records. |
| Coordinator resolution modes | Promote an existing competing revision or submit a coordinator-edited whole-visit revision | Promote existing revision only | Allows a coordinator to combine valid observations from two competing visits (e.g., one worker's observer fix and another's cover correction) into a single clean revision while preserving both original submissions. |
| Resolution concurrency guard | Optimistic check via `expectedCompetingRevisionIds` | Last-writer-wins on resolution | Prevents a coordinator from accidentally marking a visit `clean` when a third offline tablet submitted another competing revision during review. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Concurrent edit policy: Whole-visit revisions selected over field-aware three-way merge.

### Deferred
1. Pagination and filtering parameters for the unresolved-work listing endpoint (can be sized when `review-export` is designed).

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
```

---

### LLD-Level Edge-Case Probe (for your triage)

A blind subagent probe of `record-store-design.md` surfaced these 8 internal gaps. Which ones should we resolve in the LLD now vs. defer to `Open Questions & Future Decisions`?

1. **Null `currentRevisionId`**: The LLD says `currentRevisionId` is "nullable only if an initial creation itself entered conflict," but the initial-creation rule sets `currentRevisionId` to the first submission's `revisionId` and `reviewStatus` to `clean` when no revisions exist. Should `currentRevisionId` simply be non-null for every existing visit (since the first arrival sets it)?
2. **`idempotencyKey` scope and replay semantics**: Is `idempotencyKey` scoped per `authorId` or globally; are rejected requests (e.g., `422` for unknown `baseRevisionId`) excluded from idempotency tracking; and does a replayed accepted request return the original `reviewStatus`/`currentRevisionId` snapshot or the visit's current state?
3. **Post-resolution late arrivals**: If a visit is resolved to `clean` (`R4`) and an offline tablet later submits an edit with `baseRevisionId` pointing to a previously resolved competing revision (`R2`), how does `record-store` define "open" competing revisions so `R2` and other already-resolved revisions are not resurfaced in `competingRevisions`?
4. **Coordinator `editedPayload` lineage**: When a coordinator resolves via `editedPayload`, is it validated against the same field rules and `site-catalog` `plotId` check, what `baseRevisionId` and `authorId` are recorded on the resulting revision, and does it appear in `Get visit history`'s `revisions` list?
5. **Ambiguous or out-of-set resolution choices**: How should `Resolve visit conflict` behave if both `selectedRevisionId` and `editedPayload` are provided, neither is provided, or `selectedRevisionId` is a valid revision of the visit (e.g., `currentRevisionId`) that is not in `expectedCompetingRevisionIds`?
6. **Resolution retry idempotency**: Unlike `Submit visit revision`, `Resolve visit conflict` has no `idempotencyKey`—should it carry one, or does a retry after a lost response fail with `409 Conflict` because `reviewStatus` is now `clean`?
7. **Deterministic ordering**: What tie-breaker orders `competingRevisions`, `Get visit history` when timestamps tie, and `List unresolved visits`?
8. **Auth, lookup, and validation error shapes**: What status codes, error body shapes, and field invariants apply to unauthenticated/non-coordinator callers, unknown `visitId` on `Get`/`Resolve`, unknown `plotId`, and `speciesCovers` structure/bounds (including whether an empty `speciesCovers` list is valid)?

---

### Decision Doc Offer

Because the whole-visit revisions choice trades competing criteria (scientific unit integrity and simpler rules vs. coordinator review volume) and sizes both `tablet-sync` and `review-export`, would you like me to record it as a full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from `record-store-design.md`), or is the `Decisions & Alternatives` table row sufficient?

---

Please let me know:
1. Any edits to `record-store-design.md` and how you'd like to triage the 8 edge-case questions above.
2. Whether you want the standalone decision doc.
3. Whether we're approved to proceed to **Phase 3** (updating `docs/intent/record-store/record-store-specs.md`).