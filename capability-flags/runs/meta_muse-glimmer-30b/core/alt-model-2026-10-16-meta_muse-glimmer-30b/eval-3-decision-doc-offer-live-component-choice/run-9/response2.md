The record-store design is now written up with whole-visit revisions selected and downstream accommodations made explicit.

**Design updated**
`docs/intent/record-store/record-store-design.md`

- Submission envelope now documents `visit_id`, `base_revision_id`, full `payload`, `author_id`, `idempotency_key`, `client_timestamp`. Validation of field types and plot references is performed on receipt; idempotency is enforced.
- Current state is the `resolved_revision_id` payload only. `pending_revisions` are tracked when a submission’s base does not match the resolved revision or forms a fork.
- Unresolved work is defined as one or more pending revisions; submission-history returns the revision graph for whole-visit comparison.
- Resolution records coordinator identity, chosen `revision_id`, superseded submission IDs, and time. Original submissions are never discarded.

**Downstream contract implications added**

*tablet-sync*
- Must retain and send `base_revision_id` for every submission.
- Must store server `revision_id` and receipt outcome locally for retry with idempotency keys.
- Must surface to workers whether a visit has pending competing revisions and whether the exportable state differs from their last submission.
- Local storage keeps full visit payloads; no structured delta required.

*review-export*
- Must present a revision comparison screen showing whole-visit payloads side-by-side with author, receipt time, and base revision linkage.
- Export eligibility is restricted to visits with no pending revisions; unresolved visits are held out of the partner CSV.
- Export metadata must cite `resolved_revision_id` and resolving coordinator to keep the path from submission to export inspectable.
- Review queue volume will be higher than with automatic merge because even unrelated-field edits create competing revisions.

**Decisions & Alternatives**
The Decisions & Alternatives table now records why field-aware three-way merge was considered:
- It would reduce review volume and get more visits ready for export by automatically combining disjoint field changes.
- It would require tablets to keep base snapshots and send structured changes, and review/export to maintain field-level provenance and merge rules.
- It was rejected because automatic combination can cross scientific relationships the rules do not understand, and the team prefers a bigger review queue over maintaining merge rules that can combine scientifically related edits without noticing. Whole-visit preserves each submission as an intact unit and aligns with the tenet to not silently discard edits.

EARS specs in `docs/intent/record-store/record-store-specs.md` were updated to REC-007 to REC-012 to cover base revision storage, pending handling, retrieval of resolved only, resolution update, first-submission resolution, and rejection of unknown bases.

Record-store design is complete for now. Tablet-sync and review-export can proceed once you confirm the edge-case handling preferences from the previous audit, or I can proceed with the current strict manual-review defaults.
