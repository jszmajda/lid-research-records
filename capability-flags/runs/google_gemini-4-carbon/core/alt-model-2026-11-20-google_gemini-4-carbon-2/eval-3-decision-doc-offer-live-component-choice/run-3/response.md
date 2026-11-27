`docs/intent/record-store/record-store-design.md` has been updated for Phase 2 (LLD) around whole-visit revisions. Here is the full updated design, followed by a decision-doc offer, the LLD-level edge-case probe for triage, and cross-node cascade notes before we move to Phase 3 (`record-store-specs.md`).

---

### Updated LLD: `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns server-side persistence of plot-visit records, their revision lineage, and the meaning of a current visit when independently edited copies arrive. Each visit is identified by a client-generated `visit_id` (UUID) and references a `plot_id` (UUID) from `site-catalog`. Updates can arrive 48 hours or more after their starting state was fetched; server arrival order reflects tablet connectivity rather than observational authority.

A visit's scientific fields — observation date, observer list, species cover estimates, and notes — form a coupled observation record. Revising a species identification often accompanies a revised cover estimate or explanatory note, and field names alone do not reveal whether two edits are scientifically independent. Each submission is therefore stored and evaluated as a complete whole-visit revision. `tablet-sync` and `review-export` build on this node's revision, review-queue, and lineage contracts.

## Whole-Visit Revision Model

Every accepted write to a visit — whether a field worker's submission or a coordinator's resolution — creates an immutable revision with a server-assigned `revision_id` (UUID) and server receipt timestamp (`received_at`). Revisions form a per-visit directed acyclic graph:

- **Initial visit submission** (`base_revision_id: null`): records the worker submission (`submission_id`, `author_id`, `received_at`, and submitted payload) and creates the root revision for a new `visit_id`.
- **Subsequent worker submission** (`base_revision_id: <revision_id>`): records the worker submission (`submission_id`, `author_id`, `received_at`, and submitted payload) and creates a child revision linked to the single revision the worker edited.
- **Coordinator resolution** (`contributing_revision_ids: [<revision_id>, ...]`): creates a resolution revision that supersedes two or more competing revisions, recording `coordinator_id`, `received_at`, `contributing_revision_ids`, the underlying `contributing_submission_ids`, an optional `resolution_note`, and the resolved whole-visit payload.

A **tip revision** is any revision of a visit not referenced by a later accepted revision's `base_revision_id` or `contributing_revision_ids`. A visit's review state derives directly from its active tip revisions:

| Review Status | Tip Condition | `current_revision` | Meaning |
|---|---|---|---|
| `resolved` | Exactly 1 tip revision | That sole tip revision | Authoritative current state; eligible for partner CSV export |
| `needs_review` | 2 or more tip revisions | `null` | Competing revisions await coordinator resolution; excluded from export |

State transitions follow directly from lineage:

1. **Create**: Accepting a root revision for a new `visit_id` produces one tip (`resolved`).
2. **Linear edit**: Accepting a worker submission whose `base_revision_id` is the sole active tip supersedes that tip with the new revision (`resolved`).
3. **Concurrent edit**: Accepting a worker submission whose `base_revision_id` has already been superseded leaves the existing tip(s) intact and adds a new tip, placing or keeping the visit in `needs_review` with `current_revision: null`.
4. **Branch follow-up**: Accepting a worker submission whose `base_revision_id` is one of several active competing tips supersedes only that branch's tip; sibling tips remain active and the visit stays `needs_review`.
5. **Coordinator resolution**: Accepting a resolution naming the visit's exact set of active competing tips supersedes all of them with a single resolution tip, returning the visit to `resolved`.
6. **Late offline edit after resolution**: Accepting a delayed offline submission based on a revision older than a completed resolution adds a second tip alongside the resolution tip, returning the visit to `needs_review` so neither the resolution nor the late submission is lost.

## Operations and Envelopes

### Visit Payload

Every worker submission and coordinator resolution carries a complete visit payload:

| Field | Type | Constraints |
|---|---|---|
| `plot_id` | UUID | Must resolve to an existing plot in `site-catalog` (active or archived) |
| `observation_date` | ISO-8601 date (`YYYY-MM-DD`) | Required calendar date |
| `observers` | `string[]` | Non-empty list of observer names |
| `species_cover` | `array` | List of species observations, each pairing a species reference with a cover estimate |
| `notes` | `string` or `null` | Optional field notes |

The store validates field types, structural constraints, and `plot_id` existence in `site-catalog` before accepting a write. Archived plots remain valid targets so offline captures made before archival and corrections to historical visits are accepted. The store performs structural validation only, not botanical validation.

### Worker Submission

**Request envelope**:
- `idempotency_key`: client-generated key unique per submission attempt
- `visit_id`: client-generated UUID
- `base_revision_id`: `UUID | null` (`null` for initial creation of `visit_id`; otherwise an existing revision of `visit_id`)
- `payload`: complete `VisitPayload`
- Authenticated worker context supplies `author_id`.

**Idempotency and validation**:
- Repeating an accepted `idempotency_key` with an identical request envelope returns the original acceptance response without creating another stored submission or revision.
- Repeating an accepted `idempotency_key` with a different request envelope is rejected with conflict, leaving stored submissions and revisions unchanged.
- Unknown `plot_id` values, structurally invalid payloads, or a non-null `base_revision_id` that does not belong to `visit_id` are rejected.

**Acceptance response**:
- `submission_id`, `revision_id`, `visit_id`, `received_at`, `review_status` (`resolved` | `needs_review`), and `current_revision_id` (`revision_id` when `resolved`, `null` when `needs_review`).

### Retrieval and Unresolved-Work Queries

| Operation | Purpose | Returned Shape |
|---|---|---|
| Get visit (`visit_id`) | Fetch current state or conflict state for a single visit | `visit_id`, `review_status`, `current_revision` (populated when `resolved`, `null` when `needs_review`), and `competing_revisions` (empty when `resolved`, active tip revisions when `needs_review`) |
| List visits (sync / export feed) | Enumerate visits filtered by `review_status` or update cursor | Collection of visit records using the same `resolved` / `needs_review` state distinction |
| List unresolved review work | Drive the coordinator review queue | All `needs_review` visits, each with its active `competing_revisions` and the referenced `base_revisions` needed to compare each competing tip against its starting state |
| Get visit history (`visit_id`) | Inspect full provenance from submitted observations to current state | Complete revision and submission lineage for `visit_id`, including original worker payloads, `author_id` / `coordinator_id`, `received_at`, `base_revision_id`, `contributing_revision_ids`, `contributing_submission_ids`, and `resolution_note` |

### Coordinator Resolution

**Request envelope**:
- `idempotency_key`: client-generated key unique per resolution attempt
- `visit_id`: UUID of the visit under review
- `contributing_revision_ids`: exact set of active competing tip `revision_id`s reviewed by the coordinator (minimum two)
- `payload`: complete resolved `VisitPayload` (selected from a competing revision or synthesized by the coordinator)
- `resolution_note`: `string | null` optional explanation of the resolution
- Authenticated coordinator context supplies `coordinator_id`.

**Concurrency guard and idempotency**:
- Repeating an accepted `idempotency_key` with an identical resolution envelope returns the original resolution response; reusing it with a different envelope is rejected.
- The visit must currently be in `needs_review`, and its active tip set must equal `contributing_revision_ids` exactly. If another worker submission arrived or another coordinator already resolved the visit, the request is rejected with conflict and returns the current active tips so no newly arrived edit or sibling resolution is overwritten.
- When accepted, the store records `coordinator_id`, `contributing_revision_ids`, and all underlying `contributing_submission_ids` on the new resolution revision, transitions the visit to `resolved`, and sets `current_revision` to that revision while keeping every prior submission and revision intact.

**Acceptance response**:
- `revision_id`, `visit_id`, `received_at`, `review_status` (`resolved`), `current_revision_id` (`revision_id`), `contributing_revision_ids`, and `contributing_submission_ids`.

## Downstream Contracts

- **`tablet-sync`**: Retains the `revision_id` of the server revision a local draft starts from and submits it as `base_revision_id` (`null` for a newly created visit) with a stable per-attempt `idempotency_key`. When fetching a visit in `needs_review`, presents the visit as awaiting coordinator review with its competing revisions rather than treating any competing tip as settled current state.
- **`review-export`**: Renders `needs_review` visits in a coordinator comparison view backed by `competing_revisions` and `base_revisions`, submits coordinator resolutions naming the exact `contributing_revision_ids` reviewed, and restricts the reviewed CSV export to visits in `resolved` status using `current_revision`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with coordinator resolution of competing edits | Field-aware three-way merge (auto-merge disjoint fields, review overlapping fields); last-write-wins by receipt or device timestamp | Visit fields carry unmodeled scientific couplings (such as revising a species identification alongside its cover estimate and notes) that structural merge rules can combine into invalid observations without warning. Accepting a larger coordinator review queue avoids maintaining per-field merge rules, while last-write-wins violates the high-level design tenet against silently discarding submitted edits. |
| Current state while competing revisions exist | Set `review_status: needs_review` and `current_revision: null` until a coordinator resolves the conflict | Keep the earliest-arriving competing revision as `current_revision` pending review | Offline tablets sync up to 48+ hours out of capture order; keeping the first arrival as `current_revision` treats network arrival order as authority and risks exposing an unreviewed conflict side to downstream consumers. |
| Coordinator resolution representation | Append a new immutable resolution revision carrying a complete `VisitPayload` and linking `contributing_revision_ids` and `contributing_submission_ids` | Pointer-only selection of one existing competing revision; in-place mutation of a winning submission | Competing edits frequently contain compatible fixes to different fields (for example, an observer spelling correction in one and a cover correction in another); a complete resolved payload lets coordinators keep both edits without automatic merge rules while preserving original worker payloads and full lineage. |

## References

- High-level design: `docs/high-level-design.md`
- Site catalog LLD: `docs/intent/site-catalog/site-catalog-design.md`
- Record store EARS specs: `docs/intent/record-store/record-store-specs.md`
```

---

### Decision Doc Offer

Because both whole-visit revisions and field-aware three-way merge remain credible options traded across multiple criteria (coordinator review load, merge-rule maintenance, scientific cross-field coherence, and payload size) and both `tablet-sync` and `review-export` will be sized around this choice, a future cold reader could plausibly re-litigate it.

- **Option A**: Write a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and link it from the `Decisions & Alternatives` row.
- **Option B**: Keep the `Decisions & Alternatives` row in `record-store-design.md` on its own.

Which do you prefer?

---

### Phase 2 LLD Edge-Case Probe (`record-store` Internal)

Please let me know which of these gaps you want settled directly in `record-store-design.md` now versus deferred under `Open Questions & Future Decisions`:

1. **`base_revision_id: null` on an existing `visit_id`**: What happens when a submission with a new `idempotency_key` sends `base_revision_id: null` for a `visit_id` that already exists — reject with conflict (enforcing a single root per UUID), or accept as a second root tip (`needs_review`)?
2. **Changing `plot_id` on an existing visit**: What happens when a subsequent edit or resolution supplies a valid `plot_id` different from the root revision's `plot_id` — allow re-homing a mis-logged visit (leaving `needs_review` visits without a single `plot_id` until resolved), or treat `plot_id` as immutable per `visit_id`?
3. **`base_revisions` in `List unresolved review work`**: When a conflict involves a multi-edit worker branch (Transition 4) or a late offline edit competing against an earlier coordinator resolution (Transition 6, which has `contributing_revision_ids` rather than a single `base_revision_id`), should `base_revisions` return each tip's immediate parent(s), the lowest common ancestor(s) where the active tips diverged, or the unmerged ancestor chain back to the divergence point?
4. **Scope of `contributing_submission_ids` on a resolution**: When a coordinator resolves multi-step branches or a post-resolution conflict (Transition 6), should `contributing_submission_ids` record every worker `submission_id` along the superseded branches since divergence (plus transitive submissions from any superseded resolution), or only the direct tip submissions?
5. **Idempotency key scoping and drifted `review_status`**: On shared tablets, is `idempotency_key` scoped globally (including `author_id` in envelope equality so a different signed-in user cannot collide silently), and if a retry arrives after another worker's edit flipped the visit to `needs_review`, does the replay return the original point-in-time acceptance snapshot or the visit's current `review_status`?
6. **Incremental cursor + `review_status` regression**: When a consumer polls `List visits` with an update cursor, what happens when a previously `resolved` visit transitions back to `needs_review` (Transitions 3 or 6) — should cursor feeds be monotonic over all state changes without status filtering so incremental callers always observe demotions?
7. **`species_cover` and scalar structural bounds**: Should the LLD fix the exact shape of a `species_cover` entry (e.g., species code/name + numeric percentage vs. cover-class code, whether `species_cover: []` is valid for bare plots, and duplicate-species / blank-observer rules) now, or defer exact field bounds?

---

### Cross-Node Cascade Notes

- **Sibling LLDs (`tablet-sync`, `review-export`)**: Downstream obligations are recorded in `record-store-design.md § Downstream Contracts`; per your plan and segment boundaries, we will hold off drafting those nodes until `record-store` completes.
- **Stale status prose in `docs/high-level-design.md` and `docs/intent/site-catalog/site-catalog-design.md`**: Both still refer to `record-store`'s concurrency choice as open/pending (`high-level-design.md` Architecture table + line 22; `site-catalog-design.md` line 24). Left untouched for now — let me know if you want those updated once `record-store-design.md` is approved.

How would you like to handle the decision doc offer and probe items 1–7, and do you approve moving to Phase 3 (updating `record-store-specs.md`) once any adjustments are applied?