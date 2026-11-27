Record-store design updated with full rationale and downstream accommodation.

**Decisions & Alternatives – expanded**

Concurrent edit policy chosen: whole-visit revisions
- Alternatives considered: field-aware three-way merge with automatic combination of disjoint field edits.
- Rationale for choice: whole-visit preserves the worker's submitted visit as an intact unit, avoids maintaining merge rules for scalar fields, observer lists, and species entries, and prevents automatic combination of scientifically related edits the server cannot infer. Matches tenet to not silently discard edits and gives coordinators full context for scientific judgment. Trade is a larger review queue, even for unrelated field changes.

Why field-aware merge remains credible:
- Would reduce review volume by automatically combining disjoint edits and get more visits export-ready sooner.
- Requires maintained merge rules per field type and provenance tracking.
- Risks silent scientific coupling: e.g., species ID change paired with cover estimate change are field-disjoint but scientifically related. The team rejected that risk and the ongoing rule maintenance burden for a two-coordinator team.

**Downstream Accommodation added to LLD**

Tablet-sync:
- Must retain baseRevisionId for each local draft and send it with every submission.
- Tablet UI must surface pending competing revisions for a visit the worker last edited, showing submission under review and newer base existence.
- Sync state machines must handle server rejection when baseRevisionId is already resolved, prompting rebase onto current revision.

Review-export:
- Must implement a revision comparison screen for coordinators to resolve competing whole-visit revisions.
- Export eligibility governed by reviewStatus: visits with pending review are held out of the CSV.
- Export must include provenance linking an exported row to resolving coordinator and contributing submission IDs, and preserve ability to inspect original submitted payloads for any exported visit.

The updated docs/intent/record-store/record-store-design.md now contains the Decisions table, the alternative-credibility note, and the Downstream Accommodation section. Specs REC-001 to REC-011 remain as drafted.

Approve this revision to the LLD, or provide numbered feedback to adjust wording before we proceed to Phase 4 intent-narrowing edge audit?