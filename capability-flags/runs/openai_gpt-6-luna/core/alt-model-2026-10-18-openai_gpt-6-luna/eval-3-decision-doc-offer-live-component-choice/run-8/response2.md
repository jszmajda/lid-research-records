## Phase 2 — Record-store LLD

I’ve updated `docs/intent/record-store/record-store-design.md` with the whole-visit revision contract, the rationale for retaining field-aware merging as an alternative, and the obligations for tablet sync and review/export. The sibling designs remain untouched.

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

The record store accepts vegetation-visit submissions and provides the authoritative visit state used by review and export. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Workers may edit the same visit independently while tablets are offline, so a submission can be based on an older visit state than the one currently stored.

The record store preserves every accepted submission as a complete visit revision. It does not infer that edits to different fields are scientifically independent. When a submission is based on a revision that is no longer current, the record store retains it as competing review work rather than combining it with the current revision.

Tablet-sync and review-export depend on this node's submission and review contract. Their designs are separate: tablet-sync owns local draft and retry behavior, while review-export owns the coordinator workflow and CSV production.

## Visit Revisions

Each accepted submission contains a complete visit snapshot, not a patch. It includes a visit ID, plot ID, observation date, observer list, species cover estimates, and notes. The server assigns an immutable revision ID and retains the submitted payload, submitting worker, receipt time, and the revision ID on which the submission was based. A separate idempotency key identifies retries of that submission.

A new visit has no base revision. An edit identifies the server-issued revision ID for the visit snapshot from which the worker made the edit. The record store validates that the base revision belongs to that visit. The server does not use receipt time or field-level rules to combine edits.

The record store maintains a selected current revision and any unresolved competing revisions for each visit. When an edit is based on the selected current revision and no review is open, its complete snapshot becomes the selected current revision. When an edit is based on a revision that is no longer selected, the complete submission is retained as a competing revision and the visit is marked unresolved. The review set includes the previously selected revision and each competing revision; none is treated as resolved while review is open. The selected revision remains available in retrieval responses, marked unresolved, until a coordinator resolves the set.

An unresolved visit is not eligible for partner CSV export. Its complete revisions and their base-revision information remain available for comparison. The record store reports unresolved status and provides the revision data needed by review-export; review-export owns the comparison screen and export workflow.

## Submission and Retrieval

The submission operation authenticates the worker and validates field types, plot references, visit identity, and base-revision ownership before accepting a revision. Each accepted submission is retained independently of later current-state changes or review outcomes.

For an idempotency key already accepted with an identical payload and base revision, the record store returns the original acceptance result without creating another revision. Reuse of an accepted key with a different payload or base revision is rejected without changing stored data.

Retrieval returns the selected current revision and explicitly indicates whether the visit has unresolved competing revisions. Review retrieval provides the complete competing revisions, their base revision, and the identifiers and authorship metadata needed to audit the submissions. A caller must not interpret a selected current revision as resolved when the unresolved indicator is set.

## Review Resolution

A coordinator resolves an unresolved visit by selecting a complete revision as the resolved current state. Resolution records the coordinator identity, resolution time, selected revision ID, and the competing revision IDs considered. The original submissions and revision lineage remain retained after resolution.

The detailed behavior for new submissions arriving while review is open, and the permitted resolution outcomes when no submitted revision is suitable, remain open for review before the contract is finalized.

## Downstream Contract Obligations

These obligations guide the sibling designs without defining their internal workflows.

### Tablet Sync

- Store the server-issued base revision ID with the visit snapshot used to start an edit.
- Submit a complete visit snapshot with its base revision ID and an idempotency key; retries must reuse the same key and payload.
- Distinguish a revision accepted as current from one retained as competing review work, so a competing submission is not presented as an ordinary resolved update.
- Preserve enough submission context to retry or explain the server's outcome while offline and after reconnection.

### Review and Export

- Present complete competing revisions together with their base-revision information so a coordinator can compare whole visits.
- Record which revision the coordinator selected, who resolved the visit, and which competing revision IDs were considered.
- Exclude every visit with unresolved competing revisions from the partner CSV. A resolved visit becomes eligible according to the review-export contract.
- Preserve revision provenance from the accepted submissions through the selected resolved state and exported values.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent edits to a visit | Whole-visit revisions; stale-base submissions are retained as competing revisions for coordinator resolution | Field-aware three-way merge of disjoint changes, with overlapping changes sent to review | Whole revisions preserve each worker's complete submitted observation and avoid maintaining merge rules that could combine scientifically related changes across fields. This intentionally increases review volume. Field-aware merging remains worth considering because it could automatically combine genuinely unrelated edits and reduce the coordinator queue; it is not selected because field independence cannot reliably be inferred from field boundaries. |

## Open Questions & Future Decisions

### Resolved

1. Concurrent visit edits use whole-visit revisions. Submissions based on a stale revision remain intact and create unresolved review work.
2. The record store supplies revision and unresolved-state data; tablet-sync and review-export define their own user-facing workflows against that contract.

### Deferred

1. Define the exact behavior for submissions received while a visit already has unresolved review work, including whether additional edits join the open review set or are rejected for resubmission after resolution.
2. Decide whether a coordinator may resolve a visit only by selecting a submitted revision or may also create a corrected complete revision.

## References

- [High-Level Design](../../high-level-design.md)
- [Record Store EARS Specs](record-store-specs.md)
```

### LLD gap probe

Please decide which gaps to specify now and which to defer:

1. **Submissions during open review:** Should new edits join the existing review set, or be rejected until the visit is resolved?
2. **Resolution outcome:** Can a coordinator only select an already-submitted revision, or may they create a corrected complete revision?
3. **Different base revisions:** If competing submissions were based on different historical revisions, should they appear in one review set for the visit, or be grouped by base revision?
4. **Invalid base revision:** What should happen when a submission names a revision that does not exist or belongs to another visit?

Please approve the LLD and triage these gaps. I’ll wait for your review before updating the EARS specs.