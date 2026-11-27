Phase 2 LLD revised with the alternative rationale and downstream accommodations you requested.

**File:** `docs/intent/record-store/record-store-design.md`

**Concurrency Policy**
Whole-visit revisions are chosen. Each edit names its starting revision via `baseRevisionId`; concurrent edits produce competing complete revisions resolved by a coordinator. No automatic merging.

Trade-off documented: even unrelated field edits create review work and increase queue size, in exchange for preserving whole-visit intent and avoiding merge rules that could combine scientifically related edits without noticing. Server does not need to understand relationships between species ID/cover, observer lists, notes.

**Why the other approach was still credible**
Field-aware three-way merge was considered because it would reduce review volume by automatically combining disjoint field changes and only reviewing overlaps, getting more visits ready for export with smaller submissions. It was rejected because it requires maintained rules for scalar fields, observer lists, and species entries, and automatically combined fields can cross scientific relationships the rules do not understand. The user preference is a larger review queue over maintaining merge rules that can combine scientifically related edits without noticing.

**Downstream Accommodations**

Tablet-sync must:
- Store `baseRevisionId` alongside each local draft and last known server revisionId
- Include `baseRevisionId` in submit envelope; update local base to returned revisionId on acceptance
- On retrieval, warn worker if `pendingRevisions` exist for a visit they are editing and offer view/compare
- Preserve same `idempotencyKey` and `baseRevisionId` on retry; a change in base requires a new edit

Review-export must:
- Query current-state view and filter out visits where `pendingRevisions` is non-empty
- Present a revision comparison screen showing author, submittedAt, baseRevisionId, and full payload diff for two+ pending revisions
- Export eligibility rule: visit eligible only when `resolvedRevisionId` is non-null and `pendingRevisions` empty
- Retain provenance in export metadata: resolved revisionId, resolution timestamp, coordinatorId, superseded revision IDs

Decisions & Alternatives table now includes the full rationale for field-aware three-way merge and the user preference that drove the choice.

**STOP for user review.**
Confirm this LLD is complete and context-free. On explicit approval I will proceed to Phase 3 — update `docs/intent/record-store/record-store-specs.md` with EARS specs for whole-visit revisions, submission envelope, retrieval view, and resolution operations.