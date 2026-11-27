`docs/intent/record-store/record-store-design.md` has been updated around whole-visit revisions. Below is the Phase 2 LLD in full, followed by a decision-doc offer, the LLD edge-case probe for triage, and a cross-doc coherence check before we move to Phase 3 (`record-store-specs.md`).

---

### Updated LLD (`docs/intent/record-store/record-store-design.md`)

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, revision lineage, and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID (`visit_id`) and refers to a catalog `plot_id` from `site-catalog`. Because shared field tablets can remain offline for 48 hours, edits can arrive days after their starting state was fetched. Arrival order does not establish that one worker's observation is more authoritative than another's.

A visit's scientific fields — observation date, observer list, species cover estimates, and notes — can carry implicit cross-field relationships, such as revising a species identification together with its cover estimate, that field names alone do not reveal. Each submission therefore carries a complete visit snapshot naming the revision it was edited from. Concurrent edits derived from the same starting state remain intact as competing revisions for coordinator review.

## Architecture

The record store exposes authenticated operations for visit submission, current-state retrieval, unresolved-review listing, history retrieval, and coordinator resolution.

Persistence separates original worker submissions from revision-graph state so field observations remain intact across later resolutions:

- **Worker submissions** (`submission_id`): immutable records holding the exact payload submitted by an authenticated worker, `visit_id`, `base_revision_id`, `author_id`, `idempotency_key`, and server receipt time (`received_at`).
- **Visit revisions** (`revision_id`): immutable nodes in a visit's revision graph holding a complete visit payload, `visit_id`, parent revision reference(s), creation timestamp, and provenance (`submission_id` and `author_id` for a worker edit, or `resolution_id` and `coordinator_id` for a coordinator resolution).

Every accepted worker submission creates both a stored worker submission and a new visit revision. Every accepted coordinator resolution creates a resolution record and a new visit revision superseding the reviewed competing revisions.

## Revision Lineage and Visit State

A visit's review state is determined by its active head revisions (revisions not yet superseded by a subsequent linear edit or coordinator resolution):

- `resolved`: the visit has a single active head revision, which is its authoritative current state.
- `unresolved`: the visit has two or more active competing head revisions awaiting coordinator resolution; no single revision is authoritative until resolved.

Lineage transitions:

1. **Initial creation** (`base_revision_id: null`): for a new `visit_id`, the accepted submission creates the visit's first revision as its sole active head (`resolved`).
2. **Linear edit**: when a visit is `resolved` and an accepted submission names the active head as `base_revision_id`, the new revision supersedes that head and becomes the sole active head (`resolved`).
3. **Concurrent edit**: when an accepted submission names an ancestor revision that has already been superseded, or arrives while the visit is `unresolved`, the submission and its new revision are retained and the visit enters or remains in `unresolved` state with multiple competing head revisions.
4. **Coordinator resolution**: when an authenticated coordinator resolves the active competing head revisions of an `unresolved` visit, the resulting revision supersedes those heads and becomes the sole active head (`resolved`).

## Submission and Idempotency

### Submission Envelope

| Field | Description |
|---|---|
| `idempotency_key` | Client-generated retry token preventing duplicate edits across connection failures |
| `visit_id` | Client-generated UUID identifying the visit |
| `base_revision_id` | `revision_id` the worker edited from, or `null` when creating a new visit |
| `payload.plot_id` | Plot UUID validated against `site-catalog` |
| `payload.observation_date` | Survey observation date |
| `payload.observers` | List of observer names for the visit |
| `payload.species_cover` | Species cover entries (species identification and cover estimate) |
| `payload.notes` | Visit notes |

The submitting worker's `author_id` comes from the authenticated request context. Before accepting a submission, the store authenticates the worker, validates field types, verifies that `payload.plot_id` exists in `site-catalog`, and verifies that any non-null `base_revision_id` belongs to `visit_id`.

Repeating an accepted `idempotency_key` with an identical submission (`visit_id`, `base_revision_id`, and `payload`) returns the original acceptance response without creating another stored submission or revision. Repeating an accepted `idempotency_key` with a different submission payload or metadata is rejected and leaves the original submission unchanged.

### Acceptance Response

An accepted submission returns `submission_id`, the newly assigned `revision_id`, `received_at`, the visit's resulting `status` (`resolved` or `unresolved`), and the current active head `revision_id`s.

## Retrieval and Resolution Operations

### Current-State Retrieval

Retrieving a visit by `visit_id` returns:

- `visit_id` and `status` (`resolved` or `unresolved`)
- `current_revision`: the single active head revision (`revision_id`, `payload`, provenance, timestamp) when `status` is `resolved`, or `null` when `status` is `unresolved`
- `competing_revisions`: empty when `status` is `resolved`; when `status` is `unresolved`, all active competing head revisions (each with `revision_id`, `parent_revision_ids`, `payload`, provenance, and timestamp) plus the ancestor revision snapshots needed to compare edits

### Unresolved-Work Retrieval

Coordinators and export workflows can list all visits currently in `unresolved` status, returning each visit's `visit_id`, referenced `plot_id` values, competing head count, earliest competing head timestamp, and competing revision details.

### Submission and Revision History Retrieval

History retrieval for a `visit_id` returns the immutable worker submissions (`submission_id`, `resulting_revision_id`, `author_id`, `base_revision_id`, `received_at`, original `payload`) and coordinator resolution outcomes (`resolution_id`, `resulting_revision_id`, `coordinator_id`, `resolved_at`, `superseded_revision_ids`, `contributing_submission_ids`, resolved `payload`), keeping the path from every submitted observation to the current revision inspectable.

### Coordinator Resolution

| Field | Description |
|---|---|
| `visit_id` | UUID of the unresolved visit |
| `superseded_revision_ids` | Active competing head `revision_id`s reviewed by the coordinator |
| `contributing_submission_ids` | Worker `submission_id`s accounted for in the resolution outcome |
| `payload` | Complete resolved visit payload (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`) |

The coordinator's identity (`coordinator_id`) comes from the authenticated coordinator context. The store validates `payload` under the same structural and `plot_id` checks as worker submissions, verifies that the named `contributing_submission_ids` belong to `visit_id`, and checks that `superseded_revision_ids` matches the visit's current active competing head set. If another worker submission arrived while the coordinator was reviewing, the active head set no longer matches and the resolution is rejected so the newly arrived revision is not silently superseded.

On acceptance, the store records the resolution outcome with `coordinator_id`, `resolved_at`, `superseded_revision_ids`, and `contributing_submission_ids`, creates a new single active head `revision_id` carrying the resolved `payload`, transitions the visit to `resolved`, and returns `resolution_id`, `resulting_revision_id`, `resolved_at`, and `status: resolved`. Later tablet edits to that visit reference the new `revision_id` as their `base_revision_id`.

## Downstream Contracts

Sibling nodes integrate with `record-store` through these contracts:

- **tablet-sync**: stores the fetched `revision_id` as `base_revision_id` for local edits (`null` for new visits), sends complete visit payloads with a per-edit `idempotency_key`, advances its stored `base_revision_id` when an accepted submission returns `resolved`, and surfaces to field workers when an accepted edit results in an `unresolved` visit awaiting coordinator review.
- **review-export**: retrieves `unresolved` visits to drive a coordinator revision comparison screen (displaying competing revisions alongside their base revisions), submits coordinator resolutions naming `superseded_revision_ids` and `contributing_submission_ids`, surfaces unresolved visits before the Friday export, and holds `unresolved` visits out of the exported CSV.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with coordinator resolution of competing heads | Field-aware three-way merge (tablets retain base snapshots and send structured field changes; server auto-combines disjoint field edits and routes overlapping fields to review); arrival-order overwrite (eliminated by the HLD tenet against silently discarding submitted edits) | Survey fields carry implicit botanical dependencies — such as revising a species identification alongside its cover estimate — that field-level merge rules cannot detect. Whole-visit revisions keep each worker's observation intact and avoid maintaining merge rules across scalar, observer-list, and species-cover fields for a two-coordinator team, trading a larger review queue when concurrent edits touch unrelated fields. |
| Submission vs. revision records | Separate immutable worker submissions (`submission_id`) from revision-graph nodes (`revision_id`) | Single submission table used directly as the revision graph | Coordinator resolutions produce a current visit state that tablets must later edit against via `base_revision_id`, while original worker submissions must remain immutable and individually attributable via `contributing_submission_ids`. |
| Stale-base worker edits | Accept onto the revision graph as competing heads (`unresolved`) | Reject submissions with a superseded `base_revision_id` at upload time | Shared tablets operate offline for up to 48 hours; rejecting stale-base edits during sync would force whichever worker syncs the tablet to reconcile another worker's observations in the field instead of capturing every submitted edit durably for coordinator review. |
| Concurrent edit arrival during coordinator review | Require `superseded_revision_ids` to match the visit's active competing head set | Allow coordinator resolution to overwrite the visit unconditionally | If a delayed tablet uploads another revision while a coordinator is reviewing, an unconditional resolution would supersede a revision the coordinator never inspected. |

## References

- High-level design: `docs/high-level-design.md`
- Plot reference source: `docs/intent/site-catalog/site-catalog-design.md`
- Requirements: `docs/intent/record-store/record-store-specs.md`
```

---

### Recording the Concurrency Decision

Right now the concurrency choice is recorded as a row in `record-store-design.md`'s `Decisions & Alternatives` table. Because both options remain credible to a future reader (seeing unrelated-field edits enter coordinator review can tempt someone to introduce automatic field merging unless the botanical cross-field dependency and merge-rule maintenance tradeoffs are laid out against explicit criteria) and both `tablet-sync` and `review-export` are about to be sized around this choice, would you like a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` linked from that table row, or is the table row sufficient?

---

### Phase 2 LLD Edge-Case Probe (Triage: Fix in LLD vs. Defer)

Please let me know which of these internal `record-store` edge cases you want specified in the LLD now versus deferred to `Open Questions & Future Decisions`:

1. **Sequential offline edits on an already-competing branch**: If Tablet A submits `R1 -> R2` (`resolved`), goes offline, and edits `R2 -> R4` while Tablet B submits `R1 -> R3` (`unresolved` with `{R2, R3}`), when `R4` (`base_revision_id: R2`) arrives does `R4` supersede `R2` so active competing heads are `{R3, R4}`, or stay alongside `R2` (`{R2, R3, R4}`) so the coordinator compares intermediate `R2` directly?
2. **Multi-step ancestor snapshots in `Current-State Retrieval`**: When a competing branch spans multiple edits (e.g., `R1 -> R2 -> R4` vs. `R1 -> R3`) or includes a prior coordinator resolution head, should `competing_revisions` include all intermediate revisions back to the lowest common ancestor (`R1` and `R2`), or only immediate parents?
3. **Duplicate `visit_id` creation (`base_revision_id: null` on an existing visit)**: If a submission arrives with `base_revision_id: null` and a new `idempotency_key` for an existing `visit_id`, should the store reject it as a creation conflict or accept it as a parentless competing head?
4. **`idempotency_key` scope and replay response**: Is `idempotency_key` scoped per `author_id`, per `visit_id`, or globally — and if replayed after later edits changed the visit's state, does the replay return the frozen acceptance snapshot from initial receipt or the visit's live `status` / active heads?
5. **Coordinator resolution retries**: Should Coordinator Resolution also accept an `idempotency_key` (or treat an identical resolution retry as idempotent), or fail the active-head check if the network dropped the first response?
6. **`contributing_submission_ids` invariants**: Must `contributing_submission_ids` be non-empty and restricted to submissions behind the unresolved branches being resolved, or may a coordinator omit discarded erroneous submissions (or pass an empty list when keeping an existing prior resolution head)?
7. **`plot_id` mutability and field validation**: Can a later edit or coordinator resolution change a visit's `payload.plot_id` (e.g., correcting a mis-selected plot in the field), or is `plot_id` immutable once `visit_id` is created? Are there domain bounds `record-store` must enforce on `observation_date`, `observers` (e.g., non-empty), or `species_cover`?
8. **Error taxonomy**: Should the LLD define distinct error codes/shapes now for unauthenticated/unauthorized role access, nonexistent `visit_id`, `idempotency_key` payload mismatch, invalid `plot_id` / `base_revision_id`, and stale `superseded_revision_ids` on resolution?

---

### Cross-Node Status Note

`docs/high-level-design.md` (the `record-store` state cell `Drafted; concurrency choice open` and the "unresolved choice" note) and `docs/intent/site-catalog/site-catalog-design.md` ("pending that choice") still refer to this concurrency choice as open. I paused at the `record-store` boundary rather than editing them — let me know if you also want those status references updated once `record-store-design.md` is approved.