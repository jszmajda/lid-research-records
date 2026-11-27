Record-store design updated with proper rationale and downstream implications.

**Decisions & Alternatives – expanded rationale**
The LLD now records why field-aware three-way merge remained credible:
- It would reduce review volume and get more visits ready for export by automatically combining disjoint field changes and only reviewing overlaps.
- Tablet-sync would retain base snapshots and send structured changes; review-export would need field-level provenance and a review view for overlapping changes.

It was rejected because:
- Automatically combined fields can cross scientific relationships the rules do not understand, e.g., revising a species identification and its cover estimate together.
- Maintaining merge rules for scalar fields, observer lists, and species entries adds implementation burden for a two-coordinator team.
- Whole-visit revisions preserve the worker’s submitted visit as a unit, keep submission size small, require little merge logic, and make provenance inspectable. The trade is a larger review queue.

**Downstream Contract Implications added to the LLD**

Tablet-sync must:
- Retain baseRevisionId for each local draft and send it with every submission so the record store can place the edit relative to the visit’s history.
- Store the revision ID returned on acceptance and update its local base for subsequent edits.
- Display pending competing revisions returned by current-state retrieval and surface pending status to field workers.

Review-export must:
- Provide a revision comparison screen that shows two whole-visit payloads side by side with author, server receipt time, and base revision lineage.
- Hold unresolved visits out of the partner CSV export; export eligibility is `hasUnresolvedWork == false`.
- Expose a resolution operation that selects a winning revision and records coordinator identity for audit.

The design file is now at `docs/intent/record-store/record-store-design.md` with the Decisions & Alternatives table expanded and a Downstream Contract Implications section documenting the tablet and export accommodations.

Confirm this write-up and the edge-case triage, and I’ll proceed to Phase 4 intent-narrowing edge audit.