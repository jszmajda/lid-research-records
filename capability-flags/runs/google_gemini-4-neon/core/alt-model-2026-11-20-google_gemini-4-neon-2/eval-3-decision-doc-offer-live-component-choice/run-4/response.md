I have updated `docs/intent/record-store/record-store-design.md` around whole-visit revisions (Phase 2).

### Coherence pre-flight notes
- `docs/high-level-design.md` still marks `record-store` as `Drafted; concurrency choice open` and refers to its "unresolved choice." Once this LLD is approved, I can update that status wording.
- `docs/intent/record-store/record-store-specs.md` (`REC-001`–`REC-006`) predates this selection and will be updated in Phase 3 after you approve the LLD.
- `tablet-sync` and `review-export` are untouched and remain deferred until after `record-store`.

---

### Updated LLD: `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, revision lineage, and the definition of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot UUID. Updates can arrive days after their starting state was fetched, and arrival order is never treated as evidence that one worker's observations are more authoritative.

Concurrent edits are handled via **whole-visit revisions**. Every accepted submission is preserved intact as an immutable revision; edits that diverge from the current revision produce competing revisions for a coordinator to resolve before export.

## Data Model and Revision Graph

Each visit is an append-only directed acyclic graph (DAG) of immutable revisions:

- **Visit**: Identified by a client-generated `visitId` (UUID). Tracks:
  - `currentRevisionId`: the latest uncontested or coordinator-resolved revision (`null` only if competing initial creations exist with no prior accepted revision).
  - `reviewStatus`: `clean` or `needs_review`.
- **Revision**: Immutable record for every accepted worker submission or coordinator resolution:
  - `revisionId`: server-generated UUID.
  - `visitId`: UUID of the owning visit.
  - `parentRevisionIds`: empty (`[]`) for an initial visit submission; `[baseRevisionId]` for a worker edit; the set of competing `revisionId`s for a coordinator resolution.
  - `kind`: `submission` (field worker) or `resolution` (coordinator).
  - `authorId`: authenticated worker or coordinator identity.
  - `receivedAt`: server receipt timestamp.
  - `idempotencyKey`: client-supplied key for deduplicating retries.
  - `payload`: complete visit fields — `plotId` (catalog UUID), `observationDate`, `observers` (list), `speciesCover` (list of species cover estimates), and `notes`.
  - `resolutionNote`: optional coordinator rationale (present only on `resolution` revisions).

An **active head** is a revision of a visit that is not referenced in any other revision's `parentRevisionIds`. A visit is `clean` when it has exactly one active head (which equals `currentRevisionId`), and `needs_review` when it has two or more active heads.

## Submission Envelope and Acceptance

Authenticated workers submit a complete visit envelope:

| Field | Type | Notes |
|---|---|---|
| `visitId` | UUID | Client-generated visit identifier |
| `idempotencyKey` | UUID | Client-generated retry key |
| `baseRevisionId` | UUID or null | Starting revision the worker edited from (`null` for a new visit) |
| `payload` | VisitPayload | Complete visit fields (`plotId`, `observationDate`, `observers`, `speciesCover`, `notes`) |

Before accepting a submission, the record store:

1. Authenticates the submitting worker.
2. Validates field types, required structure, and that `plotId` exists in `site-catalog`.
3. Checks `idempotencyKey`: a retry repeating an accepted key with an identical payload returns the original acceptance result without creating a new revision; reuse of an accepted key with a different payload is rejected, leaving the original revision unchanged.
4. Validates `baseRevisionId`: if non-null, it must reference an existing revision of the same `visitId`.

State transitions on acceptance:

- **New visit** (`baseRevisionId` is `null` and `visitId` is unknown): creates the visit and its first `submission` revision (`parentRevisionIds = []`), sets `currentRevisionId` to the new `revisionId`, and sets `reviewStatus = clean`.
- **Linear update** (`reviewStatus == clean` and `baseRevisionId == currentRevisionId`): appends a `submission` revision with `parentRevisionIds = [baseRevisionId]`, advances `currentRevisionId` to the new `revisionId`, and keeps `reviewStatus = clean`.
- **Competing edit** (`baseRevisionId != currentRevisionId`, `reviewStatus == needs_review`, or `baseRevisionId == null` on an existing `visitId`): appends a `submission` revision with `parentRevisionIds = [baseRevisionId]` (or `[]` if `null`), leaves `currentRevisionId` unchanged, and sets `reviewStatus = needs_review`.

The acceptance response returns the created `revisionId`, the visit's resulting `reviewStatus`, and `currentRevisionId`.

## Retrieval Operations

- **Current-state retrieval** (by `visitId` or filtered list): returns `visitId`, `reviewStatus`, `exportEligible` (`true` only when `reviewStatus == clean`), `currentRevision` (full revision at `currentRevisionId`, or `null`), and `competingRevisionIds` (empty when `clean`; all active head IDs when `needs_review`).
- **Submission-history retrieval** (by `visitId`): returns all revisions for the visit with `revisionId`, `parentRevisionIds`, `kind`, `authorId`, `receivedAt`, `resolutionNote`, and the preserved original `payload`, making the path from every submitted observation to any exported value inspectable.
- **Unresolved-work retrieval** (review queue): returns visits in `needs_review` state along with their competing active head revisions and each head's parent/base revision(s) so coordinators can compare whole visits side by side.

## Review Resolution

An authenticated coordinator resolves a `needs_review` visit by submitting:

| Field | Type | Notes |
|---|---|---|
| `visitId` | UUID | Visit being resolved |
| `resolvedRevisionIds` | UUID[] | Exact set of competing active head IDs reviewed by the coordinator |
| `payload` | VisitPayload | Resolved complete visit (either copied from a chosen revision or synthesized from the competing revisions) |
| `resolutionNote` | string or null | Optional explanation of the resolution |

If `resolvedRevisionIds` matches the visit's current active heads, the record store appends a `resolution` revision with `parentRevisionIds = resolvedRevisionIds`, `authorId = coordinatorId`, `receivedAt`, and the resolved `payload`; sets `currentRevisionId` to the new revision; and transitions `reviewStatus` to `clean`. All original worker submissions remain immutable in history.

If `resolvedRevisionIds` does not match the current active heads (for example, another competing submission arrived while the coordinator was reviewing), the resolution is rejected so the unreviewed submission is not silently superseded.

## Downstream Contracts

Sibling nodes build on this contract rather than defining their own concurrency semantics:

- **tablet-sync**: retains `baseRevisionId` per local visit, submits whole-visit payloads with an `idempotencyKey`, and surfaces `needs_review` outcomes to field workers without blocking offline capture.
- **review-export**: reads unresolved work to present whole-visit revision comparisons, submits coordinator resolutions with `resolvedRevisionIds`, and excludes visits with `reviewStatus == needs_review` from the Friday CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions with competing heads sent to coordinator review | Field-aware three-way merge | Preserves each worker's submitted visit as a scientifically coherent unit and avoids maintaining merge rules that can silently combine related fields (such as a species identification and its cover estimate). Accepts a larger coordinator review queue in exchange for simpler, inspectable lineage that two coordinators can operate without a dedicated systems administrator. |
| Resolution representation | Append a new `resolution` revision referencing all resolved head IDs | Mutate or promote a winning revision in place | Keeps original worker submissions immutable, records coordinator identity and contributing revisions uniformly in the revision graph, and handles both selecting one revision and synthesizing a combined visit through a single mechanism. |
| Concurrent arrivals during review | Reject resolution unless `resolvedRevisionIds` matches current active heads | Resolve whatever heads exist at write time | Prevents a coordinator from silently superseding a competing submission that arrived while they were comparing earlier revisions. |

## Open Questions & Future Decisions

*(None deferred yet.)*
```

---

### LLD-level edge-case probe (for triage: fix in LLD vs. defer)

A delegated probe surfaced these internal gaps in `record-store-design.md`:

1. **`currentRevisionId = null` contradiction:** The data model says `currentRevisionId` is `null` if competing initial creations exist with no prior accepted revision, but the transition rules set `currentRevisionId` on the first arrival and leave it unchanged on a subsequent `baseRevisionId == null` submission—making `null` unreachable. Should `currentRevisionId` simply always point to the last uncontested/resolved revision (never `null` once a visit exists), or clear to `null` on a duplicate initial creation?
2. **Chaining on competing heads & identical-payload forks:** What happens when a worker submits an edit whose `baseRevisionId` is one of the competing active heads while the visit is `needs_review`, or submits a competing edit (new `idempotencyKey`) whose `payload` is identical to `currentRevision`?
3. **Idempotency key scoping, equality, and post-change retries:** Is `idempotencyKey` scoped globally, per `visitId`, or per `(visitId, authorId)`? What counts as an "identical payload" (e.g., list ordering in `observers`/`speciesCover`, `null` vs. empty `notes`)? And if a retry arrives *after* later edits or a resolution, does it return the original historical `reviewStatus`/`currentRevisionId` or the visit's current state?
4. **Resolution idempotency and `clean`-visit resolution:** Should coordinator resolution also accept an `idempotencyKey` (so a timed-out resolution retry doesn't fail the active-heads check), and what happens if a resolution targets a `clean` visit or passes duplicate/reordered IDs in `resolvedRevisionIds`?
5. **Role and authorization boundaries:** Are submission, review-queue retrieval, and resolution strictly role-gated (worker vs. coordinator), and can coordinators also submit field-worker revisions?
6. **Archived plots, cross-revision `plotId` changes, and payload bounds:** How should submissions/resolutions referencing an `archived` plot UUID from `site-catalog` be handled (e.g., offline visits collected before archival), may a later revision change `plotId` from its parent's plot, and what structural bounds apply to `observers`, `speciesCover`, and `observationDate`?
7. **Concurrent writes to the same `visitId`:** What per-visit serialization or transactional isolation invariant prevents lost forks or stale resolutions when two submissions (or a submission and a resolution) execute simultaneously?
8. **Error shapes and retrieval ordering:** What distinct error codes/payloads apply to each rejection (especially whether a stale-resolution rejection returns the current active heads), what order is used for submission-history retrieval, and what parent/base context is returned when a competing head has `parentRevisionIds = []` or is multiple hops beyond `currentRevisionId`?

---

### Decision doc offer

Because **whole-visit revisions vs. field-aware three-way merge** trades two credible options across multiple criteria (review workload and export readiness vs. merge-rule maintenance and preserving whole-visit scientific intent), could easily be re-litigated by a future cold reader, and sizes two downstream nodes (`tablet-sync` and `review-export`), I can record it as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and link it from the `Decisions & Alternatives` table—or keep just the `Decisions & Alternatives` row in `record-store-design.md`.

---

**Phase 2 stop — please reply with:**
1. Any feedback or edits to `record-store-design.md`.
2. Which of the 8 probe items to resolve in the LLD now vs. defer to `Open Questions & Future Decisions`.
3. Whether you want a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` or just the `Decisions & Alternatives` table row.
4. Approval (once ready) to update the HLD's open-status note and move to Phase 3 (`record-store-specs.md`).