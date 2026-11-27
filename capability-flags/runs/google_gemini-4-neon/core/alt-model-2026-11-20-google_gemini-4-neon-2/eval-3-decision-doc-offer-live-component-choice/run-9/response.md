Updated `docs/intent/record-store/record-store-design.md` for whole-visit revisions (Phase 2). Stopping here for your review before updating `docs/intent/record-store/record-store-specs.md` (Phase 3) or touching `docs/high-level-design.md`'s stale `concurrency choice open` status line.

---

### Updated LLD: `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, revision lineage, and the definition of a visit's current state when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a `site-catalog` plot UUID. Updates can arrive days after their starting state was fetched, and arrival order is not evidence that one worker's observations are more authoritative.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are scientifically coupled, such as revising a species identification and its cover estimate. Because the server cannot infer scientific coupling from field names, the record store treats each submitted visit as an indivisible unit using whole-visit revisions.

## Revision Model and Visit States

Every accepted submission is stored as an immutable whole-visit revision with a server-assigned `revision_id`, its `base_revision_id`, the complete visit payload, the authenticated `author_id`, and the server `received_at` timestamp. Original revisions are never modified or deleted.

A visit is always in one of two states:

- `current` — The visit has a single unambiguous active revision (`current_revision_id`) and is eligible for export.
- `needs_review` — Two or more competing revisions exist without a superseding coordinator resolution. The visit has no active exportable revision until resolved.

### State Transitions

1. **Initial creation (`base_revision_id: null`)**: If no revision exists for `visit_id`, the submission becomes the visit's first revision and the visit enters `current`.
2. **Linear update**: While the visit is `current`, if a submission's `base_revision_id` equals `current_revision_id`, the new revision advances `current_revision_id` and the visit remains `current`.
3. **Concurrent edit (fork)**:
   - While the visit is `current`, if a submission's `base_revision_id` references an earlier revision (not `current_revision_id`), the submission is accepted and persisted, the visit transitions to `needs_review`, and both `current_revision_id` and the new revision become competing head revisions.
   - While the visit is `needs_review`, any further accepted submission for that visit (whether based on an earlier revision or on one of the competing heads) is persisted and added to the competing head set (replacing its direct parent if its `base_revision_id` was itself a competing head). The visit remains `needs_review`.
4. **Coordinator resolution**: A coordinator resolves all current competing heads for a `needs_review` visit by producing a resolved revision (either by adopting one competing revision's payload or by authoring a reconciled whole-visit payload). The visit transitions back to `current` with the resolved revision as `current_revision_id`.

Arrival order does not privilege an earlier-arriving edit over a concurrent edit from the same base revision; once a competing edit arrives, both sit equally in the competing head set for coordinator review.

## Operations and Contracts

| Operation | Purpose | Key Inputs | Key Outputs |
|---|---|---|---|
| Submit visit revision | Persist a new whole-visit revision and update visit state | `visit_id`, `idempotency_key`, `base_revision_id`, visit payload | `revision_id`, `visit_id`, `received_at`, `visit_status`, `competing_revision_ids` |
| Get current visit | Retrieve a visit's current state and export eligibility | `visit_id` | `visit_id`, `status`, `export_eligible`, `current_revision` (when `current`), `competing_revisions` and `base_revision_id` (when `needs_review`) |
| Get visit history | Retrieve immutable revision and resolution lineage | `visit_id` | Ordered list of revisions (payloads, authors, base IDs, receipt times) and resolution records |
| List unresolved visits | Retrieve visits awaiting coordinator review | Optional filter (site, date range) | Visits in `needs_review` with competing revisions and common ancestor reference |
| Resolve visit | Clear competing revisions and establish a new current revision | `visit_id`, `resolved_competing_revision_ids`, resolution payload (or chosen `revision_id`), optional note | `resolution_id`, `current_revision_id`, `visit_status` (`current`), `resolved_by`, `resolved_at` |

### Submission Envelope and Validation

Before accepting a submission, the record store authenticates the submitting worker and validates field types, `plot_id` existence in `site-catalog`, and `base_revision_id` validity:

- If `base_revision_id` is `null`, `visit_id` must not already exist.
- If `base_revision_id` is non-null, it must reference an existing revision belonging to `visit_id`.

Each submission carries a client-generated `idempotency_key`. A retry with the same `idempotency_key` and an identical payload returns the original acceptance response without creating another revision. Reuse of an accepted `idempotency_key` with a different payload is rejected, leaving the original revision unchanged.

### Current-State and History Retrieval

Current-state retrieval explicitly separates export-ready visits from unresolved review work:

- When `status` is `current`: `export_eligible` is `true` and `current_revision` holds the active revision and payload.
- When `status` is `needs_review`: `export_eligible` is `false`, `current_revision` is `null`, and the response includes the `competing_revisions` set along with the common ancestor revision (when one exists) so callers can display or compare the divergence.

History retrieval returns every submitted revision and every resolution record for the visit, preserving original payloads separately from any later resolved revision so any exported value can be traced back to the submissions that produced it.

### Unresolved-Work Representation and Resolution

An unresolved review item corresponds to a visit in `needs_review` state and exposes:

- `visit_id` and `plot_id`
- `competing_revisions`: each competing head revision with its `revision_id`, `base_revision_id`, `author_id`, `received_at`, and complete visit payload
- `common_ancestor_revision`: the most recent revision shared by the competing heads (when one exists)

To resolve a visit, an authenticated coordinator submits:

- `visit_id`
- `resolved_competing_revision_ids`: the exact set of competing head revision IDs the coordinator reviewed
- The resolved visit outcome: either a selected `winning_revision_id` from the competing set or a coordinator-authored whole-visit payload
- An optional coordinator resolution note

The record store verifies that `resolved_competing_revision_ids` matches the visit's current competing head set. If another concurrent submission arrived after the coordinator loaded the review screen, the resolution is rejected so the newly arrived revision is not silently superseded. On success, the record store persists a resolution record capturing the coordinator's identity, timestamp, and contributing competing revision IDs, establishes the resulting resolved revision as `current_revision_id`, and transitions the visit to `current`. All original competing revisions remain intact in history.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions | Field-aware three-way merge | Preserves each submitted visit as an intact scientific unit so related field edits (such as species identification and cover estimate) are never silently combined by merge rules. Avoids maintaining field-level merge rules for scalar fields, observer lists, and species entries, trading a larger coordinator review queue when workers edit unrelated fields concurrently. |

## Downstream Cascade Notes

This node owns the concurrency contract. Sibling nodes consume it without redefining concurrency semantics:

- **tablet-sync**: Retain `base_revision_id` alongside each local draft, submit complete visit payloads with a stable `idempotency_key` per edit, and surface `needs_review` outcomes to field workers.
- **review-export**: Present a side-by-side comparison of competing revisions for `needs_review` visits, pass the reviewed `resolved_competing_revision_ids` set when resolving, and exclude `needs_review` visits from the Friday CSV export.

## Open Questions & Future Decisions

### Deferred
- Pagination and filtering parameters for listing unresolved visits once review queue volume is observed in practice.
```

---

### Decision Doc Offer

Because whole-visit revisions vs. field-aware three-way merge trades credible options across multiple criteria (scientific integrity and rule-maintenance burden vs. coordinator review volume) and both `tablet-sync` and `review-export` will be sized around this choice, a cold reader could reasonably re-litigate it later.

Would you like me to record this choice as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD's `Decisions & Alternatives` row), or keep only the `Decisions & Alternatives` row in `record-store-design.md`?

---

### Phase 2 LLD Edge-Case Probe

Please triage which of these gaps to specify in the LLD now vs. defer to Open Questions:

1. **Resolution revision ID**: When a coordinator resolves a `needs_review` visit by selecting a `winning_revision_id`, does `current_revision_id` reuse that existing `revision_id` or mint a new resolved `revision_id` (and what `base_revision_id` is recorded on a coordinator-authored resolved revision)?
2. **Late post-resolution edits**: When a late submission arrives whose `base_revision_id` references a pre-resolution revision after the visit is back to `current`, does it re-open `needs_review` with the resolved revision and late submission as competing heads—and how is `common_ancestor_revision` defined across a resolution?
3. **Resolution idempotency**: `Resolve visit` currently has no `idempotency_key`. If a coordinator's resolution request times out and retries (or two coordinators resolve simultaneously), should resolution also accept an `idempotency_key` or simply reject once the visit is `current`?
4. **Per-visit serialization**: When two submissions for the same `visit_id` (or a submission and a `Resolve visit` call) execute concurrently, should the LLD explicitly require per-visit atomic serialization to prevent lost updates or silent superseding?
5. **Idempotency key scope & retry response**: Is `idempotency_key` scoped per visit, per author, or globally, and does a valid retry after the visit's state has since changed return the original acceptance snapshot or the visit's current `visit_status` and `competing_revision_ids`?
6. **`plot_id` mutability**: Can a subsequent revision or coordinator resolution change `plot_id` for an existing `visit_id`, or is `plot_id` immutable once created? (If mutable, which `plot_id` appears on a `needs_review` item when competing heads disagree?)
7. **Identical payloads**: When two concurrent edits from the same `base_revision_id` submit identical payloads (or a linear edit submits an unchanged payload), does the store still persist a new revision and enter `needs_review`, or deduplicate identical content?
8. **Role & self-resolution rules**: Should the LLD specify role boundaries (e.g., only coordinators can call `Resolve visit`, whether coordinators can submit regular visit revisions, and whether a coordinator may resolve a conflict containing their own revision)?
9. **Error shapes**: Should the LLD specify distinct error codes and diagnostic fields for contract rejections (e.g., duplicate initial `visit_id`, `base_revision_id` mismatch, `idempotency_key` payload mismatch, stale `resolved_competing_revision_ids` returning the latest competing head IDs)?

Let me know your feedback on the LLD, your choice on the decision doc, and how you'd like to triage items 1–9 (and whether to refresh the HLD's `record-store` status line once we finalize this LLD).