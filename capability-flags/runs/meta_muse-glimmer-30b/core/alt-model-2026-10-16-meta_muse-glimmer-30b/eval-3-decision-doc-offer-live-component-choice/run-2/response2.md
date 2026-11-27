Updated record-store design with explicit downstream accommodations and full rationale for the rejected alternative.

**docs/intent/record-store/record-store-design.md**

Added Downstream Contract Implications:
- Tablet-sync must retain base revision IDs locally and send them with each submission. Submission responses must surface whether the edit became the new current resolved revision or was accepted as a competing revision. The tablet UI must show pending competing revisions for visits the worker previously edited and explain that a coordinator will choose between complete visit versions.
- Review-export must present a revision comparison workflow showing two complete visit payloads side by side with author and receipt metadata. Coordinators resolve by picking one revision; the chosen revision becomes the exportable current state. Review-export must exclude visits with pendingRevisions from the Friday CSV and make the unresolved set visible before export.
- The submission envelope and retrieval shape defined here are the contract both downstream nodes consume; neither may invent its own concurrency semantics.

Decisions & Alternatives table expanded:
- Chosen: Whole-visit revisions with explicit coordinator resolution
- Alternatives Considered: Field-aware three-way merge with automatic combination of disjoint field changes
- Rationale now records why merge was credible — it would reduce review volume and get more visits ready for export by auto-combining disjoint field changes and only reviewing overlaps — and why it was rejected — it requires maintained merge rules for scalar fields, observer lists and species entries, and risks automatically combining edits that are scientifically related even though fields appear disjoint. The team accepts a larger review queue to avoid rules that can combine scientifically related edits without noticing. The table also notes the downstream differences: merge would have required tablet-sync to retain base snapshots and send structured changes and review-export to need field-level provenance and a review view for overlapping changes; whole-visit revisions require tablets to track base revision IDs and display pending competing revisions, and review-export to provide a revision comparison screen and hold unresolved visits out of the CSV.

EARS specs REC-007 to REC-012 remain as defined and trace to the revision model, retrieval, resolution and export eligibility.

The design is now context-free and records current intent. Confirm you want to lock this LLD and proceed to Phase 4 intent-narrowing edge audit, or edit further before the audit.