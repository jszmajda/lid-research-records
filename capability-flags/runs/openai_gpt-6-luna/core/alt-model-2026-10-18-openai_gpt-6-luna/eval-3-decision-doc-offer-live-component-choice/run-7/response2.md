## Phase 2 — Record-store LLD draft

The draft records the whole-visit revision policy, why field-aware merging remains a credible option, and the obligations it creates for tablet-sync and review-export.

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

The record store owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a stable catalog plot ID. Updates may arrive days after their starting state was fetched, and arrival order does not make one worker's observations more authoritative.

The store preserves each accepted visit submission as a complete, immutable revision. A submission based on the current revision may advance the current visit when no review is outstanding. A submission based on an older revision is retained as a competing revision for coordinator review; it does not replace the current revision. This keeps submitted scientific observations intact and makes divergence visible rather than inferring which fields can safely be combined.

The trade-off is a larger review queue: unrelated changes can create competing revisions just as related scientific edits do. Field-aware three-way merge remains a credible alternative because it can advance visits with disjoint changes and reduce review work. It is not selected because field relationships are not reliably captured by the schema: individually mergeable edits can be scientifically related, and combining them automatically could produce a visit no worker submitted. The merge approach would also require durable base snapshots, structured field changes, maintained merge rules, and field-level provenance. Whole-visit revisions instead require tablets to track base revision IDs and review/export to compare complete revisions and exclude unresolved visits from CSV output.

## Revision Model

Each accepted submission creates one immutable revision containing:

| Field | Meaning |
|---|---|
| `visitId` | Stable UUID identifying the visit across revisions |
| `revisionId` | Server-assigned immutable identifier for this accepted revision |
| `baseRevisionId` | Revision from which the submitting worker edited; absent only for initial visit creation |
| `payload` | Complete submitted visit, including plot ID, observation date, observer list, species cover estimates, and notes |
| `authorId` | Authenticated worker who submitted the revision |
| `receivedAt` | Server receipt time |
| `idempotencyKey` | Key used to recognize retries of this submission |

The visit record points to a current revision and tracks any unresolved competing revisions. Revision payloads and receipt metadata are append-only. Review outcomes are recorded separately from the submissions they resolve, preserving the original evidence and the history of decisions.

## Submission and Concurrency

An authenticated submission is validated for field types, required values, and a resolvable plot reference before it is accepted. A new visit has no base revision. Every update names the revision on which its complete payload is based.

The store serializes acceptance decisions per visit:

1. A valid initial submission for an unused visit ID creates the visit and its current revision. A later submission without a base revision cannot create another initial revision for that ID.
2. If an update's base revision is the current revision and the visit has no unresolved review work, the store appends the revision and advances the current pointer to it.
3. If an update's base revision is no longer current, the store appends the complete revision as unresolved review work and leaves the current pointer unchanged.
4. An unknown base revision, a base belonging to another visit, or an update without a base is rejected without changing stored revisions.

A retry with an accepted idempotency key and identical payload returns the original acceptance result. Reusing that key with a different payload is rejected. A successfully accepted submission is never overwritten by a later revision or resolution.

## Retrieval and Review Resolution

Visit retrieval identifies the current revision and whether unresolved review work exists. Submission-history retrieval returns the immutable revisions with their base revision IDs, authors, receipt times, and review status so callers can distinguish the current version from competing submissions.

The store records a coordinator's identity, the competing revision IDs considered, and the resolution outcome. A resolution establishes the revision that becomes current and closes the unresolved review work it addresses. Exact resolution semantics—including whether a coordinator may select only an existing whole revision or create a new complete resolution revision—are listed under Open Questions & Future Decisions.

## Downstream Contract Obligations

### Tablet-sync

Tablet-sync must retain the base revision ID associated with each local edit and submit a complete visit payload with that base and an idempotency key. It must retain the submission and communicate whether the server advanced the current revision or accepted a competing revision for review. It must not automatically combine server and tablet fields.

### Review-export

Review-export must present competing complete revisions with enough identity and ancestry to compare them, and provide a coordinator path to record a resolution. It must exclude a visit with unresolved review work from the partner CSV, even when that visit still has a current revision. Once review work is resolved, export eligibility follows the resolved current revision.

These obligations define the record-store boundary; tablet-sync and review-export will specify their own interaction and presentation details in their respective design nodes.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent edits to one visit | Preserve complete submissions as competing revisions when their base is no longer current; resolve them through coordinator review | Field-aware three-way merge of edits from a shared base | Whole revisions preserve the exact observations each worker submitted and avoid rules that could combine scientifically related values without recognizing their relationship. The accepted cost is more coordinator review, including for unrelated field changes. Three-way merge remains attractive where reducing review volume outweighs the risk and ongoing cost of maintaining field-aware rules and provenance. |

## Open Questions & Future Decisions

### Resolved

1. Concurrent edits use whole-visit revisions and coordinator review rather than automatic field-aware merging.

### Deferred

1. Define whether new submissions received while a visit already has unresolved review work join that review set or can advance the current revision.
2. Define whether coordinators resolve by selecting an existing revision only or may submit a new complete resolution revision.
3. Define how one coordinator resolution closes multiple competing revisions and records which revisions contributed to its outcome.
4. Define whether repeated complete payloads submitted with different idempotency keys create distinct revisions or are treated as duplicates.
5. Define the idempotency-key namespace and which submission attributes must match for a retry to return the original acceptance result.

## References

- [High-Level Design](../../high-level-design.md)
- [Record Store EARS Specifications](record-store-specs.md)
- [Site Catalog Design](../site-catalog/site-catalog-design.md)
```

### LLD edge-case probe

Please decide which of these gaps to settle in this design and which to defer:

1. **A new submission arrives during active review.** If it is based on the current revision, should it join the competing revisions and leave the current revision unchanged, or may it advance the current revision while the older conflict remains unresolved?
2. **Coordinator resolution.** Should a coordinator select one submitted revision, or may they create a new complete revision after comparing submissions? The latter needs explicit provenance and rules for which revisions the resolution closes.
3. **A submission races with resolution.** If another revision arrives while the coordinator is resolving a set of revisions, should that new revision remain unresolved for a later review, or be included in the current resolution?
4. **Idempotency boundaries.** Should an identical payload sent under a different key be a distinct submission? What identifies the key's scope, and does a retry need to match the base revision as well as the payload?
5. **Submission responses.** What information should a rejected stale/unknown-base submission return so tablet-sync can distinguish rejection from an accepted competing revision and recover appropriately?

The chosen concurrency policy is recorded in the LLD’s Decisions & Alternatives row. This trade-off may merit a standalone decision doc because a future reader could reasonably revisit it; would you prefer that, or is the LLD row sufficient?

Please review the LLD, indicate which edge cases to settle or defer, and approve it before I update the REC EARS specifications.