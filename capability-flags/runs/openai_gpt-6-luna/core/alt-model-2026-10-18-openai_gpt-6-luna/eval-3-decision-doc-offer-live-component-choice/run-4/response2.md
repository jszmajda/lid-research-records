## Phase 2 — Record-store LLD

I updated `docs/intent/record-store/record-store-design.md` to specify whole-visit revisions, preserve the rationale for considering field-aware merge, and describe what tablet-sync and review-export will need to accommodate. The LLD is consistent with the HLD’s architecture and tenets. Its EARS specs still need to be cascaded in Phase 3.

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit has a stable client-generated UUID and refers to a catalog plot UUID. Tablets may be disconnected for as long as 48 hours, so a submission can be based on a revision that is no longer current when it reaches the server.

The record store preserves each accepted submitted visit as a complete, immutable revision. It does not combine fields from different submissions. A submission names the revision from which the worker began editing; when that base is no longer current, the submitted revision is retained as competing review work. This favors preserving each worker's submitted observation as a unit over reducing the amount of review.

## Visit and Revision Model

A visit is the logical record identified by its visit UUID. A revision is one complete visit payload, including its plot UUID, observation date, observer list, species cover estimates, and notes. The server assigns each accepted revision a revision UUID and records the submitting worker and server receipt time. A revision also records the base revision UUID from which the worker made the edit; an initial visit has no base revision.

Accepted revisions are append-only. Correcting or resolving a visit creates another complete revision rather than mutating an earlier submission. The record store retains original payloads and revision ancestry so a reviewer can identify what each worker submitted and from which state it was derived.

## Submission and Idempotency

Submission requires an authenticated worker, a visit UUID, a complete visit payload, a base revision UUID (except for an initial visit), and an idempotency key. The record store validates field types and the plot reference before acceptance. It stores the original payload, author, receipt time, base revision, and assigned revision UUID.

A retry with the same idempotency key and identical request payload returns the original acceptance result without creating another revision. Reusing an accepted key with a different request payload is rejected and leaves the accepted revision unchanged.

## Current Revision and Competing Work

For a visit with no unresolved competing revisions, a valid submission based on the current revision becomes the current revision. A submission based on a revision that is no longer current is accepted as a complete competing revision; it does not replace the current revision or alter any accepted payload. The visit is marked as having unresolved review work.

While a visit has unresolved review work, retrieval reports both the current revision and the unresolved competing revision IDs, with their authors, receipt times, and base revision IDs. The visit's unresolved status is explicit and distinct from which revision is currently selected. The record store does not infer that a revision is more authoritative merely because it arrived later, and does not automatically merge any fields.

Retrieval also provides the revision history needed to reconstruct the submitted alternatives. An unknown base revision is not treated as a known competing branch; its acceptance behavior remains an open question.

## Review Resolution

A coordinator resolves a visit's competing revisions through an authenticated resolution operation. The recorded outcome identifies the coordinator, the contributing submission IDs, the resulting whole-visit revision, and the resolution time. The original submitted revisions remain unchanged and available in history. Resolution clears the unresolved-work marker for the set of revisions it addresses.

Whether the result must be one of the submitted revisions or may be a new coordinator-authored complete revision is unresolved. The operation must not silently combine individual fields or erase the source submissions.

## Downstream Contracts

### Tablet-sync

Tablet-sync must retain the base revision UUID associated with each local edit and submit that UUID with the complete visit payload. It must handle a response that identifies an accepted competing revision and unresolved review status, rather than assuming every accepted submission replaced the current revision. Retry behavior must preserve the same idempotency key and request payload.

### Review-export

Review-export must present whole-visit revisions for comparison, including their authorship, receipt times, and base revisions. It must keep visits with unresolved competing revisions out of the partner CSV until resolution. Its resolution workflow must send a complete resolution outcome to the record store and retain coordinator identity and contributing submission IDs.

These downstream components consume the record-store contract; they do not define separate concurrency or resolution semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent edits to a visit | Preserve complete submitted revisions and route stale-base revisions to review | Field-aware three-way merge of base snapshots and structured changes | Whole-visit revisions preserve each submission intact and avoid maintained rules that might combine scientifically related edits without recognizing their relationship. This accepts a larger review queue, including review of edits that could be independent. Field-aware merging remains credible because it could combine disjoint changes automatically, reduce coordinator workload, and make more visits ready for export sooner; it would require reliable merge rules for observer lists, species entries, and other fields, plus field-level provenance and overlap handling. |
| Storage of accepted submissions | Append-only complete revision history with idempotent submission retries | Mutate a single visit row or retain only the latest state | Retaining original submissions and stable retry outcomes makes corrections auditable and prevents a retry or later resolution from destroying the submitted evidence. |

## Open Questions & Future Decisions

### Resolved

1. Concurrent edits use whole-visit revisions; a stale-base submission is retained as review work rather than merged automatically.

### Deferred

1. Define whether a coordinator resolves competition by selecting an existing submitted revision or by creating a new complete resolution revision.
2. Define how additional submissions are grouped and resolved while a visit already has unresolved competing revisions.
3. Define acceptance behavior for a submission whose base revision UUID is unknown or belongs to another visit.
4. Define whether and how the system signals that an offline tablet may still submit a revision based on an older state; the record store cannot infer unsubmitted tablet work from received revisions alone.

## References

- `docs/high-level-design.md` — project architecture and tenets.
- `docs/intent/site-catalog/site-catalog-design.md` — stable plot UUID contract.
```

### LLD edge-case probe

These gaps affect the record-store contract. Which should be resolved in this LLD, and which should remain deferred?

1. If a new submission is based on the selected current revision while the visit already has unresolved competing revisions, should it join the unresolved work or advance the current revision?
2. Should a coordinator resolve competition by selecting one submitted revision, or may they create a new complete resolution revision?
3. When more revisions arrive during unresolved work—or while a resolution is being recorded—how should they be grouped, and what exactly does that resolution clear?
4. Should an unknown or another visit’s base revision be rejected, or accepted into a separate review/error state?
5. What scope makes an idempotency key unique: across all submissions, per worker, or per visit?

One further documentation choice: the detailed rationale is currently a row in the LLD’s Decisions & Alternatives table. Because field-aware merging remains a credible option with meaningful downstream tradeoffs, a standalone decision document could preserve the full comparison. **Would you prefer a standalone decision document, or should the LLD row remain the record?**

Please review the LLD, answer or defer the probe items, and indicate your decision-document preference before I continue.