I have updated `docs/intent/record-store/record-store-design.md` for the whole-visit revision policy (and refreshed `docs/high-level-design.md` and `docs/intent/site-catalog/site-catalog-design.md` to reflect that the `record-store` concurrency policy is now settled).

Here is the updated `record-store` LLD in full:

---

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot UUID. Updates can arrive days after their starting state was fetched because tablets operate offline for up to 48 hours. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated (such as correcting an observer name and adding a missing species), while others are scientifically coupled (such as revising a species identification alongside its cover estimate). Because the server cannot infer scientific relationships from field names alone, record-store treats each submitted visit as an indivisible unit via whole-visit revisions rather than merging fields automatically.

## Whole-Visit Revision Model

Every accepted submission or coordinator resolution creates an immutable revision with a server-assigned `revisionId`, author identity, server receipt timestamp, and the complete visit payload.

Each visit tracks:
- `currentRevisionId`: the latest uncontested revision, or `null` while competing revisions await coordinator review.
- `competingRevisionIds`: the set of active head revisions when concurrent edits have branched from the same prior state. Empty when the visit is resolved.

### Revision Transitions

1. **Initial submission** (`baseRevisionId: null` for a new `visitId`): creates revision $R_1$, sets `currentRevisionId = R_1`, and leaves `competingRevisionIds` empty.
2. **Linear update** (`baseRevisionId` matches `currentRevisionId` and `competingRevisionIds` is empty): creates revision $R_2$ superseding $R_1$, updates `currentRevisionId = $R_2`, and leaves `competingRevisionIds` empty.
3. **Concurrent edit on a clean visit** (`baseRevisionId` names an ancestor revision rather than `currentRevisionId`, or `baseRevisionId: null` when the visit already exists): creates revision $R_3$, clears `currentRevisionId` to `null`, and places both the previous `currentRevisionId` and $R_3$ into `competingRevisionIds`.
4. **Additional edit on a conflicted visit** (submission arrives while `competingRevisionIds` is non-empty): creates revision $R_n$. If `baseRevisionId` matches one of the revisions currently in `competingRevisionIds`, $R_n$ replaces that base revision in `competingRevisionIds` (advancing that branch); otherwise $R_n$ is added to `competingRevisionIds` as another competing branch. `currentRevisionId` remains `null`.
5. **Coordinator resolution**: a coordinator submits a resolved visit payload citing the exact set of `competingRevisionIds` being resolved. This creates a new revision $R_{\text{res}}$ recording the coordinator's identity and the resolved `competingRevisionIds`, sets `currentRevisionId = R_{\text{res}}`, and clears `competingRevisionIds`.

## Operations and Contracts

| Operation | Input | Output / Behavior |
|---|---|---|
| Submit Visit (`POST /visits/{visitId}/revisions`) | `idempotencyKey`, `baseRevisionId` (`null` or revision UUID), `payload` (`plotId`, `observationDate`, `observers`, `speciesCovers`, `notes`), authenticated worker identity | Validates field types and checks that `plotId` exists in `site-catalog` (active or archived). Stores original submission and transitions revision state. Returns `revisionId`, `visitStatus` (`current` or `needs_review`), `currentRevisionId`, and `competingRevisionIds`. |
| Get Visit (`GET /visits/{visitId}`) | `visitId` | Returns `visitId`, `visitStatus` (`current` or `needs_review`), `currentRevision` (full revision if `current`, else `null`), and `competingRevisions` (full revision objects if `needs_review`, else empty). |
| List Visits (`GET /visits`) | Optional `status` filter (`current` or `needs_review`) | Returns matching visits with their `visitId`, `visitStatus`, `currentRevision` (if `current`), and `competingRevisions` (if `needs_review`) so `tablet-sync` and `review-export` can fetch active or review-queued visits. |
| List Revisions (`GET /visits/{visitId}/revisions`) | `visitId` | Returns the complete chronological history of submitted and resolved revisions for audit and provenance inspection, including each revision's `revisionId`, `baseRevisionId` or `resolvedRevisionIds`, `authorId`, `receivedAt`, and `payload`. |
| Resolve Visit (`POST /visits/{visitId}/resolutions`) | `idempotencyKey`, `resolvedRevisionIds` (non-empty set of revision UUIDs), `payload` (complete visit fields), authenticated coordinator identity | Verifies `resolvedRevisionIds` matches the visit's current `competingRevisionIds`. Creates a resolution revision, sets `visitStatus` to `current`, updates `currentRevisionId`, and clears `competingRevisionIds`. Rejects with conflict if `competingRevisionIds` has changed since the coordinator loaded the review. |

### Idempotency and Validation

- **Idempotency**: Submissions and resolutions carry a client-generated `idempotencyKey`. Repeating an accepted key with an identical request body returns the original acceptance response without creating a duplicate revision. Repeating an accepted key with a different request body is rejected and leaves stored state unchanged.
- **Plot Reference Validation**: A submission or resolution referencing an unknown `plotId` is rejected. References to archived plots are accepted so historical or late-arriving offline edits are not lost.
- **Lineage Validation**: If `baseRevisionId` is non-null and does not belong to `visitId`, the submission is rejected.

## Downstream Contract Obligations

- **tablet-sync**: Must persist the server-assigned `revisionId` when caching a visit and send it as `baseRevisionId` on subsequent edits. When a submission response returns `visitStatus: needs_review`, the tablet must record that the visit is pending coordinator review rather than treating its local copy as the single authoritative state.
- **review-export**: Must query visits with `visitStatus: needs_review` to populate the coordinator's revision comparison screen, submit the coordinator's chosen or synthesized visit payload with `resolvedRevisionIds` to `POST /visits/{visitId}/resolutions`, and hold any visit with `visitStatus: needs_review` out of the Friday partner CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with explicit `baseRevisionId` lineage and coordinator resolution | Field-aware three-way merge; last-writer-wins by receipt timestamp | Preserves each worker's observation as a scientifically coherent whole without maintaining field-merge rules that could silently combine coupled botanical edits (such as species identity and cover percentage). Last-writer-wins violates the tenet against silently discarding submitted edits. |

## Open Questions & Future Decisions

### Resolved
1. ✅ **Concurrent visit edit policy**: Selected whole-visit revisions over field-aware three-way merge so coupled scientific fields are never auto-combined without coordinator review.

### Deferred
1. *(None)*

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
```

---

### Decision Doc Offer

Because the choice between whole-visit revisions and field-aware three-way merge weighs competing criteria (scientific coupling safety, coordinator review load, merge rule maintenance) and sizes both `tablet-sync` and `review-export`, a cold reader could be tempted to revisit it later. Would you like to record this in a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the Decisions table), or is the row in **Decisions & Alternatives** above sufficient?

### Phase 2 LLD Edge-Case Probe

Before we move to Phase 3 (`record-store-specs.md`), please triage which of these component-level edge cases you want specified in the LLD now vs. deferred as open questions:

1. **Advancing vs. preserving competing revisions on a conflicted visit (Transition 4)**: When a visit already has `competingRevisionIds: [R1, R2]` and a worker submits `R3` with `baseRevisionId: R1`, the draft above replaces `R1` with `R3` in `competingRevisionIds` (advancing that branch while `R1` stays in history). Should `R3` replace `R1` in the active competing set, or should `R1` remain in `competingRevisionIds` alongside `R2` and `R3` until a coordinator resolves them?
2. **Concurrent edits with identical payloads**: When two workers branch from the same `baseRevisionId` (with different `idempotencyKey`s) and submit identical visit payloads, should `record-store` still mark the visit `needs_review` with both revisions in `competingRevisionIds`, or auto-collapse identical payloads without coordinator review?
3. **`plotId` mutability across revisions**: Can a subsequent revision or coordinator resolution change a visit's `plotId` (e.g., if a worker initially picked the wrong plot on the tablet), or is `plotId` immutable once the visit is created?
4. **Idempotency replay response after subsequent state changes**: When a tablet retries an accepted `idempotencyKey` after another edit has already moved the visit to `needs_review` (or a new revision), should the response return the frozen point-in-time snapshot from the original acceptance, or the original `revisionId` paired with the visit's current `visitStatus`, `currentRevisionId`, and `competingRevisionIds`?
5. **Resolving a visit that is not in `needs_review`**: If a coordinator submits a resolution for a visit that is already `current` (e.g., the other coordinator just resolved it), we reject with a conflict error — should the conflict response include the latest visit state (`currentRevision` / `competingRevisions`) so the review screen can refresh immediately?
6. **Structural field validation boundaries**: Beyond checking that `plotId` exists in `site-catalog`, what structural rules should `record-store` enforce on visit payloads (e.g., non-empty `observers`, `speciesCovers` percentage in `(0, 100]` or `[0, 100]`, no duplicate species within a visit), given the non-goal of no automated botanical validation?

Please let me know your feedback on the LLD draft, whether you want the standalone decision doc, and how you want to handle items 1–6 before we proceed to Phase 3 (EARS specs).