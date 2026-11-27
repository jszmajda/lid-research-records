Recorded **whole-visit revisions** in `docs/intent/record-store/record-store-design.md`. The LLD draft is below for review. The edge-case probe found several contract choices that need your judgment before the design can be finished.

## Record Store — LLD draft

**Parent:** high-level-design · **Spec prefix:** REC

### Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker’s observations are more authoritative.

Each accepted submission is a complete, immutable visit revision. Concurrent revisions remain separate for coordinator review, including revisions whose edits affect different fields. Whole-visit integrity takes priority over reducing the review queue because species identity, cover estimates, and other observations can be scientifically related without that relationship being apparent to software.

### Architecture

The record store exposes authenticated submission, visit-state retrieval, revision-history retrieval, unresolved-work retrieval, and coordinator resolution operations. Original submissions remain available after a revision is superseded or a conflict is resolved. Recording a revision and its effect on visit state is one atomic operation; competing submissions are evaluated against the committed state of that visit.

### Submission Envelope and Revision History

A worker submits a visit ID, an idempotency key, a base revision ID, and the complete visit payload: plot ID, observation date, observer list, species cover estimates, and notes. The first submission for a new visit has a null base revision ID. Corrections name the stored revision from which the worker edited; the base belongs to the same visit. Payloads contain whole visits rather than field patches or base snapshots.

Authenticate the worker and validate field types and catalog plot references before acceptance. The server assigns revision IDs and records the authenticated author and receipt time; client arrival times do not establish authority. Each revision retains its original submission envelope and base reference. Resolution outcomes retain coordinator identity and contributing submission IDs.

A retry with the same accepted key and identical submission envelope returns the original acceptance result without another revision, even if the visit has subsequently changed. Reuse with a different envelope is rejected. Invalid submissions do not change visit state. Revision history includes superseded and competing revisions, their payloads, authors, receipt times, and resolution records.

### Revision Transitions and Retrieval

A first accepted revision establishes the visit. For a visit without unresolved work, a correction based on its current revision replaces that revision as current while retaining both in history. A correction based on an older stored revision creates unresolved review work containing the competing complete revisions; neither receipt time nor field differences select a winner.

The submission response identifies the stored revision and whether its acceptance created unresolved work. Visit-state retrieval explicitly reports unresolved work and identifies its competing revisions. The store supplies an unresolved-work list and complete revision payloads for comparison. An unresolved visit is ineligible for the reviewed CSV; the remaining scientific approval criteria belong to review-export.

The representation of current state during review, and the treatment of further submissions during review, are open decisions below. History remains available independently of those choices.

### Coordinator Resolution

Resolution is an authenticated coordinator operation over an explicitly identified set of competing revisions. Its result establishes one complete current visit and retains the reviewed revisions and the coordinator’s outcome. It does not automatically combine fields. The operation must detect changes to the review set before committing so that another submission or coordinator cannot be silently omitted. The allowed outcome forms are an open decision below.

### Decisions & Alternatives

| Decision | Chosen | Alternative | Rationale |
|---|---|---|---|
| Concurrent visit edits | Whole-visit revisions with coordinator review | Field-aware three-way merge using base snapshots and structured changes | Preserving scientifically related observations as a submitted unit outweighs a smaller review queue; field-aware merging requires maintained rules that can miss those relationships. |

### Downstream Contracts

- **Tablet-sync** retains base revision IDs, submits complete visit payloads with stable retry keys, and presents unresolved outcomes to workers.
- **Review-export** compares whole revisions, submits coordinator outcomes, and holds unresolved visits out of the reviewed CSV.

These are obligations for those nodes’ later designs. Their local storage, user interfaces, and export implementation are outside this node. Both consume record-store’s concurrency semantics rather than defining their own.

### Open Questions & Future Decisions

1. During unresolved review, does visit retrieval expose the previous current revision as explicitly provisional, or expose no usable current revision until resolution?
2. When further valid edits arrive during unresolved review, should all be retained as additional candidates in the existing review work, or should submissions be rejected explicitly until coordination finishes?
3. Can a coordinator only select an existing complete revision, or also author a new complete corrected revision with links to the reviewed submissions?
4. If a null-base submission arrives for an existing visit ID, should it become a competing revision or be rejected as a creation collision?
5. Which revisions enter the competing set when a stale edit follows several sequential corrections: the incoming and current revisions only, or also intermediate revisions? How does that set distinguish alternatives from historical context?
6. Does resolution give the chosen outcome a new revision ID, even when selecting an existing payload, or make an existing revision current again? How are subsequent edits based on reviewed revisions classified?
7. What scopes an idempotency key, what defines identical envelopes, and how are simultaneous retries and resolution retries represented?
8. What review version identifies a resolution’s expected state, and what stale-state result is returned when another coordinator or submission commits first?
9. What results distinguish missing or cross-visit bases, creation collisions, key reuse, and review-time rejection? Do fresh-key submissions with identical scientific payloads follow the same revision transitions as other submissions?

### References

- `docs/high-level-design.md`
- `docs/intent/record-store/record-store-specs.md`
- `docs/intent/site-catalog/site-catalog-design.md`

---

## Review needed

Please resolve **questions 1–6**. The practical tradeoffs are:

- Provisional current state keeps a reference visible; no usable current state makes unresolved status harder to overlook.
- Accepting further revisions preserves ongoing submissions but can grow the review set; rejecting them requires tablets to retain and retry those edits.
- Coordinator-authored revisions allow a corrected whole visit when no candidate is right, but require a richer resolution contract.
- A new resolution revision ID distinguishes post-review edits from edits based on an earlier candidate; reusing an ID keeps history simpler.

For **questions 7–9**, which should we settle in this design, and which may remain explicitly deferred?

Two documentation decisions also need your approval:

- May I update the HLD’s stale “concurrency choice open” wording to point to this selected policy and its remaining contract questions?
- Would you like a **standalone decision document** preserving the whole-visit-versus-field-merge tradeoffs for future readers, or keep the rationale in the LLD’s decision row?

`git diff --check` passed. This is the Phase 2 review stop; the corresponding EARS update follows approval of the LLD.