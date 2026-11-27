I have updated `docs/intent/record-store/record-store-design.md` for the whole-visit revisions policy (and updated the status line in `docs/high-level-design.md` and `docs/intent/site-catalog/site-catalog-design.md` so no doc still marks the concurrency choice as open).

Before we advance to Phase 3 (`record-store-specs.md`), please review the updated LLD, decide whether you want a standalone decision doc for the concurrency choice, and triage the LLD edge-case probe items below.

---

### 1. Decision Doc Offer

Because the whole-visit revisions vs. field-aware three-way merge choice trades competing criteria (preserving cross-field scientific coherence and low coordinator tooling burden vs. review queue volume) and sizes `tablet-sync` and `review-export` around its contract, it clears the bar for a standalone decision doc.

Would you like to record it as a full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD's `Decisions & Alternatives` table), or keep it solely as the row in the LLD's `Decisions & Alternatives` table?

---

### 2. Updated `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot UUID. Updates can arrive days after their starting state was fetched, and the server does not treat arrival order as evidence that one worker's observations are more authoritative.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are related, such as revising a species identification and its cover estimate. Because the server cannot infer scientific relationships across fields from field names alone, the record store tracks whole-visit revisions rather than merging fields automatically. Every submitted revision is preserved intact as an immutable unit, and competing revisions derived from the same base revision are held for coordinator review.

## Revision Model and State Transitions

Each accepted submission creates an immutable revision with a server-assigned `revisionId`, the submitting worker's `authorId`, `receivedAt` timestamp, `baseRevisionId` (`null` for initial creation), and the complete visit payload.

A visit is in one of two states based on its active head revisions (accepted revisions that are not the `baseRevisionId` of any later revision and have not been superseded by a coordinator resolution):

- **`resolved`**: The visit has a single active head revision. That revision is the authoritative current revision and is eligible for Friday CSV export.
- **`needs_review`**: The visit has two or more competing active head revisions. No single revision is authoritative until a coordinator resolves the conflict, and the visit is held out of export.

State transitions:

1. **Initial submission (`baseRevisionId: null`)**: Creates the first revision `R1`. The visit state is `resolved` with current revision `R1`. If a second submission for the same `visitId` arrives with `baseRevisionId: null` (for example, two tablets independently creating a record for the same client-generated `visitId`), both revisions become competing heads and the visit transitions to `needs_review`.
2. **Linear update**: When the visit is `resolved` at head `R1` and a submission arrives with `baseRevisionId: R1`, the new revision `R2` supersedes `R1` as the sole active head. The visit remains `resolved` with current revision `R2`.
3. **Concurrent update (branching)**: When `R1` has already been superseded by `R2` (or by a resolution chain descending from `R1`) and another submission arrives with `baseRevisionId: R1`, the new revision `R3` is accepted as an additional active head alongside the existing head(s). The visit transitions to (or remains in) `needs_review`.
4. **Submission while `needs_review`**: If a worker submits an edit whose `baseRevisionId` is one of the competing heads `R2`, the new revision `R4` replaces `R2` among the active heads while other competing heads (such as `R3`) remain active; the visit stays `needs_review`.
5. **Coordinator resolution**: A coordinator resolves a `needs_review` visit by either selecting one of the competing head revisions or submitting a synthesized visit payload, while naming the set of competing head `revisionId`s being resolved. This creates a new revision `R_res` recording the coordinator's `authorId`, the `resolvedRevisionIds` set, and the chosen or synthesized payload. `R_res` supersedes all revisions in `resolvedRevisionIds`. If no other active heads remain, `R_res` becomes the sole active head and the visit transitions to `resolved`.

## Operations and Contracts

### Submit Visit Revision

Authenticated field workers submit visit creates and edits through a single idempotent operation.

| Field | Type | Description |
|---|---|---|
| `idempotencyKey` | UUID | Client-generated key per submission attempt |
| `visitId` | UUID | Client-generated identifier for the plot visit |
| `baseRevisionId` | UUID \| `null` | Revision the worker edited, or `null` for a new visit |
| `payload` | VisitPayload | Complete visit fields: `plotId` (UUID), `observationDate` (ISO 8601 date), `observers` (non-empty string list), `speciesCovers` (list of `{ speciesCode, coverPercent }`), `notes` (string) |

Validation rules:
- The caller must be an authenticated worker or coordinator.
- `payload.plotId` must exist in `site-catalog` (active or archived plots are valid for visit persistence; archival status only affects default tablet pickers).
- If `baseRevisionId` is non-null, it must reference an existing revision belonging to `visitId`.
- If `idempotencyKey` matches a previously accepted submission with an identical request body (`visitId`, `baseRevisionId`, and `payload`), the store returns the original acceptance response without creating a duplicate revision.
- If `idempotencyKey` matches a previously accepted submission with a different request body, the store rejects the request (`409 Conflict`) and leaves stored revisions unchanged.

Response:
- `revisionId`: Server-assigned UUID for the stored revision.
- `visitId`: UUID of the visit.
- `status`: Resulting visit status (`resolved` or `needs_review`).
- `currentRevisionId`: The authoritative `revisionId` when `status` is `resolved`, or `null` when `status` is `needs_review`.
- `competingRevisionIds`: List of active head `revisionId`s (contains one ID when `resolved`, two or more when `needs_review`).

### Retrieve Visit Current State

Used by `tablet-sync` and `review-export` to inspect a visit or list visits by status.

Response per visit:
- `visitId`: UUID.
- `status`: `resolved` or `needs_review`.
- `currentRevision`: Full revision object (`revisionId`, `authorId`, `receivedAt`, `baseRevisionId`, `resolvedRevisionIds`, `payload`) when `status` is `resolved`; `null` when `status` is `needs_review`.
- `competingRevisions`: List of active head revision objects (single element when `resolved`, all competing head revisions when `needs_review`).

### Retrieve Visit Revision History

Returns the complete, ordered lineage of all accepted revisions and coordinator resolutions for a `visitId`, preserving original payloads, `authorId`, `receivedAt`, `baseRevisionId`, and `resolvedRevisionIds` so the path from every submitted observation to the exported value is inspectable.

### Resolve Competing Revisions

Authenticated coordinators resolve `needs_review` visits.

| Field | Type | Description |
|---|---|---|
| `idempotencyKey` | UUID | Client-generated key for the resolution request |
| `visitId` | UUID | Target visit UUID |
| `resolvedRevisionIds` | list of UUID | The competing active head `revisionId`s addressed by this resolution (minimum 2) |
| `resolutionPayload` | VisitPayload | Complete visit payload to become the new revision (either matching one of the competing revisions or synthesized by the coordinator) |

Validation rules:
- Caller must be an authenticated coordinator.
- Every ID in `resolvedRevisionIds` must be a current active head revision of `visitId`.

Response:
- `revisionId`: Server-assigned UUID for the resolution revision.
- `visitId`: UUID of the visit.
- `status`: Resulting visit status (`resolved` or `needs_review`).
- `currentRevisionId`: The authoritative `revisionId` when `status` is `resolved`, or `null` when `status` is `needs_review`.
- `competingRevisionIds`: List of active head `revisionId`s.

## Downstream Obligations

- **`tablet-sync`**: Must store the server's `revisionId` alongside each synced visit and send it as `baseRevisionId` on subsequent edits. When a submission returns `needs_review`, the tablet must surface that the visit has competing revisions awaiting coordinator review.
- **`review-export`**: Must query `needs_review` visits to populate the coordinator revision comparison screen, submit coordinator resolutions via `Resolve Competing Revisions`, and include only visits with `status == resolved` (using `currentRevision`) in the Friday CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with `baseRevisionId` tracking and coordinator review for competing heads | Field-aware three-way merge; last-write-wins by receipt timestamp | Preserves each worker's submitted visit intact and avoids automated merge rules that can silently combine scientifically incompatible edits across related fields (such as species identity and cover estimate). Last-write-wins violates the tenet against silently discarding submitted edits. |
| Export eligibility during conflict | Hold `needs_review` visits out of `currentRevision` and CSV export until resolved | Export earliest head revision; export latest-received head revision | Arrival order does not reflect scientific authority after multi-day offline periods, and exporting an unreviewed competing revision could send inaccurate data to the regional science partner. |
| Resolution persistence | Store coordinator resolution as a new immutable revision linking `resolvedRevisionIds` and coordinator `authorId` | Mutate a winning revision in place; delete losing revisions | Keeps the lineage from every original field submission to the final exported record fully inspectable. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Concurrency policy for independent edits to the same visit: Whole-visit revisions selected over field-aware three-way merge so scientifically coupled fields are never auto-merged without human review.

### Deferred
1. Handling when a new competing submission arrives while a coordinator is resolving a conflict (`resolvedRevisionIds` is a strict subset of current active heads: reject as `409 Conflict` vs. resolve the listed subset and remain `needs_review`).
2. Whether `plotId` can be changed across revisions of the same `visitId` or is immutable once the visit is created.
3. Whether concurrent submissions with identical `VisitPayload` values still trigger `needs_review` or auto-resolve.
4. Field-level validation constraints on `VisitPayload` (`coverPercent` range, total cover exceeding 100% across canopy layers, duplicate `speciesCode` entries, empty `speciesCovers`).
5. Whether idempotent retries return the original point-in-time response snapshot or the visit's current status alongside the original `revisionId`.

## References

- High-Level Design: `docs/high-level-design.md`
- Site Catalog LLD: `docs/intent/site-catalog/site-catalog-design.md`
```

---

### 3. Phase 2 LLD Edge-Case Probe (Please Triage)

Which of these should we settle in the LLD now versus leave deferred?

1. **New competing head arrives during coordinator resolution (`resolvedRevisionIds` is a subset of current active heads)**:
   - **Option A**: Reject with `409 Conflict` (require `resolvedRevisionIds` to match the exact set of current active heads so the coordinator must see the newly arrived revision before resolving).
   - **Option B**: Allow partial resolution (`R_res` supersedes the listed heads; the unlisted head remains active and the visit stays `needs_review`).
2. **Late worker edit based on a revision already superseded by a coordinator resolution (`R_res`)**:
   - Should a worker submission whose `baseRevisionId` was already folded into `R_res` be accepted as a new competing head alongside `R_res` (re-opening the visit from `resolved` to `needs_review` so no submitted edit is discarded)?
3. **Changing `plotId` across revisions of the same `visitId`**:
   - Can a later revision or coordinator resolution change `plotId` (e.g., to fix a mis-selected plot), or is `plotId` immutable once a `visitId` is created?
4. **Concurrent submissions with identical payloads**:
   - If two concurrent submissions against the same `baseRevisionId` have identical `VisitPayload` values, should they still enter `needs_review` or automatically resolve?
5. **Scientific field constraints on `VisitPayload`**:
   - What validation rules apply to `speciesCovers` (e.g., `coverPercent` bounds `0–100`, whether sum of `coverPercent` across species can exceed `100%` due to canopy layering, whether duplicate `speciesCode` entries in one visit are rejected, and whether an empty `speciesCovers` list is valid for barren plots)?
6. **Idempotent retry response when visit state has since advanced**:
   - When a client retries an already-accepted `idempotencyKey` after a subsequent revision or resolution has changed the visit's state, does the response return the **original point-in-time acceptance snapshot** or the ** original `revisionId` with current visit status**?

How would you like to rule on the decision doc offer, the LLD draft, and these probe questions before we move to Phase 3 (EARS specs)?