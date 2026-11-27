Record-store LLD rewritten with explicit rationale and downstream impact.

`docs/intent/record-store/record-store-design.md` updated:

**Concurrency Policy: Whole-Visit Revisions** retained with submission envelope, revision model, retrieval and resolution contracts as before.

**Decisions & Alternatives** now records:
- Chosen: Whole-visit revisions with base revision IDs and coordinator resolution
- Alternative: Field-aware three-way merge with automatic combination of disjoint fields
- Rationale expanded: whole-visit preserves complete field-worker submissions and avoids merge rules that could silently combine scientifically related edits the server cannot infer. Field-aware merge remains credible for a different risk profile — it reduces review volume and gets more visits export-ready sooner, and would require maintained rules for scalars, observer lists and species entries. It was rejected here because automatic combination can cross scientific relationships without notice, and the team prefers explicit review of every competing whole-visit submission.

**Downstream accommodations added**
Tablet-sync must:
- retain baseRevisionId for each local draft and send it with every submission;
- display pending competing revisions when sync shows base divergence;
- surface server acceptance results and unresolved status.

Review-export must:
- provide a revision comparison screen showing two complete visit payloads side-by-side with author, receipt time and base linkage;
- hold any visit with pending revisions out of the Friday CSV export;
- record coordinator resolution with identity and contributing submission IDs for auditability.

These follow directly from keeping each submitted visit intact and deferring all conflict resolution to coordinators.

The Decisions & Alternatives table and downstream accommodations are now context-free and include why the rejected approach would still be considered.

Please confirm this write-up captures the intent and the downstream work you expect tablet-sync and review-export to accommodate, and whether you want the edge-case probe questions resolved now or deferred to implementation.
