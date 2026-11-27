Record-store design updated with the requested write-up.

docs/intent/record-store/record-store-design.md now includes:

**Concurrency Policy: Whole-visit Revisions**
Whole-visit revisions selected. Each edit names its base revision; edits from the same base produce competing complete revisions for coordinator resolution. Trade-off is a larger review queue in exchange for preserving each worker’s submitted visit as an intact unit and avoiding merge logic that could combine scientifically related edits without noticing.

**Alternative Considered — Field-aware three-way merge**
Field-aware three-way merge was considered and remains credible. It would send base state + structured changes, auto-combine disjoint fields, and review overlaps. Benefits: reduced review volume, faster export readiness, smaller submissions via deltas.

Rejected for this release because automatic field combination can cross scientific relationships the rules do not understand — e.g., a species identification and its cover estimate are linked, but a field-level rule would treat them as independent and could silently merge a corrected ID with an old cover value from another worker. Maintaining merge rules for scalars, observer lists, and species entries is ongoing burden, and the team preferred a bigger review queue over risking silent scientific incoherence.

The alternative is not closed permanently; it can be revisited with explicit scientific relationship rules and manual approval for combined records if review workload proves unsustainable.

**Downstream Accommodations**

Tablet-sync must:
* Retain base_revision_id for each local draft and display it on submit
* Track pending acknowledgments and server-side competing revisions
* Show “pending review” state for submitted visits in a competing set without blocking new observations
* Handle server responses where a submission creates a new competing revision rather than becoming current

Review-export must:
* Provide a revision comparison workflow presenting two or more complete visit payloads side-by-side for coordinator selection
* Exclude unresolved visits from the Friday partner CSV; export eligibility = current_revision_id non-null and unresolved=false
* Show provenance for resolved visits: contributing submissions, resolving coordinator, timestamp, chosen revision
* Present a review queue grouped by visit and base revision with age indicators for unresolved work

Decisions & Alternatives table updated to record the choice, the field-aware merge alternative, and rationale referencing inspectability tenet and risk of silent scientific incoherence.

The LLD is now context-free and carries the current intent. Confirm you want to proceed to Phase 4 Intent-narrowing edge audit, or adjust the alternative rationale / downstream accommodations further before the stop.
