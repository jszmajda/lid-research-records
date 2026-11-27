### Coherence Pre-Flight & Boundary Notes

- **Pre-flight (`REC`)**: Existing `REC-001`–`REC-006` in `docs/intent/record-store/record-store-specs.md` trace cleanly to `record-store` (no tests or code exist yet); EARS updates wait for Phase 3 after you approve this LLD.
- **HLD status sync**: Updated `docs/high-level-design.md` (`State` column from `Drafted; concurrency choice open` to `Drafted`, and prose from `unresolved choice` to `record-store's concurrency contract`) while keeping the concurrency decision owned by `record-store`.
- **Sibling segment flag (`site-catalog`)**: `docs/intent/site-catalog/site-catalog-design.md` (line 24) still says *"Tablet-sync's visit submission and reconciliation behavior remains pending that choice."* Because `site-catalog` is a separate segment (`CAT`), I left it untouched—let me know if you want that line updated too.

---

### Decision Recording Offer

I recorded the whole-visit revisions choice in `record-store-design.md`'s **Decisions & Alternatives** table. Because both whole-visit revisions and field-aware three-way merge remain credible options traded across multiple criteria (coordinator queue volume and submission size vs. merge-rule maintenance and silent cross-field scientific coupling) and both `tablet-sync` and `review-export` will be sized around this contract, would you like a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` linked from that row, or is the **Decisions & Alternatives** table row sufficient?

---

### Phase 2 Output: `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence, revision lineage, and the meaning of a current visit when independently edited copies arrive. Each visit is identified by a client-generated UUID (`visit_id`) and references a catalog plot UUID (`plot_id`). Because shared field tablets can remain offline for 48 hours or more, edits often arrive days after their starting state was fetched. Server arrival order does not establish which worker's observations are authoritative.

Scientific fields within a visit—plot reference, observation date, observer list, species cover estimates, and notes—can depend on one another in ways field names do not reveal, such as revising a species identification alongside its cover estimate and field note. The record store therefore treats each submission as an indivisible whole-visit revision. Concurrent edits against the same prior state become competing whole-visit revisions that a coordinator resolves explicitly.

## Revision Model and Visit States

Persistence separates immutable source records from the revision graph that tracks lineage:

- **Worker submissions** store `submission_id`, `idempotency_key`, `visit_id`, `base_revision_id` (`null` for initial creation), `author_id`, `received_at` (server receipt timestamp), and the submitted whole-visit `payload`.
- **Coordinator resolutions** store `resolution_id`, `idempotency_key`, `visit_id`, `coordinator_id`, `resolved_at` (server timestamp), `resolved_revision_ids`, `contributing_submission_ids`, an optional `resolution_note`, and the approved whole-visit `payload`. Original worker submissions remain unchanged and separately addressable.
- **Revisions** form a per-visit directed acyclic graph. Every accepted worker submission or coordinator resolution creates one immutable revision (`revision_id`, `visit_id`, `parent_revision_ids`, `source_type` of `worker_submission` or `coordinator_resolution`, `source_id`, `created_at`, and `payload`).

A revision is an **active head** of its visit while `revision_id` does not appear in any later revision's `parent_revision_ids`. A visit's state derives directly from its active heads:

- `resolved` — Exactly one active head revision exists. That revision is the visit's usable current state.
  - **Initial creation**: Accepting a submission with `base_revision_id: null` for a new `visit_id` creates the initial revision (`parent_revision_ids: []`) as sole head; the visit is `resolved`.
  - **Linear update**: When a visit is `resolved` at head `R` and an accepted submission names `base_revision_id: R`, the new revision (`parent_revision_ids: [R]`) supersedes `R` as sole head; the visit remains `resolved`.
- `needs_review` — Two or more active head revisions exist (competing revisions). No single authoritative current state exists until a coordinator resolves them.
  - **Concurrent branch from a superseded revision**: When an accepted submission names an existing `base_revision_id` of `visit_id` that is already superseded, the new revision attaches to `base_revision_id` without superseding the existing active head(s). The visit transitions to (or remains in) `needs_review`.
  - **Follow-up edit on one competing branch**: When a visit is `needs_review` and an accepted submission names one of the active heads `H_i` as `base_revision_id`, the new revision supersedes `H_i` while the other active head(s) remain un-superseded; the visit stays `needs_review`.
  - **Coordinator resolution**: Accepting a resolution that names all current active heads `[H_1, ..., H_n]` creates a single revision with `parent_revision_ids: [H_1, ..., H_n]`, superseding all competing heads and returning the visit to `resolved`.

## Operations and Contracts

| Operation | Caller | Purpose |
|---|---|---|
| `SubmitVisitRevision` | Authenticated worker | Submit a new visit or whole-visit edit against `base_revision_id` |
| `GetVisitCurrentState` / `ListVisits` | Authenticated worker, coordinator | Retrieve current state and whether unresolved review work exists |
| `ListUnresolvedVisits` / `GetVisitReviewDetail` | Coordinator | List `needs_review` visits and retrieve competing revisions with base snapshots |
| `ResolveVisitRevisions` | Coordinator | Resolve active competing head revisions into a single `resolved` revision |
| `GetVisitHistory` | Authenticated worker, coordinator | Inspect original submissions, coordinator resolutions, and full revision lineage |

### Submission Envelope (`SubmitVisitRevision`)

Request fields:
- `idempotency_key`: client-generated token unique to the logical submission attempt
- `visit_id`: client-generated UUID
- `base_revision_id`: `null` when creating a visit, or the `revision_id` the edit started from
- `payload`: whole-visit record containing `plot_id` (UUID), `observation_date` (ISO 8601 calendar date), `observers` (non-empty list of observer entries), `species_cover` (list of species and cover estimate entries), and `notes` (string)

Authenticated caller identity provides `author_id`.

Validation and idempotency rules:
1. **Authentication**: Unauthenticated requests are rejected before validation or persistence.
2. **Idempotency**: Repeating an accepted `idempotency_key` with an identical `(visit_id, base_revision_id, payload)` returns the original acceptance response without storing another submission or revision. Reusing an accepted `idempotency_key` with a different `visit_id`, `base_revision_id`, or `payload` is rejected as an idempotency conflict, leaving the original submission unchanged.
3. **Payload and plot reference**: Field types and structure are validated. `plot_id` must match an existing plot UUID in `site-catalog`; both `active` and `archived` plots are accepted so edits captured before plot archival or corrections to older visits are preserved, while unknown UUIDs are rejected.
4. **Base lineage**: A non-null `base_revision_id` must exist and belong to `visit_id`; references to unknown revisions or revisions of another visit are rejected.

Acceptance response:
- `submission_id`, `revision_id`, `received_at`, `visit_status` (`resolved` | `needs_review`), and `head_revision_ids`

### Current-State Response (`GetVisitCurrentState` / `ListVisits`)

Each visit summary or detail response carries:
- `visit_id`
- `visit_status`: `resolved` | `needs_review`
- `has_unresolved_review`: `false` when `resolved`, `true` when `needs_review`
- `current_revision`: when `resolved`, `{ revision_id, payload, created_at, source_type, source_id }`; when `needs_review`, `null`
- `head_revision_ids`: single-element list when `resolved`; all active competing head IDs when `needs_review`

Setting `current_revision` to `null` whenever `has_unresolved_review` is `true` prevents callers from accidentally exporting or displaying one competing revision as settled truth.

### Unresolved-Work Representation (`ListUnresolvedVisits` / `GetVisitReviewDetail`)

`ListUnresolvedVisits` returns all visits currently in `needs_review` with `visit_id`, active `head_revision_ids`, branch count, and earliest/latest competing receipt times for queue ordering.

`GetVisitReviewDetail` returns everything needed to compare competing branches without client-side graph traversal:
- `visit_id`
- `competing_revisions`: full records for each active head revision (`revision_id`, `parent_revision_ids`, `source_type`, `source_id`, `author_id` or `coordinator_id`, timestamp, and `payload`)
- `base_revisions`: immutable snapshots (`revision_id`, timestamp, `payload`) for each competing head's direct `parent_revision_ids` and their lowest common ancestor revision (when one exists), allowing side-by-side comparison of what each branch changed relative to the state its author saw
- `contributing_submission_ids`: all worker `submission_id`s along the competing branches since divergence

### Coordinator Resolution (`ResolveVisitRevisions`) and History (`GetVisitHistory`)

`ResolveVisitRevisions` requires an authenticated coordinator (`coordinator_id`) and accepts:
- `idempotency_key`: client-generated token for safe retry
- `visit_id`: target visit UUID
- `resolved_revision_ids`: the exact set of active competing `revision_id`s reviewed (at least two)
- `payload`: approved whole-visit record (either matching one competing revision or manually synthesized by the coordinator after reviewing the branches), validated under the same schema and catalog plot rules as worker submissions
- `resolution_note`: optional coordinator note explaining the resolution

Optimistic concurrency guard: `resolved_revision_ids` must equal the visit's current `head_revision_ids` set. If a tablet submits an additional edit while the coordinator is reviewing, the active head set changes and `ResolveVisitRevisions` rejects the request as a stale head-set conflict, returning the updated competing heads so no newly arrived submission is silently superseded. Repeating an accepted resolution `idempotency_key` with identical inputs returns the original resolution response; reusing it with different inputs is rejected.

On acceptance, the store computes `contributing_submission_ids` across the resolved branches (retaining every worker `submission_id` introduced since divergence alongside any directly selected submission), persists the resolution record, creates the new single head `revision_id`, and returns `resolution_id`, `revision_id`, `resolved_at`, `visit_status: resolved`, and `contributing_submission_ids`.

`GetVisitHistory` returns all stored worker submissions, coordinator resolutions, and revision nodes for `visit_id` in causal/receipt order so any current or exported value can be traced back to the exact submissions and coordinator decisions that produced it.

## Downstream Contracts

Sibling nodes build on this contract rather than defining independent concurrency rules:

- **tablet-sync**: Persist the server's `revision_id` with each synced visit and pass it as `base_revision_id` (`null` for new offline visits) alongside a whole-visit payload and stable per-edit `idempotency_key`. Surface `needs_review` outcomes to workers when a submission creates or joins competing revisions, and define local editing behavior when a visit retrieved from the server is in `needs_review`.
- **review-export**: Present `competing_revisions` against `base_revisions` for coordinator comparison, submit `ResolveVisitRevisions` with `resolved_revision_ids`, exclude visits with `has_unresolved_review: true` from the Friday partner CSV, and link exported rows to their `current_revision` for auditability.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with explicit coordinator resolution of competing heads | Field-aware three-way merge; last-write-wins by receipt or device timestamp | Scientific fields within a visit can be coupled without structural markers (for example, changing a species identification together with its cover estimate and notes). Whole-visit revisions avoid maintaining field and species-list merge rules that could silently combine scientifically incompatible edits, trading a larger coordinator review queue for preservation of whole-visit intent. Last-write-wins violates the tenet against silently discarding submitted edits. |
| Submission storage vs. current state | Separate immutable submission and resolution records linked by an append-only revision DAG | Mutating a single current-visit record in place with an audit log table | Offline tablets can submit edits anchored to any historical `revision_id`, including revisions superseded before an earlier coordinator resolution. Retaining every revision snapshot lets the store detect late concurrent branches, supply exact base snapshots for review, and keep the path from submitted observations to exported values inspectable. |
| Plot reference validation for archived plots | Accept both `active` and `archived` catalog plot UUIDs; reject unknown UUIDs | Reject submissions referencing `archived` plots | A plot can be archived while a tablet is offline or when a worker corrects an older visit. Accepting known archived plot UUIDs preserves valid field edits while `site-catalog` and `tablet-sync` keep archived plots out of the default new-visit picker. |

## Open Questions & Future Decisions

### Deferred
1. Pagination and filtering parameters for `ListVisits` and `ListUnresolvedVisits` (6,000 visits/season fits modest page sizes; exact query cursors can be finalized alongside `tablet-sync` and `review-export`).

## References

- High-level design: `docs/high-level-design.md`
- Site catalog contract: `docs/intent/site-catalog/site-catalog-design.md`
- Record store EARS specs: `docs/intent/record-store/record-store-specs.md`
```

---

### Phase 2 LLD Edge-Case Probe (Triage: Fix in LLD Now vs. Defer)

A delegated blind probe against `record-store-design.md` surfaced these internal gaps and potential readings. Let me know which ones to tighten in the LLD now versus park under **Open Questions & Future Decisions**:

1. **Duplicate `base_revision_id: null` for an existing `visit_id`**: If a non-idempotent submission arrives with `base_revision_id: null` for a `visit_id` that already exists, should `record-store` reject it as an already-exists conflict (enforcing a single root per UUID), or accept it as a competing root revision (`needs_review`)?
2. **`base_revisions` and `contributing_submission_ids` after a prior coordinator resolution**: Suppose branches `B1` and `B2` are resolved into `M`, and a late tablet later submits `B3` anchored to an ancestor before `B1`/`B2` diverged (active heads `[M, B3]`):
   - Should `contributing_submission_ids` for the second resolution stop at `M` (recording `B3`'s worker submissions while `M` already carries its own provenance), or re-collect `B1`/`B2` worker submissions back to the pre-`M` ancestor?
   - When 3+ branches or post-resolution diamonds have multiple maximal common ancestors rather than one unique LCA, should `base_revisions` include all maximal common ancestors plus each head's direct parents?
3. **Identical-payload concurrent submissions**: If two workers independently submit byte-identical whole-visit payloads from the same `base_revision_id` (or a worker submits a payload identical to `base_revision_id`), should the store still record both immutable submissions and route concurrent heads through `needs_review`, or auto-coalesce identical payloads?
4. **Idempotency scope, rejected requests, and replay snapshot**:
   - Should `idempotency_key` be scoped per authenticated caller + operation (rejecting cross-actor reuse) or globally?
   - If a request fails validation or a stale head-set check, is that `idempotency_key` free to retry or bound to the rejection?
   - When replaying an accepted `idempotency_key` after later edits have advanced the visit, should the response return the original frozen `(visit_status, head_revision_ids)` or the visit's current status/heads alongside the original `(submission_id, revision_id, received_at)`?
5. **Per-visit write serialization & concurrent coordinator resolution**: Should the LLD state explicitly that writes per `visit_id` are serialized, and specify the exact error shape when Coordinator B calls `ResolveVisitRevisions` after Coordinator A already resolved the visit back to a single `resolved` head?
6. **Role overlap (`coordinator` submitting visits) and error shapes**: Can coordinators also call `SubmitVisitRevision` when doing field work, and should the LLD enumerate standard error categories (`unauthenticated`, `forbidden`, `not_found`, `validation_error`, `idempotency_conflict`, `stale_heads`) across all operations (including calling `GetVisitReviewDetail` on a `resolved` visit)?
7. **Changing `plot_id` on an existing visit & scientific field bounds**: Is correcting `plot_id` on an existing `visit_id` allowed (if a worker selected the wrong plot in the field), and should `record-store` fix exact bounds for `species_cover` (e.g., empty list allowed for bare plots, cover range/units, duplicate species handling) now or defer field-level schema details?
8. **Deterministic ordering for `ListUnresolvedVisits` and `GetVisitHistory`**: How should queue receipt times be defined when one competing head is a prior `coordinator_resolution` (`resolved_at`) or a multi-edit branch, and what tie-breaker orders `GetVisitHistory` when concurrent timestamps match?

Please share your feedback on the LLD, your triage on items 1–8, and whether you want the standalone decision doc or just the table row—once approved, I'll proceed to Phase 3 (`record-store-specs.md`).