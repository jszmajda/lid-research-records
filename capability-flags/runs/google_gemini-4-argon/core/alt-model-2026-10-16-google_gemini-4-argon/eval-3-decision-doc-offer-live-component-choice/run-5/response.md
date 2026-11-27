I have updated `docs/high-level-design.md` (marking `record-store`'s concurrency choice resolved) and drafted the complete `record-store` LLD in `docs/intent/record-store/record-store-design.md` around whole-visit revisions.

### Decision Doc Offer

Because the concurrency choice between **whole-visit revisions** and **field-aware three-way merge** is a live architectural trade-off that sizes both `tablet-sync` and `review-export`, it clears the bar for a standalone decision doc (`docs/intent/record-store/decisions/concurrent-visit-edits.md`) in addition to the row in the LLD's Decisions & Alternatives table. Would you like me to write that decision doc, or is the table row in `record-store-design.md` sufficient?

---

### Updated `docs/high-level-design.md` (excerpt)

```markdown
| Node | Responsibility | Design | State |
|---|---|---|---|
| site-catalog | Maintain stable plot references and distribute the field catalog | docs/intent/site-catalog/site-catalog-design.md | Drafted |
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | docs/intent/tablet-sync/tablet-sync-design.md | Not written |
| review-export | Present review work and produce the partner's reviewed CSV | docs/intent/review-export/review-export-design.md | Not written |

The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and review-export depend on that node's contract for submission metadata, the shape of review work, and which record states can enter an export.
```

---

### Updated `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are related, such as revising a species identification and its cover estimate. Because the server cannot infer scientific relationships between fields from field names alone, the store treats each submitted visit as an indivisible whole-visit revision rather than merging fields automatically.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, and review-outcome operations. Persistence keeps an immutable log of revisions: each revision records its revision ID, parent revision IDs, author or coordinator identity, server receipt time, and full visit payload.

Each visit maintains a current state determined by its active revision set:

- **Resolved (`current`)**: A single revision is the unambiguous head of the visit's revision graph.
- **Unresolved (`in_review`)**: Multiple competing revisions exist because concurrent submissions referenced the same base revision (or an ancestor that already had a successor). No single revision is authoritative until a coordinator resolves the branch.

## Submission Contract

A submission carries:
- `idempotency_key`: Client-generated UUID for retry safety.
- `visit_id`: Client-generated UUID identifying the visit.
- `base_revision_id`: The revision ID the worker edited from (`null` when creating a new visit).
- `payload`: Complete visit data (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`).

The store authenticates the submitting worker and validates field types and plot references (via `site-catalog`, permitting both active and archived plot UUIDs so historical visits remain editable) before accepting a submission.

### Idempotency
A retry with an existing `idempotency_key` and an identical submission envelope (`visit_id`, `base_revision_id`, and `payload`) returns the original acceptance result without storing a duplicate revision. Reusing an `idempotency_key` with any difference in `visit_id`, `base_revision_id`, or `payload` is rejected with a conflict error and leaves stored state unchanged.

### Revision Advancing and Forking
When a valid submission is accepted, the store assigns a new `revision_id` and records the immutable submission:

1. **Initial creation**: When `base_revision_id` is `null` and the visit does not yet exist, the new revision becomes the sole active head. The visit state is `current`.
2. **Linear update**: When the visit is `current` and `base_revision_id` matches the active head revision ID, the new revision replaces the head as the sole active revision. The visit remains `current`.
3. **Concurrent edit (fork)**: When `base_revision_id` refers to an existing revision of the visit that is not the sole active head — or when `base_revision_id` is `null` for a visit that already exists — the new revision is added to the visit's competing active heads alongside the existing head(s). The visit state becomes `in_review`.
4. **Unknown base revision**: When `base_revision_id` does not match any stored revision for that `visit_id`, the submission is rejected.

## Retrieval Contract

### Current-State Retrieval
Retrieving a visit returns:
- `visit_id`: The visit UUID.
- `status`: `current` or `in_review`.
- `head_revision`: When `status` is `current`, the single active revision (ID, parent revision IDs, author/coordinator, receipt time, optional resolution note, and payload). When `status` is `in_review`, `null` so callers cannot accidentally export an unresolved revision as authoritative.
- `competing_revisions`: When `status` is `in_review`, the list of active competing head revisions (each with its ID, parent revision IDs, author, receipt time, and payload). Empty when `status` is `current`.

### History Retrieval
Retrieving a visit's history returns the complete lineage of submitted revisions and coordinator resolution records in topological/chronological order, preserving every original submission and resolution outcome for audit.

## Review Resolution Contract

To resolve a visit that is `in_review`, an authenticated coordinator submits a resolution containing:
- `visit_id`: The visit being resolved.
- `superseded_revision_ids`: The exact set of competing active head revision IDs being resolved.
- `payload`: The chosen or synthesized complete visit payload (which may match one of the competing revisions or combine values after human inspection).
- `resolution_note` (optional): Coordinator explanation of the decision.

When accepted:
1. The store verifies that `superseded_revision_ids` matches the visit's current set of competing head revisions. If another worker submission arrived while the coordinator was reviewing (changing the competing head set), the resolution is rejected as stale so the new submission is not silently overwritten.
2. The store creates a new authoritative revision whose parent list is `superseded_revision_ids`, recording the coordinator's identity, server receipt time, and the resolved payload.
3. This new revision becomes the sole active head, and the visit status returns to `current`.
4. All superseded revisions remain in the revision history.

## Downstream Obligations (Cascade Notes)

- **`tablet-sync`**: Must store the `revision_id` received with each downloaded or accepted visit and send it as `base_revision_id` on subsequent edits (`null` for new visits). Must surface `in_review` status and competing revisions when syncing visits that forked.
- **`review-export`**: Must query visits with status `in_review` for the coordinator comparison queue, submit resolutions naming the `superseded_revision_ids`, and include only visits with status `current` (using `head_revision`) in the Friday partner CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent visit edit policy | Whole-visit revisions with explicit base revision tracking and coordinator resolution | Field-aware three-way merge; last-write-wins | Scientific fields within a visit can depend on one another (e.g., a species identification and its cover estimate). Whole-visit revisions keep each worker's submission intact for human review without maintaining field-level merge rules that could silently combine scientifically incompatible edits. Last-write-wins violates the tenet against silently discarding submitted edits. |
| Concurrent resolution race handling | Require resolution requests to name the exact `superseded_revision_ids` set; reject if new competing heads arrived | Blindly overwrite current competing state | If a tablet syncs an offline edit while a coordinator is reviewing, a blind resolution would silently bury the newly arrived submission, violating the tenet against discarding submitted edits. |
```

---

### Phase 2 LLD Edge-Case Probe

Please review these internal edge cases and let me know which to settle in the LLD now versus defer:

1. **Follow-up edit on one branch while already `in_review`**: If a visit is `in_review` with competing heads `[R1, R2]` and a worker submits `R3` based on `R1`, does `R3` *replace* `R1` in the active competing heads (yielding leaves `[R2, R3]`), or remain alongside `R1` (`[R1, R2, R3]`)?
2. **Client- vs. server-generated `revision_id` (chained offline edits)**: If a tablet creates a visit offline and edits it a second time before reconnecting, can the client generate `revision_id` UUIDs (so edit 2 can reference edit 1's `revision_id`), or are `revision_id`s strictly server-assigned (requiring `tablet-sync` to collapse local drafts or sync sequentially)?
3. **Concurrent identical payloads**: If two workers independently submit the exact same `payload` against the same `base_revision_id` (with different `idempotency_key`s), should the store still fork into `in_review`, or treat them as non-conflicting?
4. **Plot ID mutability across revisions**: Can a subsequent edit or coordinator resolution change a visit's `plot_id` (e.g., if a worker initially selected the wrong plot), or is `plot_id` immutable after visit creation?
5. **Idempotency on rejected submissions & resolution requests**:
   - Should coordinator resolutions also carry an `idempotency_key` so retries after a network timeout don't fail as stale?
   - Are `idempotency_key`s recorded only for *accepted* submissions (so a rejected request doesn't lock out the key), and scoped globally across the store?
6. **List/query operations for downstream consumers**: Beyond single-visit lookup, should the Retrieval Contract explicitly define list queries (e.g., list visits filtered by `status` or updated since a timestamp/cursor) for `review-export` and `tablet-sync`?

How would you like to rule on the decision doc offer, the LLD draft, and these probe items before we move to Phase 3 (EARS specs)?