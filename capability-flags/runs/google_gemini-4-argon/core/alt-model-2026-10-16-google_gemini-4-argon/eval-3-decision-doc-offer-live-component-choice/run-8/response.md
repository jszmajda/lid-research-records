I have updated `docs/intent/record-store/record-store-design.md` (and marked `record-store` as `Drafted` in `docs/high-level-design.md`) to complete the Phase 2 LLD for whole-visit revisions.

### 1. Decision Recording Offer

Selecting **whole-visit revisions** over **field-aware three-way merge** is a live architectural choice that trades review queue volume against preserving whole-visit scientific coherence, and both `tablet-sync` and `review-export` will be sized around it.

Would you like me to record this as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-revisions.md` (linked from the LLD's Decisions & Alternatives table), or keep it solely as the row in the LLD's `Decisions & Alternatives` table?

---

### 2. Updated `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are related, such as revising a species identification and its cover estimate. Because the server cannot infer scientific relationships across fields from field names alone, the store treats each submitted visit as an indivisible unit of observation rather than merging individual fields automatically.

## Revision Model

Each accepted submission creates an immutable visit revision with a server-assigned revision ID, the client-supplied visit ID, the base revision ID it was edited from (`null` for an initial submission), the submitting worker's author ID, the server receipt timestamp, and the complete visit payload.

A visit's state is derived from its revision graph:

- **Single active head (`current`)**: When a visit has one un-superseded revision, that revision is the current visit state and the visit has no unresolved review work.
- **Linear update**: When a new submission's `base_revision_id` matches the visit's sole active head, the new revision supersedes that head and becomes the new `current` revision without creating review work.
- **Competing revisions (`needs_review`)**: When a submission's `base_revision_id` refers to a revision that has already been superseded—or is `null` when the visit already exists—the new revision is added as a competing head alongside the existing active head(s). The visit enters the `needs_review` state until a coordinator resolves the active heads into a single revision.

## Submission Contract

`POST /visits/{visit_id}/revisions`

The submitting worker must be authenticated. Before accepting a submission, the store validates field types, verifies that `plot_id` resolves in `site-catalog` (active or archived plots are accepted so offline edits to recently archived plots are not lost), and checks that `base_revision_id` (when non-null) belongs to `{visit_id}`.

| Field | Type | Description |
|---|---|---|
| `idempotency_key` | UUID | Client-generated key per submission attempt |
| `base_revision_id` | Revision ID \| `null` | Revision the worker started from, or `null` for a first submission |
| `payload` | VisitPayload | Complete visit record (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`) |

**Idempotency**:
- Repeating an accepted `idempotency_key` with an identical `base_revision_id` and `payload` returns the original acceptance response (`revision_id` and resulting visit state) without creating a duplicate revision.
- Repeating an accepted `idempotency_key` with a different `base_revision_id` or `payload` is rejected with `409 Conflict` and leaves stored revisions unchanged.
- An unknown `base_revision_id` or a `base_revision_id` belonging to a different visit is rejected with `422 Unprocessable Entity`.

## Retrieval and Unresolved-Work Representation

- `GET /visits/{visit_id}` returns the visit's current status (`current` or `needs_review`), the `current_revision` (when status is `current`, or the last non-conflicted revision if tracked), and the full set of `active_head_revisions` when status is `needs_review`.
- `GET /visits/{visit_id}/revisions` returns the complete immutable history of revisions and resolution metadata in receipt order so the path from any submitted observation to the current value remains inspectable.
- `GET /visits?status=needs_review` lists visits with more than one active head so `review-export` can build the coordinator review queue and hold unresolved visits out of the Friday CSV export.

## Resolution Operation

`POST /visits/{visit_id}/resolutions`

A coordinator resolves competing revisions by submitting a resolution that names the exact set of active head revision IDs being resolved (`resolved_revision_ids`) and the resulting complete `payload` (either matching one of the competing revisions or combining values after manual inspection).

- The store verifies the caller is an authenticated coordinator and that `resolved_revision_ids` matches a subset or the full set of currently active heads for `{visit_id}`.
- The store creates a new immutable revision recording the coordinator's identity, server timestamp, `resolved_revision_ids` as its parent provenance, and the chosen `payload`.
- Each revision in `resolved_revision_ids` is marked superseded by the new resolution revision. If no other active heads remain (for example, if no additional tablet submission arrived while the coordinator was reviewing), the new revision becomes the sole active head and the visit returns to `current`. If another tablet submission arrived concurrently and was not in `resolved_revision_ids`, it remains an active head alongside the resolution revision and the visit stays in `needs_review`.

## Downstream Obligations

This contract creates the following obligations for sibling nodes (to be designed next):

- **`tablet-sync`**: Must store the `revision_id` of the downloaded visit as `base_revision_id` alongside local drafts, send complete visit payloads with `base_revision_id` and `idempotency_key`, and surface to the worker when a submission lands in `needs_review`.
- **`review-export`**: Must query unresolved visits, present competing active head revisions for coordinator comparison, submit `resolved_revision_ids` with the resolved payload, and exclude any visit in `needs_review` from the partner CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit handling | Whole-visit revisions with explicit `base_revision_id` and coordinator resolution of competing heads | Field-aware three-way merge using base snapshots and per-field merge rules | Whole-visit revisions preserve each submitted visit as a coherent scientific observation and avoid maintaining field-merge rules that can silently combine scientifically related edits (such as species identity and cover estimate). Accepting a larger coordinator review queue is preferable to risking unreviewed cross-field combinations. |
| Resolution target set | Resolution explicitly lists `resolved_revision_ids` rather than blindly clearing all conflict state on the visit | Resolve-all-current-heads without naming revision IDs | Naming the exact revision IDs the coordinator inspected prevents a late-arriving tablet submission from being silently superseded if it arrives while the coordinator has the comparison view open. |
```

---

### 3. Phase 2 LLD Edge-Case Probe

Please review these edge cases surfaced against the `record-store` LLD and let me know which ones to tighten in the LLD now versus defer:

1. **Extending one branch of a conflicted visit**: When a visit is already in `needs_review` (e.g., active heads $R_1$ and $R_2$) and a worker submits an edit with `base_revision_id: R_1`, should the new revision supersede $R_1$ (leaving $R_{\text{new}}$ and $R_2$ as the two active heads in `needs_review`), or treat all edits during `needs_review` as additional heads without superseding $R_1$?
2. **`current_revision` when in `needs_review`**: In `GET /visits/{visit_id}`, when a visit is in `needs_review`, should `current_revision` be `null` (with callers inspecting `active_head_revisions`), or should it return the last single-head ancestor before the fork?
3. **Competing submissions with identical payloads**: If two workers independently submit the exact same payload from the same `base_revision_id` (different `idempotency_key`s), should the store still record both revisions and enter `needs_review`, or auto-collapse identical payloads?
4. **Changing `plot_id` across revisions**: May a subsequent revision or coordinator resolution change a visit's `plot_id` (e.g., if a worker accidentally recorded a visit against the wrong plot), or is `plot_id` immutable once a visit is created?
5. **Minimum cardinality & stale IDs in `resolved_revision_ids`**: Should `POST /visits/{visit_id}/resolutions` require at least 2 currently active head IDs in `resolved_revision_ids` and reject (`409 Conflict`) if any listed ID has already been superseded (which also handles duplicate resolution retries)?
6. **`VisitPayload` domain validation**: Beyond checking that `plot_id` resolves in `site-catalog` and basic field types, what domain invariants should `record-store` enforce on `VisitPayload` (e.g., non-empty `observers`, cover percentage bounds `0–100`, unique species per visit), vs. leaving domain rules minimal?

Please share your feedback on the LLD, the decision doc offer, and which probe items to fold in before we move to Phase 3 (`record-store-specs.md`).