I recorded the choice in `docs/intent/record-store/decisions/concurrent-visit-edits.md` and drafted the record-store design around whole-visit revisions. The draft identifies contract details that still need your decisions before the specs can be completed.

## Record-store design

`docs/intent/record-store/record-store-design.md`:

> ---
> parent: high-level-design  
> prefix: REC
> ---
>
> # Record Store
>
> ## Context
>
> This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.
>
> Tablet-sync and review-export depend on this node's revision and review contract.
>
> ## Architecture
>
> The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, and review-outcome operations. Persistence keeps original submissions, their authors, and server receipt times. A submission carries an idempotency key so a connection failure does not create another edit on retry.
>
> A visit's scientific fields include observation date, observer list, species cover estimates, and notes. Some edits are unrelated, such as correcting an observer name and adding a missing species. Other edits are related, such as revising a species identification and its cover estimate. The server cannot infer all such relationships from field names.
>
> ## Whole-Visit Revisions
>
> Each submitted edit is a complete visit with the ID of the revision it was based on. The store retains the submitted payload as an immutable revision, including its author and server receipt time. Edits based on the same starting state can therefore be compared as complete observations. Concurrent edits are retained as competing revisions for coordinator review; the store does not automatically merge fields. See [Concurrent Visit Edits](docs/intent/record-store/decisions/concurrent-visit-edits.md) for the tradeoff.
>
> When there is no unresolved review work, an edit based on the current revision becomes the new current revision. When competing revisions require review, retrieval must identify the unresolved work and make the competing revisions available for comparison. An unresolved visit is ineligible for the reviewed CSV until the review is resolved.
>
> ## Submission and Retrieval
>
> Authenticate the submitting worker and validate field types and plot references before accepting a submission. A submission envelope contains the visit UUID, the complete visit payload, the starting revision ID for an edit, and an idempotency key. The store records the authenticated author and receipt time and assigns identifiers to accepted submissions and revisions. Preserve the original payload separately from any later resolution. A retry with the same key and identical payload returns the original acceptance result; reuse with a different payload is rejected.
>
> Current-state retrieval distinguishes a usable current visit from unresolved review work. Submission-history retrieval exposes original submissions and their revision relationships for review and provenance. Review outcomes record the coordinator's identity and contributing submission IDs.
>
> ## Downstream Contracts
>
> Tablet-sync must retain base revision IDs, submit complete visits, and show workers the outcomes of submissions that become competing revisions. Its local storage and retry state machine depend on the completed submission contract.
>
> Review-export must provide revision comparison and exclude unresolved visits from the reviewed CSV. Its coordinator interface and export eligibility handling depend on the completed retrieval and resolution contract.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives considered | Rationale |
> |---|---|---|---|
> | Concurrent visit edits | Whole-visit revisions with coordinator review | Field-aware three-way merge | Preserve the context of submitted observations without maintaining rules that can miss scientific relationships, accepting more review work. See [the decision](docs/intent/record-store/decisions/concurrent-visit-edits.md). |
>
> ## Open Questions & Future Decisions
>
> - How is the first revision created and represented when there is no starting revision? What happens if a visit UUID or base revision is unknown or belongs to another visit?
> - When an edit is based on an older revision, including one superseded by a resolution, which revisions constitute the review work? What happens to further edits submitted while that work is unresolved?
> - May a coordinator only select an existing revision, or also submit a new complete visit as the resolution? How are the contributing submissions identified?
> - What happens if a coordinator resolves a review using a stale view while another edit or resolution arrives? How are concurrent submissions and resolutions serialized?
> - What is returned for current-state retrieval while review is unresolved, and how can callers enumerate all pending review work and retrieve its full revision history?
> - What is the scope of an idempotency key, what constitutes an identical payload, and how are retries authenticated and handled after a failed or concurrent request?
> - Which validation failures are reported and how are archived plots handled for new visits versus historical edits?

## Decision document

`docs/intent/record-store/decisions/concurrent-visit-edits.md`:

> ---
> node: record-store
> ---
>
> # Decision: Concurrent Visit Edits
>
> ## Context
>
> Field workers can independently correct the same visit while tablets are offline for days. The record store must retain submitted observations and establish a reviewable current visit without treating arrival order as scientific authority. A visit contains related observations: for example, a change to species identification can affect the interpretation of its cover estimate. The server cannot reliably infer every such relationship from field names.
>
> ## Decision Elements
>
> - **Major — preserve observation context.** Keep scientifically related edits understandable together, including relationships the software cannot recognize. This supports the HLD's tenet that the path from submission to export remains inspectable.
> - **Major — coordinator workload.** Limit the volume and complexity of manual review for two coordinators preparing a weekly export.
> - **Moderate — operational and implementation burden.** Limit specialized rules that must be built, tested, and maintained by a small team, consistent with the HLD's preference for workflows without a dedicated systems administrator.
> - **Moderate — offline submission burden.** Limit the state and data that tablets must retain and transmit after extended disconnection.
>
> Both options retain original submissions; neither uses arrival order as evidence of authority.
>
> ## Options in the Domain
>
> ### Whole-visit revisions
>
> Each submission contains a complete visit and identifies its starting revision. Concurrent edits are retained as competing revisions for a coordinator to review. Until a conflict is resolved, the visit is held out of the reviewed CSV.
>
> - **Observation context: strong fit.** Each worker's submitted visit remains intact for comparison; the system does not automatically combine fields that may be scientifically related.
> - **Coordinator workload: weak fit.** Even edits to unrelated fields create review work and keep the visit out of export until resolved.
> - **Operational and implementation burden: strong fit.** The store needs revision and review handling but no maintained field-specific merge rules.
> - **Offline submission burden: partial fit.** Tablets retain base revision IDs rather than base snapshots, but submit complete visits.
>
> ### Field-aware three-way merge
>
> Each submission carries its base snapshot and structured changes. Rules compare the base and independent changes, automatically combining disjoint fields and sending overlaps to review. The original submissions remain available, and field-level provenance explains the combined result.
>
> - **Observation context: partial fit.** Rules can detect specified overlaps, but disjoint fields can still be scientifically related in ways the rules do not recognize.
> - **Coordinator workload: strong fit.** Unrelated edits can be combined without creating a review item, making more visits available for export.
> - **Operational and implementation burden: weak fit.** Rules for scalar fields, observer lists, and species entries require ongoing design, testing, and maintenance; review and export need field-level provenance.
> - **Offline submission burden: partial fit.** Structured changes can reduce submitted data, but tablets must retain base snapshots and construct changes.
>
> ## Selection
>
> Use whole-visit revisions. Preserving each worker's observation context without relying on rules to recognize scientific relationships outweighs the larger review queue and complete-visit submissions. This supports the HLD's inspectability tenet and accepts more coordinator work in exchange for less specialized merge maintenance.
>
> Field-aware merging remains a credible alternative if review volume or delayed exports become the dominant problem and the team can maintain and validate merge rules against the scientific relationships in its data. It would require a deliberate change to the record-store contract, not just a different presentation of the same revisions.
>
> Tablet sync must retain base revision IDs, submit complete visits, and convey competing-revision outcomes. Review/export must support revision comparison and keep unresolved visits out of the CSV. Their detailed designs depend on the record-store contract and are owned by those components.

The existing record-store specs remain generic and do not yet cover the selected revision policy; I’ll update them after the design is settled. The site-catalog design also still says the concurrency choice is pending, so that sibling document will need a later correction.

**First design question:** when resolving competing revisions, should a coordinator only select an existing complete revision, or may they also create a new complete visit combining or correcting observations? We can work through the other open questions one at a time.