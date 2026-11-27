I have updated `docs/intent/record-store/record-store-design.md` with the whole-visit revisions contract (Phase 2).

### Coherence Pre-Flight Notes
- `docs/high-level-design.md` (lines 18, 22) and `docs/intent/site-catalog/site-catalog-design.md` (line 24) still note the `record-store` concurrency choice as open. I left both untouched for now (`site-catalog` is a separate segment); let me know if you want the HLD status note updated once this LLD is approved.
- `docs/intent/record-store/record-store-specs.md` (`REC-001`–`REC-006`) is untouched and will be updated in Phase 3 after you approve the LLD.

---

### Updated LLD: `docs/intent/record-store/record-store-design.md`

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence, revision lineage, and the definition of a visit's current state when independently edited copies arrive. A visit is identified by a client-generated UUID and references a permanent plot UUID from `site-catalog`. Tablets can remain offline for up to 48 hours and submit edits days after fetching their starting state. Arrival order is never treated as evidence that one worker's observations are more authoritative.

A visit's scientific fields—observation date, observer list, species cover estimates, and notes—can be scientifically interdependent (for example, revising a species identification alongside its cover estimate). The server cannot infer all such relationships from field names alone, so each submission is preserved and evaluated as a whole visit. Every submitted edit is retained immutably so the path from any field observation to an exported value remains inspectable.

## Data Model and Revision Lineage

The store maintains an append-only revision log per visit alongside a lightweight visit summary pointing to the canonical revision and any unresolved competing revisions.

### Visit Summary

| Field | Type | Meaning |
|---|---|---|
| `visit_id` | UUID (client-generated) | Stable identifier for the plot visit |
| `plot_id` | UUID | Reference to a permanent plot in `site-catalog` |
| `current_revision_id` | UUID | Canonical revision representing the latest accepted state |
| `review_state` | `clean` or `unresolved` | Whether competing revisions await coordinator review |
| `pending_revision_ids` | list of UUIDs | Competing revisions awaiting resolution (empty when `clean`) |

### Immutable Revision

Every accepted worker submission and every coordinator resolution creates a new immutable revision record. Original submissions are never overwritten or deleted.

| Field | Type | Meaning |
|---|---|---|
| `revision_id` | UUID (server-assigned) | Unique identifier for this revision |
| `visit_id` | UUID | Parent visit |
| `kind` | `submission` or `resolution` | Distinguishes field worker submissions from coordinator resolutions |
| `base_revision_id` | UUID or `null` | Starting revision for a worker edit (`null` for initial visit creation and resolutions) |
| `resolved_revision_ids` | list of UUIDs | For `resolution` revisions, the revision IDs reconciled by this outcome (empty for `submission`) |
| `author_id` | string | Authenticated worker or coordinator identity |
| `received_at` | timestamp (UTC) | Server receipt time |
| `idempotency_key` | string | Client-supplied key for retry deduplication |
| `payload` | VisitPayload | Complete scientific record: `plot_id`, `observation_date`, `observers`, `species_cover_estimates`, `notes` |

## Submission Contract and Concurrency Policy

The store uses **whole-visit revisions** with optimistic base-revision tracking. Workers submit complete visit payloads naming the `base_revision_id` they edited from.

### Validation and Idempotency

Before creating a revision, the store authenticates the submitting worker, validates field types and structure, and checks that `plot_id` exists in `site-catalog`.

Each submission carries an `idempotency_key` scoped to the visit:
- Repeating an accepted `idempotency_key` with an identical `base_revision_id` and `payload` returns the original acceptance result without creating another revision.
- Repeating an accepted `idempotency_key` with a different `base_revision_id` or `payload` is rejected without modifying stored state.

### Submission Envelope

| Direction | Fields |
|---|---|
| Request | `visit_id`, `base_revision_id` (`null` for a new visit; required for edits), `idempotency_key`, `payload` |
| Response | `revision_id`, `visit_id`, `outcome` (`accepted_as_current` or `accepted_as_competing`), `review_state` (`clean` or `unresolved`), `current_revision_id`, `received_at` |

### Concurrency State Transitions

1. **Initial visit creation** (`visit_id` does not exist, `base_revision_id` is `null`): create the first `submission` revision, set `current_revision_id` to it, set `review_state` to `clean`, and return `accepted_as_current`.
2. **Fast-forward edit** (`visit_id` exists, `review_state` is `clean`, and `base_revision_id == current_revision_id`): create a `submission` revision, advance `current_revision_id` to it, keep `review_state` as `clean`, and return `accepted_as_current`.
3. **Competing edit** (`visit_id` exists, `base_revision_id` belongs to the visit, and either `base_revision_id != current_revision_id` or `review_state` is `unresolved`): create a `submission` revision preserving the full payload, leave `current_revision_id` unchanged, append the new `revision_id` to `pending_revision_ids`, set `review_state` to `unresolved`, and return `accepted_as_competing`.
4. **Invalid base reference**: if `visit_id` does not exist and `base_revision_id` is non-null, if `visit_id` already exists and `base_revision_id` is `null`, or if `base_revision_id` does not belong to `visit_id`, reject the submission.

Competing edits are always accepted and preserved intact; the server never silently discards or auto-merges them.

## Retrieval Contracts

### Current-State Retrieval

Callers retrieve a single visit by `visit_id` or query visits filtered by `review_state` (for example, all `clean` visits for export or all `unresolved` visits for the review queue).

Each visit response includes:
- `visit_id`, `plot_id`, and `review_state` (`clean` or `unresolved`)
- `current_revision`: full metadata and `payload` for `current_revision_id`
- `pending_revisions`: full metadata and `payload` for each revision in `pending_revision_ids` (empty when `clean`)

This lets callers distinguish export-ready state (`clean`) from unresolved review work (`unresolved`) without reconstructing lineage from history.

### Submission-History Retrieval

Given a `visit_id`, the store returns all immutable revisions ordered by `received_at`, including `revision_id`, `kind`, `base_revision_id`, `resolved_revision_ids`, `author_id`, `received_at`, and `payload`. This supports auditing and tracing any exported value back to its contributing submissions and coordinator resolutions.

## Coordinator Resolution

Coordinators resolve `unresolved` visits through an authenticated resolution operation.

### Resolution Envelope

| Direction | Fields |
|---|---|
| Request | `visit_id`, `idempotency_key`, `resolved_revision_ids`, and either `selected_revision_id` (adopt one existing revision's payload verbatim) or `payload` (a coordinator-authored complete visit payload) |
| Response | `revision_id`, `visit_id`, `review_state` (`clean`), `current_revision_id`, `resolved_revision_ids`, `received_at` |

### Resolution Rules

- The caller must be authenticated as a coordinator.
- The visit must currently be in `unresolved` state.
- `resolved_revision_ids` must include the visit's `current_revision_id` and every revision currently in `pending_revision_ids`. If another competing submission arrived after the coordinator loaded the visit, the request is rejected so the newly arrived edit cannot be closed out unseen.
- If `selected_revision_id` is provided, it must be in `resolved_revision_ids`, and its payload becomes the resolution's payload.
- On acceptance, the store appends a new `resolution` revision recording the coordinator's `author_id`, `received_at`, `resolved_revision_ids`, and resolved `payload`; advances `current_revision_id` to the new revision; clears `pending_revision_ids`; and sets `review_state` to `clean`.
- Idempotency follows the same key-matching rules as worker submissions.

## Downstream Obligations (Cascade Notes)

Implementing whole-visit revisions in `record-store` creates contract obligations for sibling nodes rather than shared ownership of concurrency semantics:

- **`tablet-sync`**: retain the `base_revision_id` of each cached visit, supply stable `idempotency_key` values across retries, submit complete visit payloads, and surface `accepted_as_competing` / `unresolved` outcomes to field workers.
- **`review-export`**: present a whole-visit revision comparison view over `current_revision` and `pending_revisions`, submit coordinator outcomes through the resolution operation, and exclude visits with `review_state == unresolved` from the Friday partner CSV export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edit policy | Whole-visit revisions with coordinator review | Field-aware three-way merge; Last-write-wins | Preserves each worker's visit as a scientifically coherent unit and avoids maintaining merge rules for scalar fields, observer lists, and species entries that could silently combine related edits (such as species ID and cover estimate). Last-write-wins violates the no-silent-discard tenet. At ~6,000 visits/season with two coordinators and no dedicated sysadmin, a larger review queue is preferable to maintaining merge rules or risking silent semantic errors. |
| Resolution lineage representation | Append a new immutable `resolution` revision referencing `resolved_revision_ids` | Promote/overwrite an existing revision in place | Keeps every original worker submission intact, handles both verbatim selection and coordinator-composed payloads uniformly, and records coordinator identity and contributing submission IDs for export provenance. |
| Resolution concurrency guard | Require `resolved_revision_ids` to cover `current_revision_id` and all current `pending_revision_ids` | Clear all pending revisions unconditionally on resolution | Prevents a coordinator from inadvertently closing out a competing submission that arrived while the review screen was open. |
| Idempotency key mismatch | Reject key reuse when `base_revision_id` or `payload` differs | Return original result ignoring payload; Overwrite original submission | Safe retries over flaky connections succeed without duplicating revisions, while client bugs that reuse a key for a new edit fail loudly instead of silently dropping data. |

## References

- `docs/high-level-design.md` — TidePlot system architecture and tenets
- `docs/intent/site-catalog/site-catalog-design.md` — Permanent plot UUIDs and catalog lookup contract
```

---

### Decision Doc Offer

The concurrency policy choice (whole-visit revisions vs. field-aware three-way merge) stays genuinely live for a cold reader: two credible options were traded across multiple criteria (review workload, submission size, merge-rule maintenance, and preserving cross-field scientific coherence), and both `tablet-sync` and `review-export` will be sized around it.

Would you like to record this choice as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the `Decisions & Alternatives` row), or keep it as the `Decisions & Alternatives` table row only?

---

### Phase 2 LLD Edge-Case Probe (Delegated Subagent Findings)

Please triage which of these internal `record-store` gaps to specify in the LLD now vs. defer as open questions:

1. **Changing `payload.plot_id` on an existing visit**: Is `plot_id` immutable after visit creation, or can edits/resolutions reassign it (and if mutable, how does `Visit Summary.plot_id` update while competing revisions are pending)?
2. **Archived plots**: `site-catalog` keeps archived plots resolvable. Should `record-store` accept or reject an archived `plot_id` on initial visit creation, edits to existing visits, and coordinator resolutions?
3. **`VisitPayload` validation and canonical equality**: What are the field constraints (empty `observers`/`species_cover_estimates`, duplicate species, cover-value bounds, date format, null `notes`), and does list ordering affect idempotency payload comparison?
4. **No-op edits**: What happens when a worker submits an edit whose `payload` is identical to `current_revision` (especially from a stale `base_revision_id`)—still append a revision / mark `unresolved`, or treat as a no-op?
5. **Chained edits off a pending revision**: When a worker submits an edit whose `base_revision_id` is already in `pending_revision_ids`, does it append alongside its parent in `pending_revision_ids` or supersede that pending entry?
6. **Idempotency key edge cases**:
   - Are keys scoped per `(visit_id, author_id, operation)` or strictly per `visit_id`?
   - Are rejected `idempotency_key`s re-evaluated on retry or cached as rejected?
   - On an idempotent retry of an already-accepted resolution, does idempotency short-circuit *before* the `visit must be unresolved` check?
7. **Resolution input edge cases**: What happens if a resolution supplies both or neither of `selected_revision_id` and `payload`, or passes extra/duplicate IDs in `resolved_revision_ids` beyond `{current_revision_id} ∪ pending_revision_ids` (exact set match vs. superset)?
8. **Concurrent write serialization**: What per-visit concurrency/locking guarantee linearizes simultaneous initial creations (same `visit_id`, different keys), simultaneous fast-forward edits from the same base, and a simultaneous worker edit + coordinator resolution?
9. **Ordering and pagination**: What tie-breaker orders revisions with identical `received_at`, what orders `pending_revisions`, and do `review_state` queries need pagination/ordering?
10. **Error shapes**: Should the LLD define structured error categories/codes to distinguish permanent validation errors from refreshable concurrency conflicts (e.g., stale `resolved_revision_ids`)?

---

**Phase 2 stop — waiting for your review:**
1. Any changes to `record-store-design.md`?
2. Standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, or keep the `Decisions & Alternatives` row only?
3. Which edge-case probe items (1–10) should be specified in the LLD vs. deferred?
4. Should we also update the HLD's "concurrency choice open" status lines once this LLD is settled, before moving to Phase 3 (EARS specs)?