Drafted **whole-visit revisions** in `docs/intent/record-store/record-store-design.md`. The decision stays in record-store, with downstream obligations recorded there.

The contract preserves complete submissions, advances uncontested revisions, holds competing revisions for review, and prevents unresolved visits from entering the CSV. `git diff --check` passes.

**One choice remains before the design can be finalized:** may coordinators author a complete replacement during resolution, or only select an existing revision?

### Review questions

1. **Resolution outcome**
   - **Selection only:** choose an intact existing revision; further corrections require another submission.
   - **Selection or coordinator-authored replacement:** a coordinator can reconcile field notes into a new complete revision, with contributing submissions recorded. This still involves no automatic field merging.

2. **Edge-case probe:** a separate reader found these gaps. Which should we settle in this LLD, and which should remain explicitly deferred?
   - Must a resolution name exactly the entire outstanding revision set? What errors cover missing, duplicate, or invalid revision IDs?
   - How are comparison inputs kept consistent when submissions arrive between retrieval calls? Does every accepted submission advance the state version?
   - How are concurrent uses of an author’s idempotency key serialized across different visits? How should resolution retries work after a lost response?
   - Can a resolution select an older historical revision or run when no review work exists?
   - Can a correction change the plot UUID, and what validation/error details do callers receive?

3. **Decision record:** this trade-off will shape both downstream designs, and a future maintainer could reasonably reconsider it. Would you like a standalone decision document comparing scientific fidelity, review workload, and maintenance burden, or keep the Decisions & Alternatives row?

4. **Adjacent-document refresh:** the HLD and site-catalog still describe this choice as pending. May I refresh those references after this design review?

The current EARS cover the original preservation and retry behaviors but do not yet cover this expanded contract. Their update follows approval of the LLD.

<details>
<summary>Full record-store design draft</summary>

# Record Store

Parent: `high-level-design`  
Spec prefix: `REC`

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker’s observations are more authoritative.

Whole-visit revisions preserve each submitted visit as a scientific unit. Concurrent submissions create review work even when their changed fields appear unrelated. Scientific relationships between fields are assessed by a coordinator rather than encoded in automatic merge rules.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, unresolved-visit listing, and coordinator resolution operations. Original submissions and revision payloads are immutable. A visit’s current revision and review state are mutable references updated atomically with its history.

A complete visit payload contains its plot UUID, observation date, observer list, species cover estimates, and notes. Author identity is derived from authentication and is separate from the observer list. Server receipt time records arrival, not scientific precedence.

### Stored entities

| Entity | Contents |
|---|---|
| Submission | Submission ID, visit ID, authenticated author ID, server receipt time, idempotency key, base revision ID, original complete payload, resulting revision ID, original acceptance result |
| Revision | Server-assigned revision ID, visit ID, immutable complete payload, originating submission or resolution ID, base revision ID where applicable |
| Visit state | Visit ID, current revision ID, review-required flag, outstanding revision IDs, opaque state version |
| Resolution | Resolution ID, coordinator ID, server receipt time, reviewed state version, contributing submission IDs, reviewed revision IDs, outcome revision ID |

Revision IDs identify stored snapshots; the state version identifies the entire mutable visit state, including outstanding review work. Both are opaque to callers.

## Submission and Retrieval

### Submission envelope

Each request contains `visitId`, `idempotencyKey`, `baseRevisionId`, and the complete visit payload. A first submission uses a null base revision ID. A correction names the stored revision from which the worker began editing. The server does not require a base snapshot or field-level changes.

Authenticate the submitting worker and validate field types and plot references before accepting a submission. Archived plot UUIDs remain resolvable through site-catalog. A non-null base must exist and belong to the same visit; an unknown or cross-visit base is rejected without accepting the submission.

Idempotency keys are scoped to the authenticated author. Compare the entire submission envelope, including visit and base revision IDs, by its structured values. A retry with the same key and identical envelope returns the original acceptance result; reuse with a different envelope is rejected. An identical payload under a different key remains a distinct submission.

Successful responses contain submission ID, revision ID, receipt time, and the disposition at acceptance: `current` or `review_required`. That result remains fixed for retries; callers retrieve the visit separately to learn its latest state.

### State transitions

| Prior state and submission | Result |
|---|---|
| Visit does not exist; null base | Store the submission and revision; establish the revision as current with no outstanding concurrency review |
| Visit exists with no review work; base equals current revision | Store the complete new revision and advance current to it |
| Visit exists; null base or base differs from current revision | Store the complete revision as outstanding review work; retain the current reference and mark the visit unresolved |
| Visit already has review work; any valid base | Store the revision as additional review work; retain the current reference and keep the visit unresolved |

Each transition is a transaction serialized per visit. Two submissions naming the same current base cannot both advance current without exposing review work. No acceptance transition combines payloads or compares fields to waive review.

The first arriving revision can become current before a competitor arrives. Once review work exists, that reference is historical context for comparison, not a selection of the scientifically preferred revision. Incoming descendants of an outstanding revision are retained along with that revision for coordinator inspection. A late correction based on a revision predating a resolution reopens review rather than replacing the resolved outcome.

### Retrieval and errors

Visit retrieval returns `visitId`, `stateVersion`, `currentRevisionId`, the current payload, `reviewRequired`, and outstanding revision IDs. History retrieval exposes original submissions, revision bases, authors, receipt times, and resolution outcomes. An unresolved-visit listing exposes visit IDs and state versions so review-export can retrieve the matching comparison inputs.

When `reviewRequired` is true, the current payload is not eligible for CSV export. When false, it is a candidate for review-export’s separate approval and export rules; absence of a concurrency conflict does not establish scientific approval.

Operations return structured error codes: `unauthenticated`, `forbidden`, `invalid_payload`, `unknown_plot`, `unknown_visit`, `invalid_base_revision`, `idempotency_key_reused`, or `stale_visit_state`, as applicable. Validation failures do not create accepted submissions or change visit state. A stale-state response includes the latest state version and directs the caller to retrieve fresh comparison inputs.

## Coordinator Resolution

A coordinator retrieves the current revision, outstanding revisions, and history at a visit state version. A resolution request names that version, all reviewed outstanding revision IDs, and its whole-visit outcome. Resolution records retain the coordinator’s identity and contributing submission IDs; reviewed but unselected revisions remain inspectable.

The permitted outcome needs a design decision:

- Select one existing complete revision, including the current revision. This makes resolution a choice among intact submissions. A correction absent from every candidate requires a separate submitted revision.
- Select an existing revision or submit a coordinator-authored complete replacement. This permits a coordinator to reconcile field notes in one operation while recording the contributing submissions. The replacement is a manually authored revision, not a server-generated field merge.

In either form, resolution atomically checks the submitted state version against the current visit state. If another submission or resolution has changed the state, it returns `stale_visit_state` without clearing review work. A successful resolution records its outcome, establishes the outcome revision as current, clears the reviewed outstanding set, and advances the state version. Losing submissions and earlier outcomes remain in history. Concurrent coordinator decisions therefore cannot silently overwrite one another.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent edit policy | Whole-visit revisions with coordinator review of competitors | Field-aware three-way merge | A larger review queue is preferable to maintaining merge rules that can silently combine scientifically related edits. Complete submitted visits retain their meaning and provenance. |
| Arrival order | Advance an uncontested current revision; hold competitors for review | Last-arrival overwrite; automatic field reconciliation | Arrival order supports serial progress but does not establish scientific authority over competing submissions. |
| Resolution concurrency | Compare the entire visit state version atomically | Compare only the current revision ID | New competing submissions can change the review inputs without changing the current revision ID. |

## Downstream Contract Obligations

These obligations originate in record-store; the consuming nodes own their interfaces and workflows.

- **Tablet-sync:** retain base revision IDs, submit complete visit payloads, preserve the same submission envelope and idempotency key across retries, and distinguish acceptance from becoming current. Its design must address edits made locally before a prior submission receives a server revision ID, and display fresh unresolved state after retrieval.
- **Review-export:** compare complete revisions and their provenance, send resolutions against a retrieved state version, refresh after stale-state errors, and exclude unresolved visits from the CSV. Its design must establish how export selection stays consistent if review state changes while an export is produced.
- **Site-catalog:** supply stable plot UUID lookup, including archived plots, under its existing historical-reference contract.

## Open Questions & Future Decisions

- Resolution outcome: selection only, or selection plus a coordinator-authored complete replacement.
- Resolution retries after a lost response: define an idempotency contract before implementation.
- Payload validation: define allowed cover ranges, duplicate species handling, and required fields before implementation; these are validation rules, not scientific inference.

## References

- [High-level design](docs/high-level-design.md)
- [Record-store EARS](docs/intent/record-store/record-store-specs.md)
- [Site-catalog design](docs/intent/site-catalog/site-catalog-design.md)

</details>

Please answer the numbered questions and flag any changes you want in the draft before we move to EARS.