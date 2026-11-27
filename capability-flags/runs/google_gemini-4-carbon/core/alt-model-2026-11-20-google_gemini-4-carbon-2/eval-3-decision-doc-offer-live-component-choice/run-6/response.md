I have updated `docs/intent/record-store/record-store-design.md` to complete the `record-store` LLD around whole-visit revisions (and updated `docs/high-level-design.md`'s architecture table from `Drafted; concurrency choice open` to `Drafted`, keeping ownership of the concurrency choice in `record-store`).

### Updated LLD (`docs/intent/record-store/record-store-design.md`)

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, revision lineage, and how independently edited copies of a visit become a current record. A visit is identified by a client-generated UUID (`visitId`) and references a catalog plot UUID (`plotId`). Updates can arrive days after their starting state was fetched during offline field work, and the server never treats arrival order as evidence that one worker's observations are more authoritative than another's.

A visit's scientific payload contains `plotId`, `observationDate`, `observers`, `speciesCover`, and `notes`. Edits across these fields can carry scientific relationships that field names alone do not reveal, such as revising a species identification alongside its cover estimate. Each submission is therefore stored, compared, and resolved as a complete whole-visit revision rather than merged field-by-field.

## Revision Model and States

Every accepted worker submission or coordinator resolution creates an immutable revision record containing `revisionId`, `visitId`, `origin` (`submission` | `resolution`), `actorId` (the submitting worker or resolving coordinator), server receipt timestamp (`receivedAt`), lineage reference (`baseRevisionId` when `origin = submission`; `contributingRevisionIds` when `origin = resolution`), and complete visit `payload`. Original worker payloads are never mutated or overwritten by later edits or resolutions, and mutations to a given `visitId` are serialized atomically.

Revisions of a single `visitId` form a directed acyclic graph:

- A worker submission (`origin = submission`) carries `baseRevisionId`: `null` when creating a new visit, or an existing `revisionId` of that visit when submitting an edit.
- A coordinator resolution (`origin = resolution`) carries `contributingRevisionIds`: the set of two or more competing `revisionId`s resolved together.

A revision is a **leaf** of its visit while no later revision of that visit references it in `baseRevisionId` or `contributingRevisionIds`. Ancestor relationships traverse both `baseRevisionId` and `contributingRevisionIds` edges. The count of leaf revisions defines the visit's state:

- `current` (one leaf revision): that leaf is the visit's authoritative `currentRevision`, and no unresolved review work exists.
- `unresolved` (two or more leaf revisions): all leaf revisions are competing candidates awaiting coordinator resolution, and the visit has no single authoritative `currentRevision`.

State transitions follow directly from leaf membership:

- **Initial creation**: An accepted submission with `baseRevisionId: null` for an unused `visitId` creates sole leaf `R1` (`status = current`, `currentRevision = R1`).
- **Linear edit**: While `status = current` with sole leaf `R1`, an accepted submission with `baseRevisionId = R1` creates `R2` and supersedes `R1` (`status = current`, `currentRevision = R2`).
- **Concurrent edit**: An accepted submission whose `baseRevisionId` names an already-superseded revision (for example, `R1` after `R2` has already advanced from `R1`) adds another leaf without superseding existing leaves (`status = unresolved`, leaves `{R2, R3}`).
- **Edit on an unresolved visit**: While `status = unresolved` (for example, leaves `{R2, R3}`), an accepted submission naming leaf `R2` as `baseRevisionId` advances that branch tip to `R4` (leaves `{R4, R3}`); a submission naming an earlier non-leaf revision adds a new leaf (leaves `{R2, R3, R5}`). The visit remains `unresolved` while multiple leaves exist.
- **Coordinator resolution**: An accepted resolution whose `contributingRevisionIds` matches all active leaves `{R2, R3}` creates resolution revision `R_res`, superseding every listed leaf and returning the visit to `status = current` (`currentRevision = R_res`).

## Operations and Contracts

| Operation | Caller | Request | Response / Outcome |
|---|---|---|---|
| Submit visit revision | Authenticated worker | `idempotencyKey`, `visitId`, `baseRevisionId`, `payload` | Assigned `revisionId`, `receivedAt`, resulting `status` (`current` \| `unresolved`), and competing leaf `revisionId`s when `unresolved` |
| Retrieve visit current state | Authenticated caller | `visitId` | `visitId`, `status`, `currentRevision` (when `current`), `unresolvedWork` (when `unresolved`) |
| List visits | Authenticated caller | Optional `status` filter (`current` \| `unresolved`), cursor / change token | Matching visits with their current-state representation (`visitId`, `status`, `currentRevision` or `unresolvedWork`) |
| Retrieve visit history | Authenticated caller | `visitId` | Complete immutable revision list for `visitId` |
| Resolve unresolved visit | Authenticated coordinator | `idempotencyKey`, `visitId`, `contributingRevisionIds`, `payload` | Assigned resolution `revisionId`, `receivedAt`, `status = current`, `currentRevision` |

### Submission Envelope and Validation

Before accepting a worker submission, the record store authenticates the caller (`actorId`), checks idempotency, validates visit field types (`observationDate`, `observers`, `speciesCover`, `notes`), verifies that `plotId` resolves to a known plot in `site-catalog` (including plots later archived in the catalog, so visits captured offline before archival remain submittable), and verifies that any non-null `baseRevisionId` belongs to `visitId`.

Idempotency is checked before state mutation so network retries cannot duplicate edits:

- Repeating an accepted `idempotencyKey` with an identical `visitId`, `baseRevisionId`, and `payload` returns the original acceptance response without creating another stored revision.
- Repeating an accepted `idempotencyKey` with any difference in `visitId`, `baseRevisionId`, or `payload` is rejected with an idempotency-conflict error, leaving stored revisions unchanged.

### Current-State and Unresolved-Work Representation

Current-state retrieval (single-visit and via `List visits`) distinguishes settled visits from visits awaiting coordinator review:

- When `status = unresolved`, `currentRevision` is `null` and `unresolvedWork` carries:
  - `competingRevisions`: every active leaf revision record of the visit.
  - `commonBaseRevision`: the lowest common ancestor revision record shared by all `competingRevisions` in the visit's revision graph, or `null` if no shared ancestor exists.
- When `status = current`, `currentRevision` carries the sole leaf revision record (`revisionId`, `visitId`, `origin`, lineage reference, `actorId`, `receivedAt`, `payload`) and `unresolvedWork` is `null`.

### Coordinator Resolution

A coordinator resolves an `unresolved` visit by supplying `idempotencyKey`, `visitId`, `contributingRevisionIds`, and the resolved whole-visit `payload` (either matching one of the competing revisions or composed by the coordinator after comparing them).

The server verifies coordinator authority (`actorId`), evaluates `idempotencyKey` first (returning the original resolution response on an identical retry and rejecting key reuse with different inputs), validates `payload` and `plotId`, and checks that `contributingRevisionIds` exactly matches the visit's current set of active leaf revisions. If another submission arrived and altered the leaf set while the coordinator was reviewing, the resolution is rejected with a stale-review conflict so the newly arrived revision cannot be marked resolved without inspection.

## Downstream Contract Obligations

- **tablet-sync**: Persist the `revisionId` a local draft started from and send it as `baseRevisionId` with a complete visit `payload` and per-edit `idempotencyKey`. Use `List visits` / current-state responses to refresh local state, and when a visit reports `status = unresolved`, display the pending competing state to field workers rather than presenting an unreviewed branch as settled.
- **review-export**: Query `List visits` (`status = unresolved`) to populate the coordinator review queue, present `competingRevisions` alongside `commonBaseRevision` for comparison, submit resolutions with the reviewed `contributingRevisionIds`, and export only `status = current` visits (holding all `status = unresolved` visits out of the partner CSV).

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with coordinator resolution of competing leaves | Field-aware three-way merge; arrival-order last-write-wins | Visit fields carry scientific relationships (such as species identification paired with cover estimate) that automated field merge rules cannot reliably detect. Whole-visit revisions preserve each worker's observation intact and avoid maintaining merge rules across scalar fields, observer lists, and species entries, trading a larger coordinator review queue when concurrent edits touch unrelated fields. Arrival-order overwrite silently discards offline edits. |
| Current-state value while unresolved | `status = unresolved` with `currentRevision = null` and explicit `unresolvedWork` | Keep earliest-arriving leaf as `currentRevision`; fall back to `commonBaseRevision` | Treating the earliest leaf as current makes arrival order authoritative; exposing `commonBaseRevision` as current presents superseded data. Returning `currentRevision = null` forces callers to handle unresolved visits explicitly and keeps unreviewed conflicts out of exports. |
| Resolution concurrency guard | Require `contributingRevisionIds` to match the visit's exact active leaf set | Resolve all current leaves on `visitId` regardless of which leaves the coordinator viewed | Prevents an offline submission that arrives mid-review from being absorbed into a resolution nobody inspected, preserving the HLD tenet not to silently discard submitted edits. |

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
```

---

### Decision Recording Option

Because whole-visit revisions vs. field-aware three-way merge trades credible options across multiple criteria (coordinator review volume vs. unexpressed scientific coupling and merge-rule maintenance) and both `tablet-sync` and `review-export` will be sized around this contract, would you like a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from `record-store`'s `Decisions & Alternatives` row), or keep just the `Decisions & Alternatives` table row above?

---

### Phase 2 LLD Edge-Case Probe (`record-store`)

Please let me know which of these gaps to settle in the LLD now versus defer under `Open Questions & Future Decisions`:

1. **`plotId` mutability across revisions**: What happens when an edit or coordinator resolution for an existing `visitId` changes `plotId` (for instance, correcting a mis-selected adjacent plot) — is `plotId` mutable across revisions of a visit, or fixed once the visit is created?
2. **Identical competing payloads**: What happens when two concurrent edits from the same `baseRevisionId` submit identical `payload` values — should `record-store` still mark the visit `unresolved` strictly by leaf count, or auto-collapse byte/semantically identical leaves without coordinator review?
3. **Duplicate initial creation (`baseRevisionId: null` on an existing `visitId`)**: What happens when a submission with a *different* `idempotencyKey` sends `baseRevisionId: null` for a `visitId` that already exists — reject it as a duplicate visit creation error, or accept it as a second root leaf (`status = unresolved`, `commonBaseRevision = null`)?
4. **Idempotency key scope, failed requests, and retry status**:
   - Should `idempotencyKey` uniqueness be scoped globally across `record-store` or per `actorId` / operation?
   - When a submission or resolution is *rejected* (validation error or `stale-review conflict`), does its `idempotencyKey` remain unrecorded so a corrected request may use a fresh or same key, or is it bound?
   - When an idempotent retry arrives after later submissions have changed the visit's `status`, should the response replay the original acceptance snapshot (`status` at receipt time) or return the original `revisionId`/`receivedAt` with the visit's current `status`?
5. **Scientific `payload` field invariants**: Beyond basic types and `plotId` existence, what structural bounds should `record-store` enforce (e.g., non-empty `observers`, empty `speciesCover` permitted for barren plots, numeric bounds on cover estimates, duplicate species entries within one submission)?
6. **Read/resolution error shapes and ordering**: What behavior should apply for unknown `visitId` on reads/resolutions (`not-found` error across all three vs. empty history), non-coordinator callers on `Resolve` (`forbidden`), and ordering of `Retrieve visit history`, `competingRevisions`, and `List visits` (e.g., causal/receipt order with `revisionId` tie-breaking)?

*(Cross-segment note: `docs/intent/site-catalog/site-catalog-design.md` still has one sentence noting that `tablet-sync` remains pending the `record-store` concurrency choice. Left untouched across the `CAT` segment boundary — let me know if you want that line cleaned up too.)*

Once you review the LLD, decide on the decision doc vs. table row, and triage items 1–6, I will incorporate your feedback and proceed to **Phase 3** (`docs/intent/record-store/record-store-specs.md`).