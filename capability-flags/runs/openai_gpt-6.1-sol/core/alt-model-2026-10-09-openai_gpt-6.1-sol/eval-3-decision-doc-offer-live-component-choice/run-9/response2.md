Created `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the record-store design’s Decisions & Alternatives table.

It records the trade-off, gives field-aware merging a fair case, identifies when reconsideration would make sense, and spells out the tablet and export obligations. `git diff --check` passes.

<details>
<summary>Full decision document</summary>

# Decision: Concurrent Visit Edits

## Context

TidePlot receives complete vegetation plot visits from shared tablets that can be offline for 48 hours. Workers can independently correct copies of the same visit. Observation date, observers, species identification, cover estimates, and notes can have scientific relationships that are not apparent from their field names. Arrival order does not establish which correction is authoritative.

Both approaches considered here retain original submissions. The decision concerns how those submissions become a current visit, where reconciliation judgment lives, and what the tablet and review/export contracts must carry. Record-store owns that mechanism; tablet-sync and review-export consume its contract.

Two coordinators handle review, and a regional science partner receives a reviewed CSV each Friday. Reconciliation therefore trades scientific fidelity and software maintenance against coordinator workload and timely export coverage. The design has no measured conflict rate or review-capacity estimate with which to quantify that trade-off.

## Decision Elements

| Criterion | Importance | Basis |
|---|---|---|
| Preserve whole-visit scientific meaning during reconciliation | Major | Fields that appear structurally independent can represent one scientific correction. Reconciliation should not require the server to infer that relationship. |
| Keep reconciliation logic maintainable | Major | The tenet “Prefer workflows two coordinators can operate without a dedicated systems administrator” favors a contract whose correctness does not depend on ongoing domain-specific merge-rule maintenance. |
| Keep the review queue manageable and Friday exports useful | Moderate | The same operational tenet and the Friday delivery goal favor less routine review. Unresolved visits reduce export coverage, even if the delivered CSV is internally sound. |
| Make the reconciliation outcome easy to explain | Moderate | The tenet “Keep the path from a submitted observation to an exported value inspectable” favors provenance a coordinator can reconstruct without understanding many merge rules. |
| Limit tablet reconciliation bookkeeping | Minor | The offline-collection tenet favors durable local capture and understandable recovery. Both approaches support offline work, but they require different local metadata and retry handling. |

Retention of original submissions is common to both options rather than a differentiating criterion. Neither option can use silent overwrite to reduce its review or storage costs.

## Options in the Domain

### Whole-visit revisions

Each submission contains a complete visit and identifies its base revision. An uncontested correction can advance the current revision. A competing revision is retained as review work, and the visit becomes ineligible for export until a coordinator resolves it. Apparent independence between changed fields does not waive review.

For example, two workers start from revision R1. One corrects an observer name; the other adds a species. Their complete revisions compete even though their changes occupy different fields. A coordinator inspects them rather than the server producing a combined payload. The same mechanism applies when one worker revises a species identification and another revises its cover estimate.

- **Strong** fit for whole-visit scientific meaning: each worker’s complete submitted observation remains an intact candidate, and reconciliation judgment stays with a coordinator.
- **Strong** fit for maintainable reconciliation logic: the server compares revision identity and visit state rather than maintaining per-field merge semantics. Atomic state changes and retry correctness still require implementation care.
- **Weak** fit for review workload and Friday export coverage: unrelated concurrent corrections create review work; unresolved visits are withheld from the CSV. The cost depends on conflict frequency and coordinator throughput.
- **Strong** fit for explainability: comparison inputs are complete revisions with authors, bases, receipt times, and retained resolution outcomes.
- **Strong** fit for limited tablet bookkeeping: tablets retain base revision IDs and complete payloads. They still need durable retry envelopes and a policy for local edits made before a server revision ID is received. Complete payloads can cost more bandwidth than structured changes.

### Field-aware three-way merge

Each edit supplies its base state and structured changes. The server compares the base, the current visit, and the submitted changes. Maintained rules for scalar fields, observer lists, and species entries automatically combine compatible changes; overlapping or unsupported changes become review work. Original submissions remain available, and merged values carry field-level provenance.

For the observer-name and added-species example, a rule set can combine both corrections without coordinator intervention. A conservative rule set can also declare species identification and cover estimates to be a coupled group, routing changes within that group to review. This makes the approach credible where relationships are sufficiently explicit and maintainable, although unmodeled scientific relationships can still cross those groups.

- **Partial** fit for whole-visit scientific meaning: declared dependencies and conservative rules protect known relationships, but structurally disjoint changes can have an unmodeled scientific relationship. Automatic composition can create a visit that no worker submitted as a unit.
- **Weak** fit for maintainable reconciliation logic: field types, list identity, species-entry identity, coupled groups, schema changes, and provenance require maintained rules and regression coverage. Routing more cases to review reduces this burden but also reduces the automatic-merge benefit.
- **Strong** fit for review workload and Friday export coverage: compatible disjoint changes can proceed without entering the concurrency review queue. The benefit depends on how many edits the rule set can safely classify; overlaps still require review.
- **Partial** fit for explainability: field-level provenance can make every exported value traceable, but reconstructing a combined visit also requires the base states, rule behavior, and merge outcome.
- **Partial** fit for limited tablet bookkeeping: tablets retain base snapshots and structured changes, preserve them across retries, and accommodate the change schema. Smaller change payloads can reduce transfer volume.

## Selection

Use **whole-visit revisions**. Preserving the scientific meaning of a complete submitted visit and avoiding ongoing domain-specific merge-rule maintenance take priority over reducing the review queue. The additional review workload and the possibility of withholding more visits from a Friday CSV are accepted costs.

The selection supports an inspectable path from submissions to exported values and a simpler operational contract. It also puts pressure on the tenet favoring workflows two coordinators can operate: simpler software shifts reconciliation work onto those coordinators. The review/export design must make that workload visible rather than assume it is negligible.

Field-aware three-way merge remains a credible alternative if measured review backlog or export omissions make whole-visit review impractical, and if the team can define and maintain conservative scientific dependency rules with adequate validation. Reconsideration would require revisiting the record-store contract and both consuming designs, not merely substituting a server-side helper.

This decision establishes automatic acceptance of uncontested whole revisions and coordinator review of competitors. Whether coordinators may author a complete replacement during resolution, rather than only select an existing revision, remains an open LLD choice.

### Tablet-sync obligations

- Retain the base revision ID for each correction and submit a complete visit payload.
- Persist the submission envelope and idempotency key so retries identify the same submission.
- Distinguish a stored submission from a revision becoming current. Acceptance does not guarantee that the visit is resolved or exportable.
- Retrieve fresh visit state to show outstanding review work; an original acceptance result can predate a later competitor.
- Design local sequencing for edits made before an earlier submission receives its server revision ID, and recovery for late submissions whose base predates a coordinator resolution.
- Accommodate complete-payload storage and transfer without requiring connectivity for field capture.

### Review-export obligations

- Provide complete-revision comparison with authors, base revisions, receipt times, and resolution history, including retained unselected submissions.
- Resolve against the retrieved visit state version and refresh comparison inputs after a stale-state rejection. Two coordinators must not silently overwrite each other’s outcomes.
- Exclude unresolved visits from the CSV even when an older current revision remains available. A conflict-free revision must still satisfy the review/export node’s own approval rules.
- Define how export selection remains consistent with concurrent submissions and resolutions.
- Make unresolved work and its effect on the Friday export visible to coordinators. Queue measurements can inform a future reconsideration; no acceptable backlog threshold is established by this decision.
- Accommodate the resolution outcome and retry contracts once the record-store LLD settles them.

These are obligations on the consuming nodes, not designs for their local state machine, comparison screen, or export implementation.

## References

- Record-store design: `docs/intent/record-store/record-store-design.md`
- High-level design: `docs/high-level-design.md`

</details>

Does this capture the rationale you want preserved? To continue finalizing the record-store LLD, should coordinators **only select an existing revision**, or also **author a complete replacement with contributing submissions recorded**?