`docs/intent/record-store/record-store-design.md` has been updated for **Phase 2 (LLD)** around whole-visit revisions:

---

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, whole-visit revision lineage, and the rules that determine when a visit has a settled current record versus unresolved review work. A visit is identified by a client-generated UUID (`visitId`) and refers to a plot UUID (`plotId`) from `site-catalog`. Tablets can remain offline for 48 hours or more, so edits can arrive days after their starting state was fetched. Arrival order reflects connectivity rather than observational authority; the server never discards or overwrites an accepted submission based on when it arrived.

A visit's scientific fields — observation date, observer list, species cover estimates, and notes — can carry domain relationships that field names do not reveal, such as revising a species identification alongside its cover estimate. Treating each submitted visit as an indivisible whole-visit revision preserves each worker's observation intact and routes any concurrent edits to coordinator review.

## Revision and State Model

Persistence separates raw audit records from the revision graph they advance:

- **Submission**: an immutable record created when a worker's visit edit is accepted (`submissionId`, `visitId`, `authorId`, `receivedAt`, `idempotencyKey`, `baseRevisionId`, and original `payload`). Accepted submissions are retained permanently and are never mutated by later submissions or coordinator resolutions.
- **Resolution**: an immutable record created when a coordinator resolves competing revisions (`resolutionId`, `visitId`, `coordinatorId`, `resolvedAt`, `resolvedRevisionIds`, `contributingSubmissionIds`, `resolutionNote`, and resulting whole-visit `payload`).
- **Revision**: an immutable whole-visit snapshot (`revisionId`, `visitId`, `parentRevisionIds`, `createdAt`, `origin` referencing either a `submissionId` or a `resolutionId`, and `payload`).

### Lineage Transitions

- **Initial creation**: when a visit has no existing revisions and a valid submission arrives with `baseRevisionId: null`, the store records the submission and creates initial revision `R1` (`parentRevisionIds: []`). `R1` becomes the sole active tip revision.
- **Linear update**: when a visit is `clean` and a valid submission names the sole active tip revision as its `baseRevisionId`, the store records the submission and creates a child revision (`parentRevisionIds: [baseRevisionId]`) that replaces its parent as the sole active tip.
- **Competing update**: when a valid submission names a `baseRevisionId` that has already been superseded by another revision, arrives with `baseRevisionId: null` after revisions already exist for `visitId`, or arrives while the visit is already `unresolved`, the store records the submission and creates a new revision linked to its declared `baseRevisionId` (`[]` if `null`) without replacing existing unmerged tips.
- **Coordinator resolution**: when a coordinator resolves all active competing tip revisions of an `unresolved` visit, the store records the resolution and creates a single revision whose `parentRevisionIds` list `resolvedRevisionIds`, collapsing those tips into one active tip.

### Visit Review States

- `clean` — Exactly one active tip revision exists (`currentRevision`). No unresolved review work exists; the visit is eligible for CSV export.
- `unresolved` — Two or more unmerged tip revisions exist. No competing tip is treated as authoritative (`currentRevision` is `null`); the visit requires coordinator review and is excluded from CSV export.

## Operations and Contracts

### Visit Payload

| Field | Type | Description |
|---|---|---|
| `plotId` | UUID | Plot identifier in `site-catalog` |
| `observationDate` | ISO-8601 date | Calendar date of the field survey |
| `observers` | `list<string>` | Non-empty list of observer names |
| `speciesCover` | `list<SpeciesCoverEntry>` | Species identifiers/names paired with cover estimates |
| `notes` | `string` or `null` | Optional field notes |

### Submission Envelope and Acceptance

Authenticated workers submit visit creations and edits using the following envelope:

| Field | Type | Description |
|---|---|---|
| `idempotencyKey` | string | Client-generated key unique to the submission attempt |
| `visitId` | UUID | Client-generated visit identifier |
| `baseRevisionId` | UUID or `null` | Revision ID the tablet started from, or `null` for initial visit creation |
| `payload` | VisitPayload | Complete whole-visit observation record |

Before accepting a submission, the store authenticates the worker (`authorId`) and evaluates idempotency:

- Repeating an accepted `idempotencyKey` with an identical envelope (`visitId`, `baseRevisionId`, `payload`) returns the original acceptance response without creating another submission or revision.
- Repeating an accepted `idempotencyKey` with a different envelope is rejected without altering existing records.

For new keys, the store validates field types, verifies `plotId` exists in `site-catalog`, and — when `baseRevisionId` is non-null — verifies `baseRevisionId` belongs to `visitId`. Invalid requests are rejected without recording a submission.

Accepted submissions return `submissionId`, `visitId`, `revisionId`, `receivedAt`, `reviewState` (`clean` or `unresolved`), `currentRevisionId` (populated when `clean`, `null` when `unresolved`), and `competingRevisionIds` (empty when `clean`, active tip revision IDs when `unresolved`).

### Current-State Retrieval

Retrieving a visit by `visitId` distinguishes settled data from pending review work:

| Field | Type | Description |
|---|---|---|
| `visitId` | UUID | Visit identifier |
| `reviewState` | `clean` or `unresolved` | Whether the visit has a single current record or pending competing revisions |
| `currentRevision` | `Revision` or `null` | Sole active tip revision when `clean`; `null` when `unresolved` |
| `unresolvedWork` | `UnresolvedWork` or `null` | Competing revision bundle when `unresolved`; `null` when `clean` |

### Unresolved-Work Representation

Returned within current-state retrieval for `unresolved` visits and by the unresolved-visits queue query:

| Field | Type | Description |
|---|---|---|
| `visitId` | UUID | Visit identifier |
| `baseRevision` | `Revision` or `null` | Most recent common ancestor shared by all active tip revisions, or `null` if none exists |
| `competingRevisions` | `list<Revision>` | All active unmerged tip revisions, each with `revisionId`, `parentRevisionIds`, `origin` metadata, `createdAt`, and full `payload` |
| `contributingSubmissionIds` | `list<UUID>` | Worker submission IDs along the competing branches after `baseRevision` (or all branch submissions when `baseRevision` is `null`) |

### Coordinator Resolution Operation

Authenticated coordinators resolve an `unresolved` visit with:

| Field | Type | Description |
|---|---|---|
| `visitId` | UUID | Visit being resolved |
| `resolvedRevisionIds` | `list<UUID>` | Exact set of active tip revision IDs reviewed by the coordinator |
| `payload` | VisitPayload | Resulting whole-visit record (matching one competing revision or reconciled across them) |
| `resolutionNote` | `string` or `null` | Optional coordinator rationale |

The store verifies the caller holds coordinator authority, validates `payload` and `plotId`, confirms the visit is `unresolved`, and checks that `resolvedRevisionIds` matches the visit's complete set of active tip revisions. If another submission arrived after the coordinator loaded the review item, the store rejects the stale resolution with a conflict response containing the updated `UnresolvedWork`. Otherwise, it records the resolution (linking `coordinatorId`, `resolvedRevisionIds`, and `contributingSubmissionIds`), creates the new head revision, sets `currentRevision`, and transitions `reviewState` to `clean`.

### Submission-History Retrieval

Retrieving history for `visitId` returns all accepted worker submissions, all coordinator resolutions, and the revision graph connecting them in lineage order so coordinators and auditors can trace any current or exported value back to the original observations.

## Downstream Contract Obligations

- **`tablet-sync`**: retain the latest known `revisionId` as `baseRevisionId` for local edits; submit whole-visit payloads with per-attempt `idempotencyKey` values; when submission acceptance or visit retrieval reports `reviewState: unresolved`, preserve visibility into competing revisions and avoid silently overwriting local state.
- **`review-export`**: query `unresolved` visits and present a whole-visit comparison view built from `baseRevision` and `competingRevisions`; submit resolutions naming the reviewed `resolvedRevisionIds` and handle conflict responses when new submissions arrive mid-review; export `currentRevision.payload` only for `clean` visits and hold `unresolved` visits out of the partner CSV.

Both downstream nodes must link to `record-store` rather than defining separate concurrency or merge rules.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions | Field-aware three-way merge | Edits within a visit can be scientifically coupled (such as revising a species identification alongside its cover estimate) in ways field names do not reveal. Whole-visit revisions preserve each worker's observation as a unit and avoid maintaining per-field merge rules that could silently combine incompatible edits, trading a larger coordinator review queue when concurrent edits touch unrelated fields. |
| Current state of an unresolved visit | Set `currentRevision` to `null` while competing tips exist; expose `unresolvedWork` separately | Keep earliest-arriving or latest-arriving tip as `currentRevision` until resolved | Arrival order reflects tablet connectivity rather than observational authority; withholding a single `currentRevision` prevents callers and exports from treating an unreviewed competing submission as settled data. |
| Mid-review arrival of another submission | Require `resolvedRevisionIds` to match all active tips; reject stale resolution on mismatch | Apply coordinator resolution across the visit regardless of newly arrived tips | Rejecting a stale resolution guarantees a late-arriving offline submission is reviewed before being superseded, upholding the tenet never to silently discard a submitted edit. |

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
- `docs/intent/record-store/record-store-specs.md`
```

---

### Decision Doc Option

Because whole-visit revisions vs. field-aware three-way merge trades credible options across multiple criteria (coordinator review queue size and submission payload size vs. merge-rule maintenance and preserving scientifically coupled edits) and sizes both `tablet-sync` and `review-export` around the outcome, would you like to record this in a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the `Decisions & Alternatives` row), or keep the `Decisions & Alternatives` row in `record-store-design.md` on its own?

### Phase 2 LLD Edge-Case Probe (for triage: fix in LLD vs. defer to Open Questions)

A blind probe against `record-store-design.md` surfaced these internal gaps and multi-reading points:

1. **Editing an unmerged tip while `unresolved`**: When a visit has active tips `[R2, R3]` and a valid submission arrives with `baseRevisionId: R2` (creating `R4`), should `R4` advance that branch's tip so active tips become `[R4, R3]` (with `R2` retained in submission/revision history), or should `[R2, R3, R4]` all remain in `competingRevisions` until coordinator resolution?
2. **Identical concurrent payloads**: When two submissions from the same `baseRevisionId` (with distinct `idempotencyKey`s) carry identical `VisitPayload` values, does the visit still enter `unresolved` with two competing revisions, or avoid creating review work?
3. **`plotId` mutability across a visit's revisions**: Can a subsequent submission or coordinator resolution change `payload.plotId` for an existing `visitId` (e.g., fixing a misselected plot code), or is `plotId` immutable once `visitId` is created?
4. **Idempotent replay after visit state changes & key scope**: If a tablet retries an accepted `idempotencyKey` after another edit or resolution has changed the visit's `reviewState`, should the response replay the stored point-in-time acceptance snapshot or return the original `submissionId`/`revisionId` with the visit's current `reviewState`? Also, is `idempotencyKey` scoped per `authorId`, per `visitId`, or globally?
5. **Coordinator resolution retries and two-coordinator race**: Should Coordinator Resolution also accept an `idempotencyKey`, define an explicit success response (`resolutionId`, new `revisionId`, `resolvedAt`), and return a conflict error when the visit has already been resolved (`clean`) by the other coordinator?
6. **Late edit predating an earlier resolution**: When a coordinator resolves `[R2, R3]` into `M1` and a late offline edit `R4` later arrives based on pre-resolution `R1` or `R2` (making active tips `[M1, R4]`), should `baseRevision` be defined strictly as the topological lowest common ancestor in the revision DAG, and should `contributingSubmissionIds` include only submissions not yet folded into `M1` or all worker submissions reachable since `baseRevision`?
7. **Payload validation bounds, ordering, and error shapes**: Which field-level invariants belong in `record-store` now (e.g., `SpeciesCoverEntry` structure and cover range, whether empty `speciesCover` is valid on bare plots, duplicate species/observer entries, `Revision.origin` inline attribution fields, chronological vs. topological history ordering, and error shapes for unknown `visitId` / invalid `baseRevisionId`) vs. deferred?

### Cross-Boundary Notes

- `docs/high-level-design.md` (lines 18 and 22) and `docs/intent/site-catalog/site-catalog-design.md` (line 24) still describe `record-store`'s concurrency choice as open/pending. Let me know if you want those updated alongside this LLD before we proceed to **Phase 3 (`record-store-specs.md`)**.

How would you like to rule on the LLD, the decision-doc option, and items 1–7?