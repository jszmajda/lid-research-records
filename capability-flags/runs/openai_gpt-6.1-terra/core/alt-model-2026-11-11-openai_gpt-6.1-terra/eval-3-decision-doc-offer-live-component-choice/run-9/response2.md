I wrote the decision document at `docs/intent/record-store/decisions/concurrent-visit-edits.md`:

---

# Decision: Concurrent Visit Edits

## Context

Field workers can independently correct the same vegetation visit while tablets are offline. Submissions may arrive days after the state on which they were based, and arrival order does not establish scientific authority. A visit contains fields whose scientific meaning can be related even when their data structures are distinct: for example, a species identification and its cover estimate.

The record store must preserve submitted edits and give coordinators a way to resolve competing work. Its concurrency policy also shapes tablet submissions, coordinator review, and export eligibility.

## Decision Elements

- **Major — preserve scientific context.** Keep a worker's complete submitted observation available for review without assuming that independently edited fields are scientifically unrelated. This supports the project's tenet that the path from submission to export remain inspectable.
- **Moderate — coordinator workload and timely export.** Limit the amount of review needed for routine independent corrections, given two coordinators and a weekly CSV.
- **Moderate — implementation and maintenance burden.** Keep the tablet protocol and server-side reconciliation understandable and maintainable for the team, in keeping with the tenet favoring workflows that do not require a dedicated systems administrator.

## Options in the Domain

### Whole-visit revisions

Each submission is a complete visit revision naming the revision from which it was edited. Competing revisions are retained as complete submissions and sent to coordinators for review. Even edits to different fields can create competing revisions.

- **Strong — scientific context:** Each worker's submitted visit remains available as a unit, without automatic combination of fields whose relationship may be significant.
- **Partial — coordinator workload and timely export:** Unrelated edits can create review work, and unresolved visits are held out of the CSV.
- **Strong — implementation and maintenance burden:** Tablets track base revision IDs, and the store does not need field-specific merge rules. Review requires comparison of complete revisions.

### Field-aware three-way merge

Tablets retain a base snapshot and submit structured changes. The store compares the base, the submitted changes, and the current state: unrelated field changes can be combined automatically, while overlapping changes go to review. Merge rules must account for scalar fields, observer lists, and species entries.

- **Partial — scientific context:** Original submissions remain available, but automatic combinations can join scientifically related edits that appear unrelated to field-level rules. Field-level provenance is needed to explain the combined result.
- **Strong — coordinator workload and timely export:** Disjoint edits can be combined without creating a review item, leaving fewer visits waiting for review before export.
- **Partial — implementation and maintenance burden:** Tablets retain base snapshots and structured changes; the store and review workflow must maintain merge rules and field-level provenance.

## Selection

Use whole-visit revisions. Protecting the context of each submitted observation outweighs the additional review queue: field-level rules cannot reliably recognize all scientific relationships between edits. Three-way merging remains a credible alternative if review workload becomes more important, but its benefit depends on maintaining rules and accepting the risk of scientifically misleading combinations.

Tablet-sync must retain base revision IDs and convey pending competing revisions to workers. Review-export must provide a revision comparison workflow and hold unresolved visits out of the CSV. The record-store design defines the submission and resolution contracts these components depend on; their detailed designs remain with their respective nodes.

---

Does this capture the decision and its tradeoffs accurately, and do you approve the HLD update shown previously so I can complete the record-store design?

Also, would you add **“Preserve scientific context over reducing review workload”** as a project tenet?