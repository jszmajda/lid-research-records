I have updated `docs/intent/record-store/record-store-design.md` around whole-visit revisions (and updated `docs/high-level-design.md` so `record-store` is no longer marked `concurrency choice open`, while keeping the concurrency decision itself inside `record-store`).

### Phase 2 Output — `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, submission history, and the meaning of a current visit when independently edited copies arrive from offline tablets. A visit is identified by a client-generated UUID (`visit_id`) and refers to a catalog plot UUID (`plot_id`). Edits can arrive days after their starting state was fetched, so server receipt order is never treated as evidence that one worker's observations are more authoritative.

`tablet-sync` and `review-export` consume the submission, retrieval, and review-resolution contracts defined here rather than defining concurrency semantics of their own.

## Revision Model

A visit's scientific payload contains `plot_id`, `observation_date`, `observers`, `species_cover` (species and cover estimate entries), and `notes`. Edits across fields can be scientifically coupled—such as revising a species identification alongside its cover estimate—in ways field names do not reveal. Each submission and resolution therefore operates on a complete whole-visit payload.

Persistence retains three immutable record kinds:

- **Worker submissions**: `submission_id`, `idempotency_key`, `visit_id`, `base_revision_id` (`null` for initial creation), `author_id`, `received_at`, and the original submitted `payload`.
- **Coordinator resolutions**: `resolution_id`, `idempotency_key`, `visit_id`, `coordinator_id`, `resolved_at`, `superseded_revision_ids`, `contributing_submission_ids`, optional `resolution_note`, and `resolved_payload`.
- **Revisions**: server-assigned `revision_id`, `visit_id`, whole-visit `payload`, `created_at`, `parent_revision_ids`, and an origin reference (`submission_id` or `resolution_id`).

A revision is an **active head** of its visit until another accepted revision lists it in `parent_revision_ids`:

- **Resolved (`has_unresolved_review: false`)**: the visit has exactly one active head revision, exposed as `current_revision`. Creating a new visit (`base_revision_id: null`) produces a single active head. Submitting an edit whose `base_revision_id` matches the visit's sole active head supersedes that head and advances `current_revision` without creating review work.
- **Unresolved (`has_unresolved_review: true`)**: the visit has two or more active head revisions. When an accepted edit names a `base_revision_id` that has already been superseded—whether by another worker's edit or a prior coordinator resolution—the new revision becomes an additional active head. `current_revision` is `null` and all active heads appear in `competing_revisions` until a coordinator resolves them. If a worker submits an edit based on one competing head before review completes, the new revision supersedes that head while leaving sibling competing heads active.

## Operations and Contracts

### Submission

Authenticated workers submit new visits and whole-visit edits through a single idempotent submission envelope:

| Field | Type | Rules |
|---|---|---|
| `idempotency_key` | string | Client-generated key unique per logical submission attempt |
| `visit_id` | UUID | Client-generated visit identifier |
| `base_revision_id` | UUID or null | `null` when creating a new visit; starting `revision_id` when editing an existing visit |
| `payload` | VisitPayload | Complete `plot_id`, `observation_date`, `observers`, `species_cover`, and `notes` |

Validation and acceptance rules:

1. Authenticate the submitting worker and record their authenticated identity as `author_id`.
2. **Idempotency**: if `idempotency_key` matches a previously accepted submission with an identical envelope (`visit_id`, `base_revision_id`, and `payload`), return the original acceptance result without creating another submission or revision. If `idempotency_key` was already accepted with different content, reject the request and leave stored records unchanged.
3. **Field and catalog validation**: validate field types and verify `plot_id` exists in `site-catalog` (active or archived, preserving offline captures made before a plot was archived and edits to historical visits).
4. **Lineage validation**: if `base_revision_id` is `null` and `visit_id` already exists, reject the submission. If `base_revision_id` is non-null, verify that it belongs to `visit_id`; otherwise reject the submission.
5. **Acceptance response**: return `submission_id`, assigned `revision_id`, `visit_id`, `has_unresolved_review`, `current_revision_id` (`revision_id` when resolved, `null` when unresolved), and `competing_revision_ids` (`[]` when resolved, or all active head IDs when unresolved).

### Current-State and Review-Queue Retrieval

Visit retrieval distinguishes settled visits from visits awaiting coordinator review:

| Field | Resolved Visit (`has_unresolved_review: false`) | Unresolved Visit (`has_unresolved_review: true`) |
|---|---|---|
| `visit_id` | UUID | UUID |
| `has_unresolved_review` | `false` | `true` |
| `current_revision` | Single active head revision (`revision_id`, `payload`, `created_at`, origin) | `null` |
| `competing_revisions` | `[]` | All active head revisions (`revision_id`, `parent_revision_ids`, `payload`, `created_at`, origin) |
| `base_revisions` | `[]` | Referenced parent/common-ancestor revision snapshots for comparison |

`competing_revisions` is ordered deterministically by `created_at` then `revision_id` for stable presentation only; order carries no authority. Review-queue listing returns all visits with `has_unresolved_review: true`, and export-eligible listing returns only visits with `has_unresolved_review: false`.

### History Retrieval

History retrieval for a `visit_id` returns the complete immutable set of worker submissions, coordinator resolutions, and revisions with their `parent_revision_ids` and origin links, keeping the path from every submitted observation to any resolved or exported value inspectable.

### Coordinator Resolution

Authenticated coordinators resolve competing revisions into a single successor revision:

| Field | Type | Rules |
|---|---|---|
| `idempotency_key` | string | Client-generated key following the same replay/mismatch rule as worker submissions |
| `visit_id` | UUID | Target visit with unresolved review work |
| `superseded_revision_ids` | UUID[] | Distinct revision IDs (at least two) matching the visit's full current active head set |
| `resolved_payload` | VisitPayload | Complete whole-visit payload selected from a competing head or reconciled across them |
| `resolution_note` | string or null | Optional coordinator explanation of how competing observations were reconciled |

Validation and outcome rules:

1. Authenticate the coordinator and record `coordinator_id`.
2. Apply idempotency checks on `idempotency_key`, then validate `resolved_payload` field types and `plot_id` existence.
3. Verify `superseded_revision_ids` contains distinct IDs matching the visit's full current active head set (requiring at least two active heads). If a new worker submission changed the active head set after the coordinator loaded the review, reject the resolution as stale so every competing head is reviewed together.
4. Derive `contributing_submission_ids` from the worker submissions along the competing branches since their lowest common ancestor revision, persist the immutable resolution record, and create a new single active head `revision_id` with `parent_revision_ids = superseded_revision_ids` and `payload = resolved_payload`.
5. Transition the visit to `has_unresolved_review: false` with `current_revision` set to the new revision, retain all original worker submissions intact, and return `resolution_id`, the new `revision_id`, and `contributing_submission_ids`.

## Downstream Contract Obligations

- **`tablet-sync`**: stores the `revision_id` of each synced visit locally, sends it as `base_revision_id` (`null` for newly created visits) with a persistent `idempotency_key` across retries, and distinguishes clean succession from `has_unresolved_review: true` outcomes when explaining sync status to field workers.
- **`review-export`**: renders whole-visit comparisons across `competing_revisions` and `base_revisions`, submits coordinator resolutions naming the full active head set, and excludes visits with `has_unresolved_review: true` from the Friday partner CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit reconciliation | Whole-visit revisions with coordinator resolution of competing heads | Field-aware three-way merge (auto-merge disjoint fields, review overlapping edits) | Scientific fields carry cross-field dependencies that field names do not expose, such as a revised species identification paired with its cover estimate. Automatic merging risks silently combining incompatible edits and requires maintained merge rules across scalars, observer lists, and species entries. Whole-visit revisions preserve each submitted visit intact at the cost of full-visit payloads and a larger coordinator review queue. |
| Representation while competing heads exist | `current_revision` is `null` and active heads appear in `competing_revisions` | Keep the earliest-arrived or latest-arrived revision as a provisional `current_revision` | Treating any competing head as current based on server receipt time privileges arrival order over offline workers and creates a trap where downstream consumers read an unreviewed winner. |
| Concurrent arrival during coordinator review | Reject resolution when `superseded_revision_ids` does not match the full active head set | Supersede only the named subset of heads and leave newly arrived heads competing with the resolution | Requiring the full active head set guarantees the coordinator sees all competing observations together rather than reconciling in blind stages when a tablet syncs mid-review. |
```

---

### Decision Recording Offer

Because whole-visit revisions vs. field-aware three-way merge trades two genuinely credible options across multiple criteria (coordinator review volume and payload size vs. merge-rule maintenance and silent cross-field scientific coupling) and sizes both `tablet-sync` and `review-export`—making it a choice a future maintainer might otherwise be tempted to revisit when disjoint-field reviews accumulate—would you like a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` linked from the table, or is the `Decisions & Alternatives` row above sufficient?

---

### Cross-Segment Cascade Note

- `docs/intent/site-catalog/site-catalog-design.md` (line 24) still contains a note saying *"Tablet-sync's visit submission and reconciliation behavior remains pending that choice."* Because `site-catalog` is a sibling segment, I left it untouched—let me know if you want me to clean up that sentence as well.

---

### Phase 2 LLD Edge-Case Probe (for Triage)

Please let me know which of these internal `record-store` edge cases you want specified in the LLD now vs. deferred to `Open Questions & Future Decisions` (and confirm whether you agree with the two auxiliary choices in `Decisions & Alternatives`—setting `current_revision: null` while unresolved and rejecting stale-head resolutions):

1. **`plot_id` mutability across revisions**: What happens if an edit or coordinator resolution for an existing `visit_id` supplies a different `plot_id` than the initial submission (e.g., fixing a wrong plot selected in the field vs. enforcing `plot_id` as immutable per visit)?
2. **Identical concurrent edits**: What happens when an offline edit against a superseded `base_revision_id` carries a `payload` identical to the current active head (e.g., two workers independently entered the exact same correction)? Should it still create competing heads for coordinator review, or coalesce without review?
3. **Structural `VisitPayload` invariants**: Without crossing the HLD non-goal against automated botanical validation, what structural constraints belong in `record-store`—e.g., non-empty `observers`, allowing empty `species_cover` (unvegetated plot), cover value bounds, duplicate species entries within `species_cover`, or future `observation_date`?
4. **Idempotency key scoping, replay snapshot, and rejected keys**: Is `idempotency_key` scoped per authenticated caller or globally across `record-store`? When an accepted request is replayed after later edits have changed the visit's head state, should replay return the stored point-in-time acceptance response or recompute current head status? May a key from a *rejected* request be reused?
5. **Envelope equality on idempotent replay**: Is "identical envelope" strict array-order equality on `observers`, `species_cover`, and `superseded_revision_ids`, or canonical/set equality?
6. **Multi-cycle conflict ancestry**: When a visit enters a second conflict after an earlier coordinator resolution (e.g., a long-offline tablet edits from pre-resolution `R1` while another edits from resolved `R4`), what exact snapshots belong in `base_revisions` (direct parent of each competing head plus lowest common ancestor(s)) and how should `contributing_submission_ids` traverse across intermediate resolutions?
7. **Role boundaries and self-resolution**: May coordinators also submit worker edits and resolve conflicts that include their own submissions (given the team has only two coordinators), and are retrieval/listing operations open to any authenticated worker or split between worker sync reads and coordinator-only review/export queries?
8. **Rejection error shapes and listing details**: Should `record-store` define explicit error categories (such as returning the updated active head set on a stale resolution rejection vs. lineage/idempotency/validation errors) and deterministic sort/pagination rules for History, Review-Queue, and Export-Eligible listings?

Once you review the LLD, answer the decision-doc question, and triage the items above, we will incorporate your feedback and proceed to **Phase 3** (`docs/intent/record-store/record-store-specs.md`).