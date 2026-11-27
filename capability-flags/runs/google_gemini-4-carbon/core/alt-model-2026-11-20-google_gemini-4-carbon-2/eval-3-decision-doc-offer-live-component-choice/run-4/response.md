I have updated `docs/intent/record-store/record-store-design.md` around whole-visit revisions (Phase 2 — LLD). Below is the updated LLD in full, followed by the decision-recording option, the Phase 2 edge-case probe for triage, and two cross-doc notes before we move to Phase 3 (`record-store-specs.md`).

---

### Updated `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, revision lineage, and the definition of a visit's current state when field workers edit the same visit independently while offline. A visit is identified by a client-generated UUID (`visitId`) and references a permanent plot in `site-catalog` by plot UUID (`plotId`). Because shared tablets can remain disconnected for up to 48 hours, edits can arrive days after their starting state was fetched; server receipt order does not indicate which worker's observation is more accurate.

Visit observations contain scientific couplings across fields—such as revising a species identification alongside its cover estimate—that cannot be inferred reliably from field names. The store therefore versions and reconciles visits as whole-visit revisions rather than merging individual fields automatically.

## Revision Model

Every accepted worker submission or coordinator resolution produces an immutable revision (`revisionId`) attached to a `visitId` and holding a complete visit payload:

- `plotId`: catalog plot UUID
- `observationDate`: calendar date of the plot survey
- `observers`: list of observer names
- `speciesCover`: species cover entries for the visit
- `notes`: freeform field notes

Each revision records its origin and parent lineage:

- **Worker-submitted revision**: records `submissionId`, `authorId`, `receivedAt`, and `baseRevisionId` (`null` when creating the visit's initial revision, or the starting `revisionId` when editing an existing visit).
- **Coordinator-resolved revision**: records `resolutionId`, `coordinatorId`, `resolvedAt`, `resolvedRevisionIds` (the two or more competing `revisionId`s reviewed and superseded), `contributingSubmissionIds`, and optional `resolutionNote`.

Revisions form a directed acyclic lineage per visit. A revision is an **active head** while no later revision on that visit references it as `baseRevisionId` or includes it in `resolvedRevisionIds`. Visit state derives from active heads:

- **Resolved** (`activeHeads` count = 1): the single active head is the authoritative `currentRevision`. Sequential edits against the sole active head advance `currentRevision` without creating review work.
- **Unresolved** (`activeHeads` count ≥ 2): concurrent edits from the same `baseRevisionId` (or edits arriving against an already-superseded revision) leave multiple active heads as competing whole-visit revisions awaiting coordinator resolution.

Original worker submissions and coordinator resolution records are append-only and never overwritten or deleted when superseded.

## Submission Envelope

Authenticated workers submit visits through an idempotent envelope:

| Field | Type | Description |
|---|---|---|
| `idempotencyKey` | string | Client-generated retry key for the submission |
| `visitId` | UUID | Client-generated visit identifier |
| `baseRevisionId` | UUID or null | Starting `revisionId`, or `null` when creating a new visit |
| `payload` | VisitPayload | Complete visit fields (`plotId`, `observationDate`, `observers`, `speciesCover`, `notes`) |

Before accepting a submission, the store authenticates the worker (`authorId`), validates field types, verifies that `plotId` resolves in `site-catalog`, and verifies `baseRevisionId` against the visit's stored revisions.

On acceptance, the store persists the original submission (`submissionId`, `visitId`, `authorId`, `receivedAt`, `baseRevisionId`, `idempotencyKey`, `payload`), creates its `revisionId`, and returns an acceptance response containing `submissionId`, `revisionId`, `receivedAt`, the resulting visit `status` (`resolved` or `unresolved`), and active head revision IDs.

Repeating an accepted `idempotencyKey` with an identical envelope returns the original acceptance response without creating another submission or revision. Reusing an accepted `idempotencyKey` with a different envelope is rejected while leaving the original submission unchanged.

## Retrieval and Unresolved-Work Representation

The store exposes three read views:

1. **Current-state retrieval** (by `visitId` or collection query): returns `visitId`, `status` (`resolved` or `unresolved`), `currentRevision`, and `competingRevisions`.
   - When `status` is `resolved`, `currentRevision` holds the sole active head revision (including its `revisionId`, origin metadata, and `payload`) and `competingRevisions` is empty.
   - When `status` is `unresolved`, `currentRevision` is `null` and `competingRevisions` contains every active head revision in full (`revisionId`, origin metadata, parent revision reference(s), and `payload`). Withholding `currentRevision` ensures callers cannot mistake arrival order for authority or export an unreviewed visit.
2. **Unresolved-work query**: lists all visits currently in `unresolved` status alongside their `competingRevisions` and ancestor revision snapshots needed for side-by-side comparison.
3. **Visit history retrieval**: returns all immutable worker submissions and coordinator resolutions for a `visitId`, preserving the complete audit path from submitted observations to any current or exported state.

## Resolution Operation

Authenticated coordinators resolve competing revisions by submitting:

| Field | Type | Description |
|---|---|---|
| `idempotencyKey` | string | Client-generated retry key for the resolution |
| `visitId` | UUID | Visit being resolved |
| `resolvedRevisionIds` | UUID[] | Distinct active head `revisionId`s reviewed and superseded by this resolution (at least two) |
| `payload` | VisitPayload | Complete resolved visit payload (selected from a competing revision or reconciled manually by the coordinator) |
| `resolutionNote` | string or null | Optional coordinator rationale |

The store authenticates `coordinatorId`, validates `payload` and `plotId`, verifies `resolvedRevisionIds` against the visit's current active heads, persists the resolution outcome (`resolutionId`, `revisionId`, `coordinatorId`, `resolvedAt`, `resolvedRevisionIds`, `contributingSubmissionIds`, `payload`, `resolutionNote`), and returns the resulting revision and visit state. Repeating an accepted resolution `idempotencyKey` with an identical request returns the original resolution outcome; reusing it with a different request is rejected.

## Downstream Contract

Sibling nodes consume this contract as follows:

- **tablet-sync**: tracks the `revisionId` a local draft is based on as `baseRevisionId` (`null` for new visits), submits complete visit payloads with `idempotencyKey`, updates local tracking from the returned `revisionId`, and surfaces `unresolved` status and competing revisions to field workers.
- **review-export**: renders `competingRevisions` (and their ancestor revision snapshots) for coordinator comparison, writes coordinator decisions through the resolution operation, and exports `currentRevision` for `resolved` visits only—holding `unresolved` visits out of the partner CSV.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with coordinator resolution of competing heads | Field-aware three-way merge (auto-combining disjoint scalar, observer-list, and species edits; reviewing only overlapping fields) | Field changes can be scientifically coupled across fields (such as a revised species identification and its cover estimate) in ways field structure does not expose. Keeping each submission intact avoids silent cross-field combinations and avoids maintaining per-field merge rules, trading a larger coordinator review queue for scientific fidelity and operational simplicity. |
| Unresolved visit current-state shape | `currentRevision: null` with full `competingRevisions` list while multiple active heads exist | Expose first-arriving or latest-arriving head as tentative `currentRevision` with a conflict flag | Tablets remain offline for up to 48 hours, so server receipt order carries no scientific authority; omitting `currentRevision` prevents callers from treating arrival order as authoritative or exporting unresolved visits by mistake. |
```

---

### 1. Decision Doc vs. Table Row

Because whole-visit revisions vs. field-aware three-way merge trades credible options across multiple criteria (scientific field coupling and merge-rule maintenance vs. review queue volume and payload size) and both `tablet-sync` and `review-export` will be sized around this contract, would you like me to record this choice as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from `record-store-design.md`), or keep just the `Decisions & Alternatives` table row above?

---

### 2. Phase 2 LLD Edge-Case Probe (Triage: Fix in LLD Now vs. Defer)

Please let me know which of these internal `record-store` gaps you want settled in the LLD now versus deferred to `Open Questions & Future Decisions`:

1. **Late submission arriving during coordinator review**: What happens when a coordinator submits `resolvedRevisionIds: [R2, R3]`, but a third offline edit `R4` arrived in the meantime so the active heads are now `[R2, R3, R4]`—should the store reject the resolution as stale (requiring the coordinator to review all three together), or accept the resolution to supersede `[R2, R3]` and leave `[R_res, R4]` as competing heads?
2. **`contributingSubmissionIds` across multi-step branches or prior resolutions**: What happens when a resolved branch contains sequential offline edits (`S1 -> S2`) or a prior coordinator resolution—does `contributingSubmissionIds` record all worker `submissionId`s along the diverged branches since their common ancestor, only the immediate superseded heads' `submissionId`s, or the transitive union across prior resolutions?
3. **Ancestor snapshots in the unresolved-work query**: What happens when competing heads do not share the same immediate `baseRevisionId` (for example, `R1 -> R2 -> R3` competing with `R1 -> R4`)—should the unresolved-work query include the lowest common ancestor (`R1`), each head's direct parent, or both?
4. **Duplicate initial creation (`baseRevisionId: null` on an existing `visitId`) and invalid `baseRevisionId`**: What happens when a submission with a new `idempotencyKey` arrives with `baseRevisionId: null` for an already-existing `visitId`—reject it, or treat it as a competing rootless head? (And confirm that a non-null `baseRevisionId` missing from that `visitId` is rejected.)
5. **`plotId` mutability and archived plots on submission**: What happens when a worker edit or coordinator resolution changes `plotId` relative to its parent revision on the same `visitId` (is `plotId` editable to fix a misselected plot in the field, or immutable per `visitId`)? And should submissions referencing an archived `plotId` be accepted (for surveys captured offline before archival) or flagged/restricted?
6. **Idempotency replay freshness and scoping**: What happens when an accepted submission's `idempotencyKey` is replayed *after* a later edit or resolution has changed the visit's `status`—should it return the frozen acceptance snapshot recorded at initial receipt or the visit's current `status`? Also, is `idempotencyKey` scoped globally per operation or per `(authorId, operation)`?
7. **Domain validation & rejection error shapes**: Beyond basic types and `plotId` lookup, should `record-store` enforce payload invariants (non-empty `observers`, valid cover ranges, unique species entries per visit, date bounds) and return structured rejection codes distinguishing validation errors, idempotency conflicts, and stale-head conflicts?

---

### 3. Cross-Node References Outside `record-store`

Two upstream/sibling docs still describe the `record-store` concurrency choice as open:
- `docs/high-level-design.md` (`Drafted; concurrency choice open` in the Architecture table, and `depend on that node's unresolved choice`)
- `docs/intent/site-catalog/site-catalog-design.md` (`remains pending that choice`)

Should I update those two notes as well once you approve this LLD, before we proceed to Phase 3 (`docs/intent/record-store/record-store-specs.md`)?