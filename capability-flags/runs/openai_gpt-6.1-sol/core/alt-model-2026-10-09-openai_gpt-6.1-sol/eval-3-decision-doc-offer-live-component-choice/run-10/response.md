Drafted **whole-visit revisions** in `docs/intent/record-store/record-store-design.md`, including your rationale: preserving scientifically related edits together is worth a larger review queue.

The draft defines complete immutable revisions, base revision IDs, retry handling, competing-revision states, and coordinator resolution guarded against new submissions or another coordinator’s decision. **This is the LLD review stop**; a few contract choices need your judgment before the design can be finalized.

<details>
<summary>Full record-store design draft</summary>

```yaml
parent: high-level-design
prefix: REC
```

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Whole-visit revisions preserve each submitted visit as a scientific unit. Independent edits can relate a species identification to its cover estimate even when they touch different fields. Competing revisions therefore enter coordinator review rather than being automatically combined. A larger review queue is an accepted cost of preserving whole-visit intent.

Tablet-sync and review-export consume this node's submission and review contracts. This node owns persistence and concurrency semantics; its consumers own tablet interaction, coordinator presentation, and CSV generation.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, unresolved-work retrieval, and coordinator resolution operations. Each accepted submission creates an immutable complete revision. The original submission envelope, authenticated author, and server receipt time remain available after subsequent edits and review decisions.

Persistence separates immutable revisions from a visit's mutable state: current revision ID, review state, candidate revision IDs, and a state token. A transaction serializes changes to one visit and advances its state token. The token identifies the exact state read by a coordinator, including the set of candidates, rather than merely identifying the current revision.

Acceptance, idempotency recording, and the resulting visit-state change commit atomically. An acceptance response is returned only after durable commit. Server receipt times document receipt, not scientific precedence.

## Submission Envelope

| Field | Meaning |
|---|---|
| `visitId` | Client-generated UUID identifying the visit across revisions |
| `idempotencyKey` | Worker-generated identifier reused for retries of the same submission |
| `baseRevisionId` | Accepted revision from which the edit began; null for initial creation |
| `visit` | Complete snapshot: plot UUID, observation date, observer list, species cover estimates, and notes |

The authenticated worker identity comes from authentication, separately from the observation's observer list. The server assigns the submission's revision ID and receipt time. A submitted snapshot replaces the whole visit only through the transitions below; the store does not derive field patches or automatically combine snapshots.

Validate the envelope, field types, and plot reference before acceptance. Plot references use stable catalog UUIDs and remain resolvable after archival. A non-null base must identify a retained revision of this same visit. An unknown base or a base belonging to another visit is rejected with a specific error, leaving the visit unchanged.

The precise scientific-field validation limits and the policy for new visits referencing archived plots are review questions below. No botanical inference is used to decide whether competing submissions are scientifically equivalent.

### Idempotency

Idempotency keys are scoped to the authenticated worker. Equality compares the submitted visit ID, base revision ID, and complete snapshot using structural JSON equality; object-key order is immaterial and array order is retained. Authentication credentials and transport metadata are outside this comparison.

A retry of an accepted identical submission returns its original acceptance result, including revision ID and disposition at acceptance. It does not re-evaluate the submission against later visit state. Clients retrieve current state separately. Reuse of the same worker's accepted key for a different envelope returns `idempotency-key-reused`. Rejected requests do not reserve keys. Accepted key records remain with the submission history so multi-day retries remain safe.

## Visit State and Transitions

`clear` means the store has one current revision and no competing revisions requiring resolution. `needs-review` means the current revision is retained for context but is not usable as an export value. Store-level clearance describes concurrency only; review-export owns any additional scientific approval criteria.

| Existing state | Accepted submission | Result |
|---|---|---|
| Visit absent | Null base | Create a clear visit with the submitted revision as current |
| Clear | Base equals current revision ID | Advance current to the submitted complete revision |
| Clear | Base is another retained revision of this visit | Enter needs-review with the current and submitted revisions as candidates |
| Visit exists | Null base under a new idempotency key | Preserve the competing initial submission and enter or remain needs-review |
| Needs-review | Any valid base, including the current revision | Retain the new revision as another candidate; remain needs-review |

An update during review never clears the review state automatically. Existing candidates remain available even when a later submission is based on one of them. Two competing submissions with equal snapshots but different keys still retain distinct revision identities and follow these transitions. A coordinator sees the complete candidate snapshots and their base links; the store performs no equivalence-based suppression.

In a clear visit, a superseded revision remains in history. In a needs-review visit, every outstanding candidate remains in the candidate set until a successful coordinator resolution. A late submission based on a pre-resolution revision creates new review work against the then-current revision, including after an earlier dispute was resolved.

## Retrieval Contract

| Operation | Returned information |
|---|---|
| Submit | Revision ID, receipt time, acceptance disposition (`current` or `needs-review`), and visit state token at acceptance |
| Get visit | Visit ID, state token, review state, current revision snapshot and ID, candidate revision IDs, and concurrency clearance |
| Get history | All retained revision envelopes, base links, authors, receipt times, and resolution records for the visit |
| Get unresolved work | Needs-review visits with state tokens and complete candidate revisions for comparison |

Each visit-state response is a coherent read: its token, current revision, and candidate set describe the same committed state. A needs-review response explicitly marks its current revision as context only. A missing visit returns `visit-not-found`, rather than an empty scientific record.

## Coordinator Resolution

A resolution request carries the visit ID, an idempotency key, the state token reviewed, and an outcome identifying the complete revision to make current. The coordinator's authenticated identity, server resolution time, reviewed candidate IDs, and outcome revision ID form an immutable resolution record. Original revisions remain unchanged and accessible.

The coordinator must resolve the entire candidate set represented by the supplied token. A successful resolution atomically records the outcome, installs its current revision, clears the candidate set, and advances the state token. A mismatched token returns `review-state-changed` without applying the outcome. This prevents either a newly arrived field submission or the other coordinator's decision from being silently overwritten.

Resolution retries use the same worker-scoped idempotency rules as submission retries, with operation type included in request equality. A successful resolution retry returns the original result before checking its old token. A request against a clear visit returns `review-not-open`.

The permitted outcome forms require user review: selection of one existing candidate is supported by the revision model; allowing a coordinator-authored complete replacement would additionally create a new immutable revision linked to the reviewed candidates. This choice determines the resolution request's final payload shape.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions with coordinator review of competing snapshots | Field-aware three-way merge of disjoint changes | Scientific relationships can cross fields. Preserving the submitted visit as a unit is worth increased review work and avoids maintaining merge rules that can combine related edits without noticing. |
| Stale edits | Retain as competing revisions, including after a resolution | Reject stale edits; make latest receipt current | Workers can submit after multi-day disconnection; their observations must remain inspectable without giving arrival order scientific authority. |
| Review concurrency | Compare a visit-state token covering current and all candidates | Compare current revision ID alone | A newly arrived candidate can change review work without changing the current revision; both coordinators need protection against stale decisions. |
| Retry outcomes | Replay the original durable result; retrieve current state separately | Recompute acceptance on each retry | An uncertain connection must not create a second edit or change what an earlier acceptance meant. |

## Open Questions & Future Decisions

1. Can a coordinator only select an existing candidate, or also author a complete corrected revision from the reviewed submissions? Both preserve original submissions; the latter enables corrections that no submitted candidate contains.
2. Does a new visit naming an archived plot enter the store, or are archived references accepted only for corrections to existing visits? The catalog guarantees historical lookup but does not select the intake policy.
3. Which scientific-field constraints define a valid submission: cover range and precision, repeated species entries, date format and future dates, and empty observer lists? Field-type validation alone does not settle these domain choices.

## Downstream Obligations

Tablet-sync retains base revision IDs and submits complete snapshots with stable retry keys. It distinguishes durable acceptance from clearance and retrieves current state when an old acceptance result is replayed. Its local draft, retry, and worker-notification design consumes this contract.

Review-export presents complete competing revisions with authors, base links, and receipt times. It submits coordinator outcomes against the state token actually reviewed and handles `review-state-changed` by fetching the revised candidate set. Visits with unresolved review work are excluded from the CSV, even though a contextual current revision is available. Review-export owns the consistency boundary for assembling a CSV while visit states can change.

These obligations are inputs to the downstream designs and await their separate review. The site-catalog snapshot format remains independent of revision handling.

## References

- `docs/high-level-design.md`
- `docs/intent/site-catalog/site-catalog-design.md`
- `docs/intent/record-store/record-store-specs.md`

</details>

### Review questions

The design probe found these gaps. Please indicate which to settle now and which to defer:

1. **Coordinator outcomes:** select an existing candidate only, or also author a complete corrected revision? For example, neither candidate may contain the final correct species identification and cover estimate.
2. **Archived plots:** accept new visits against archived plots, or allow only corrections to existing visits?
3. **Validation:** which cover limits, duplicate-species rules, date rules, and observer requirements belong at intake?
4. **Outcome eligibility:** must a selected revision be an outstanding candidate, or may a coordinator restore any historical revision?
5. **Competing initial submissions:** should a second null-base submission retain the previous current revision and put both snapshots into review?
6. **Retry precedence:** should accepted-key lookup always precede validation, so an identical retry succeeds even if validation rules have changed?
7. **Error contract:** if another coordinator has already cleared the visit, should a stale resolution return `review-state-changed` or `review-not-open`? The machine-readable error envelope also needs definition.

Two documentation decisions accompany this stop:

- May I refresh the HLD’s stale “concurrency choice open” references while keeping the substantive decision owned by record-store?
- This trade-off is consequential enough that a future maintainer could revisit it. Would you like a standalone decision document comparing scientific integrity, review workload, and maintenance cost, or keep the rationale in the existing Decisions & Alternatives table?

`git diff --check` passed. **Do you approve the draft direction, with the questions above resolved or explicitly deferred?**