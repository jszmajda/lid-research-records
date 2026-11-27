**Phase 2 Complete**
The record-store design is finalized in `docs/intent/record-store/record-store-design.md`.

It now defines:

- Immutable, complete visit revisions with no field-level automatic merging.
- Neutral-base handling that prevents receipt order from choosing scientific authority.
- Competing initial creations with no current revision until review.
- Dynamic neutral-base recalculation when another branch joins an open case.
- Linearizable submissions, retrieval, history, and coordinator resolutions.
- Idempotent worker submissions and coordinator resolutions.
- Explicit reviewed-versus-contributing revision provenance.
- Stable machine-readable rejection reasons and retry behavior.
- Exact-set checks preventing resolution from overlooking newly accepted revisions.
- Record-store obligations that tablet-sync and review-export must accommodate.

The full rationale is recorded in `docs/intent/record-store/decisions/whole-visit-revisions.md`. It presents field-aware three-way merge as a credible alternative because it could reduce review volume and improve Friday export readiness without necessarily changing the tablet envelope. It also records why it was not selected: field-level provenance, maintained merge semantics, and the risk of silently combining scientifically related observations.

`docs/high-level-design.md` now marks record-store as designed and implementation pending.

Two independent cold checks passed after the edge-case corrections, and `git diff --check` passes. No EARS requirements have been changed yet.

Please approve Phase 2 or provide changes. On approval, I’ll draft the record-store EARS requirements for Phase 3.