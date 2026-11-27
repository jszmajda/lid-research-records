## Phase 2 — Record-store LLD

The draft specifies whole-visit revisions with explicit base revision IDs. Stale or competing submissions remain intact for coordinator review; the store does not automatically merge fields. It also records why field-aware merging remains a credible alternative: it could reduce review volume for unrelated edits, but would require rules that safely account for scientific relationships between fields.

The draft is in `docs/intent/record-store/record-store-design.md`:

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

The record store owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a stable catalog plot ID. Tablets may be offline for up to 48 hours, so an edit can be submitted after another worker has already changed the visit.

The store preserves every accepted submission as a complete visit revision. The revision a worker edited is part of the submission's meaning: the store uses its base revision ID to distinguish an edit based on the current record from one based on an older record. Server arrival time is audit information, not evidence that one worker's scientific observations are more authoritative.

## Revision Model

Each visit has a stable `visit_id`, a current resolved `revision_id`, and zero or one open review case. A revision is immutable and contains:

| Field | Meaning |
|---|---|
| `revision_id` | Server-assigned stable identifier for this complete visit snapshot |
| `visit_id` | Stable identity of the visit |
| `base_revision_id` | Revision the submitter edited; absent only for the initial visit revision |
| `submission_id` | Identity of the accepted submission that created this revision |
| `author_id` | Authenticated worker who submitted it |
| `received_at` | Server receipt time |
| `payload` | Complete submitted visit, including all scientific fields |

The store retains the original submitted payload and revision metadata after later revisions or review resolutions. It does not overwrite a revision or synthesize a merged revision from worker submissions.

## Submission and Current-State Rules

The authenticated submission operation accepts a visit ID, an idempotency key, a base revision ID, and the complete edited visit payload. The store authenticates the worker and validates field types, required fields, and the plot reference before accepting the submission.

For an accepted submission, the store assigns a submission ID and revision ID and records the complete payload, author, base revision, and server receipt time. An identical retry with the same idempotency key returns the original acceptance result without adding a revision. Reusing an accepted key with a different payload is rejected without changing stored data.

| Condition at acceptance | Store outcome |
|---|---|
| Initial visit has no revision and the submission has no base revision | Store the initial revision as the current resolved revision |
| No review case is open and `base_revision_id` equals the current resolved revision | Store the new complete revision and make it the current resolved revision |
| No review case is open and the base revision differs from the current resolved revision | Preserve the current resolved revision, open review work for the visit with that revision and the submitted revision as candidates, and retain the submitted revision |
| Review work is already open for the visit | Retain the new revision as another competing revision; do not advance the current resolved revision |

The review work includes the last current resolved revision, each competing complete revision, and each revision's base revision so a coordinator can compare them in context. It remains open until an explicit coordinator resolution. A visit with open review work has no newly selected current revision; retrieval returns the last current resolved revision together with the open-review indicator and competing revision IDs.

If two submissions use the same base revision, the first may briefly become the current resolved revision. When the later submission arrives with that now-stale base, the store opens review work that includes both the current revision and the new competing revision. The store does not resolve the conflict by comparing receipt times.

## Review Resolution

A coordinator resolution closes the visit's open review case and selects the complete visit that becomes current. The coordinator may select one of the complete revisions in the case, including the previously current revision, or submit a complete corrected visit as the resolution. A coordinator-authored corrected visit is stored as a new immutable revision.

The resolution record retains the coordinator ID, resolution time, selected or created revision ID, and IDs of all submissions and revisions considered. The review case and its revisions remain available in submission history. Later edits continue from the selected current revision; a new submission based on a stale revision opens new review work.

## Retrieval and Submission History

Current-state retrieval returns the visit's current resolved revision and an explicit indication of whether review work is open. When review work is open, the response identifies its competing revisions so a caller can explain the unresolved state rather than treating a proposal as current.

Submission-history retrieval returns immutable revisions and resolution records in a form that preserves their authorship, base revision, receipt time, and relationship to review outcomes. Ordering may be provided for readability, but ordering does not determine precedence.

## Downstream Contract Obligations

### Tablet sync

- Store the revision ID a worker edited as the base revision for that tablet's local change.
- Submit that base revision ID with the complete visit snapshot and a stable idempotency key.
- Retain the local submission and display whether it became current or is waiting in review; a pending revision must not be presented as the server's current resolved visit.
- On retry, reuse the original idempotency key and payload. Do not automatically rebase or combine a local edit with a different server revision.

### Review and export

- Present open review work as competing complete revisions, with a comparison view that lets a coordinator inspect each submitted visit against its base revision and relevant visit history.
- Let the coordinator select a complete revision or submit a complete corrected visit as the resolution; preserve the resolution's coordinator and submission provenance.
- Exclude a visit with open review work from the partner CSV until a coordinator resolves it. Export the current resolved revision after resolution.
- Explain the exported revision through revision-level provenance: its submission or resolution, author or coordinator, and contributing submission IDs.

These are consumer obligations of the record-store contract. Tablet sync and review/export own their local persistence, interfaces, and CSV behavior in their respective design nodes.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Preserve complete submitted revisions; route stale-base and otherwise competing revisions to coordinator review | Field-aware three-way merge that combines disjoint field edits and reviews overlaps | Whole-visit revisions preserve each worker's submitted scientific interpretation and avoid relying on merge rules that may miss relationships between fields, such as species identity and cover. This creates more review work, including for unrelated edits, but the team accepts a larger queue over maintaining rules that could combine scientifically related changes without noticing. Field-aware merge remains worth reconsidering if review volume proves unmanageable and rules can safely represent the relationships in the data. |
| Current state while review is open | Keep the last resolved revision as current and expose unresolved proposals separately | Promote the newest submission or treat receipt order as precedence | The last resolved revision remains a clearly identified usable state, while every competing submission remains visible for a coordinator. Receipt order does not establish scientific authority. |
| Coordinator resolution | Select one complete revision or store a coordinator-authored complete correction as a new revision | Field-by-field merge performed by the store | A coordinator can resolve a case using scientific judgment without making automated field-combination rules part of the persistence layer. Retaining a corrected complete revision keeps the resolved result and the submissions considered inspectable. |

## Open Questions & Future Decisions

### Resolved

1. Concurrent edits use whole-visit revisions with explicit base revision IDs and coordinator review for competing submissions.
2. Unresolved review work leaves the last resolved revision identifiable but holds the visit out of CSV export.
3. Coordinator resolution selects a complete revision or records a complete corrected visit as a new revision.

### Deferred

1. The submission, retrieval, history, and resolution wire formats, including error shapes and authorization boundaries, belong in the service implementation design.
2. Tablet-local persistence and user-facing pending-review behavior belong in tablet-sync.
3. The comparison interface, queue operation, and exact CSV columns belong in review-export.
4. Review-queue volume should be observed during operation; a future change to field-aware merge requires rules that preserve scientifically related edits, not merely disjoint field paths.

## References

- `docs/high-level-design.md` — project architecture and governing goals.
- `docs/intent/site-catalog/site-catalog-design.md` — stable plot references used by visit revisions.
```

The LLD-level edge-case probe surfaced these questions for your triage:

**Needs a design decision or explicit deferral**
1. If two initial submissions for one visit arrive concurrently with no base revision, should one become the initial revision and the other enter review, or should the duplicate initial submission be rejected?
2. If a submission names a base revision that does not exist or belongs to another visit, should it be rejected without storing a revision?
3. If a submission races with a coordinator resolving the open case, should the operation order determine whether it joins the case being closed or is evaluated against the newly selected revision?
4. If two coordinators resolve the same case concurrently, should only the first resolution succeed? How should a retry after the case has closed behave?
5. For a coordinator-authored correction, what should its `base_revision_id` reference when the case contains multiple candidate revisions?

**Reasonable to defer to implementation design**
- Exact error responses for authentication, invalid fields or plot references, unknown bases, and idempotency-key reuse.
- What counts as an identical retry payload and the idempotency-key uniqueness scope.
- Submission-history pagination and display ordering.

`git diff --check` passes. The existing EARS file remains unchanged pending your LLD review and the next phase.

Two related decisions need your direction before I proceed:

- Would you like the concurrency choice recorded in a standalone decision doc, or is the rationale in the LLD table sufficient? The choice has meaningful tradeoffs and will shape downstream designs.
- `docs/intent/site-catalog/site-catalog-design.md` still says tablet submission and reconciliation behavior is pending the concurrency choice. That statement is now stale and crosses into another segment; should I update that sentence now, or leave it for a later cascade?

Please review the LLD and tell me which probe items to resolve in the design versus defer, along with your decisions on those two points.